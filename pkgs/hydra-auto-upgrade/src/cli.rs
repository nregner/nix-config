use clap::{Parser, Subcommand};
use std::path::PathBuf;

#[derive(Parser, Debug)]
#[command()]
pub struct Args {
    #[arg(long, default_value = "https://hydra.nregner.net")]
    pub instance: String,
    #[arg(long, default_value = "nix-config")]
    pub project: String,
    #[arg(long, default_value = "master")]
    pub jobset: String,

    #[command(subcommand)]
    pub profile: Profile,
}

#[derive(Subcommand, Debug)]
pub enum Profile {
    Home {
        #[arg(long)]
        attr: Option<String>,
        #[arg(long)]
        force: bool,
    },
    System {
        #[arg(long)]
        attr: Option<String>,
        #[arg(long)]
        force: bool,
        #[cfg(target_os = "linux")]
        operation: String,
        #[cfg(target_os = "linux")]
        args: Vec<String>,
    },
}

impl Profile {
    pub fn force(&self) -> bool {
        match self {
            Profile::Home { force, .. } => *force,
            Profile::System { force, .. } => *force,
        }
    }

    pub fn attr(&self) -> Option<&str> {
        match self {
            Profile::Home { attr, .. } => attr,
            Profile::System { attr, .. } => attr,
        }
        .as_deref()
    }

    pub fn path(&self) -> PathBuf {
        match self {
            Profile::Home { .. } => {
                let home = std::env::home_dir().expect("Failed to locate user $HOME");
                home.join(".local/state/nix/profiles/home-manager")
            }
            Profile::System { .. } => PathBuf::from("/run/current-system"),
        }
    }

    pub fn top_attr(&self) -> &'static str {
        match self {
            Profile::Home { .. } => "homeConfigurations",
            #[cfg(target_os = "linux")]
            Profile::System { .. } => "nixosConfigurations",
            #[cfg(target_os = "macos")]
            Profile::System { .. } => "darwinConfigurations",
        }
    }
}
