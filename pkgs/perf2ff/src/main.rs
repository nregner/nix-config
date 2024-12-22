//! https://github.com/firefox-devtools/profiler/blob/main/docs-developer/loading-in-profiles.md#url

use std::io::Cursor;
use std::net::{Ipv4Addr, SocketAddr};
use std::process::Command;
use std::sync::Arc;
use std::{env, fs, io};

// use http::{Method, Request, Response, StatusCode};
use http_body_util::{BodyExt, Full};
use hyper::body::{Bytes, Incoming};
use hyper::header::{HeaderValue, ACCESS_CONTROL_ALLOW_ORIGIN, CONTENT_TYPE};
use hyper::service::service_fn;
use hyper::{Method, Request, Response, StatusCode};
use hyper_util::rt::{TokioExecutor, TokioIo};
use hyper_util::server::conn::auto::Builder;
use rustls::pki_types::{CertificateDer, PrivateKeyDer};
use rustls::ServerConfig;
use tokio::net::TcpListener;
use tokio_rustls::TlsAcceptor;
use url::Url;

fn main() -> anyhow::Result<()> {
    run_server()?;
    Ok(())
}

#[tokio::main(flavor = "current_thread")]
async fn run_server() -> anyhow::Result<()> {
    let addr = SocketAddr::new(Ipv4Addr::LOCALHOST.into(), 3000);
    let port = addr.port();

    let certs = load_certs()?;
    let key = load_private_key()?;

    let incoming = TcpListener::bind(&addr).await?;

    let server_config = ServerConfig::builder()
        .with_no_client_auth()
        .with_single_cert(certs, key)?;
    // server_config.alpn_protocols = vec![b"h2".to_vec(), b"http/1.1".to_vec(), b"http/1.0".to_vec()];
    let tls_acceptor = TlsAcceptor::from(Arc::new(server_config));

    let service = service_fn(echo);

    let mut url = Url::parse("https://profiler.firefox.com/from-url/")?;
    url.path_segments_mut()
        .expect("base url")
        .push(&format!("https://localhost:{port}"));
    Command::new("firefox")
        .arg(url.to_string())
        .spawn()?
        .wait()?;

    loop {
        let (tcp_stream, _remote_addr) = incoming.accept().await?;

        let tls_acceptor = tls_acceptor.clone();
        tokio::spawn(async move {
            let tls_stream = match tls_acceptor.accept(tcp_stream).await {
                Ok(tls_stream) => tls_stream,
                Err(err) => {
                    eprintln!("failed to perform tls handshake: {err:#}");
                    return;
                }
            };
            if let Err(err) = Builder::new(TokioExecutor::new())
                .serve_connection(TokioIo::new(tls_stream), service)
                .await
            {
                eprintln!("failed to serve connection: {err:#}");
            }
        });
    }
}

async fn echo(req: Request<Incoming>) -> Result<Response<Full<Bytes>>, hyper::Error> {
    let mut response = Response::new(Full::default());
    let headers = response.headers_mut();
    headers.insert(
        ACCESS_CONTROL_ALLOW_ORIGIN,
        HeaderValue::from_static("https://profiler.firefox.com"),
    );
    headers.insert(CONTENT_TYPE, HeaderValue::from_static("application/json"));
    match dbg!((req.method(), req.uri().path())) {
        (&Method::GET, "/") => {
            *response.body_mut() = Full::from("Try POST /echo\n");
        }
        (&Method::POST, "/echo") => {
            *response.body_mut() = Full::from(req.into_body().collect().await?.to_bytes());
        }
        _ => {
            *response.status_mut() = StatusCode::NOT_FOUND;
        }
    };
    Ok(response)
}

fn load_certs() -> io::Result<Vec<CertificateDer<'static>>> {
    let mut reader = Cursor::new(include_bytes!("../localhost.cert"));
    rustls_pemfile::certs(&mut reader).collect()
}

fn load_private_key() -> io::Result<PrivateKeyDer<'static>> {
    let mut reader = Cursor::new(include_bytes!("../localhost.key"));
    rustls_pemfile::private_key(&mut reader).map(|key| key.unwrap())
}
