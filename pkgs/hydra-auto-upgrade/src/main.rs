mod cli;
mod hydra;

use clap::Parser;
use clap::{Args, Command, CommandFactory, Parser, Subcommand, ValueHint};
use clap_complete::{generate, Generator};
use cli::{Opt, Profile};
use core::error::Error;
use hydra::Build;
use std::{
    fs,
    io::{self, BufRead},
    path::Path,
};

type Result<T> = std::result::Result<T, Box<dyn Error>>;

fn main() -> Result<()> {
    let opt = cli::Opt::parse();

    if let Some(generator) = opt.generator {
        let mut cmd = Opt::command();
        eprintln!("Generating completion file for {generator:?}...");
        print_completions(generator, &mut cmd);
    }

    let command = opt.command.expect("no command provided");

    let profile = &opt.profile;
    let profile_path = profile.path();

    let build = hydra::get_latest_build(&opt)?;

    let changed = if fs::canonicalize(profile.path())? == build.out_path() {
        if !profile.force() {
            eprintln!("Profile unchanged, skipping activation");
            return Ok(());
        }
        eprintln!("Re-running activation script");
        false
    } else {
        copy(&build)?;
        diff(&profile_path, &build)?;
        eprintln!();
        true
    };

    if changed && atty::is(atty::Stream::Stdout) {
        eprintln!("Press enter to continue");
        let mut stdin = std::io::stdin().lock();
        stdin.read_line(&mut String::new())?;
    }

    switch(&profile, &build)?;
    set_profile(&profile_path, &build)?;

    Ok(())
}

pub fn print_completions<G: Generator>(gen: G, cmd: &mut Command) {
    generate(gen, cmd, cmd.get_name().to_string(), &mut io::stdout());
}

fn copy(build: &Build) -> io::Result<()> {
    let mut command = Command::new("nix");
    command.arg("build").arg("--no-link").arg(&build.out_path());
    exec(&mut command)
}

fn diff(profile_path: &Path, build: &Build) -> io::Result<()> {
    let mut command = Command::new("nvd");
    command
        .arg("--color=always")
        .arg("diff")
        .arg(profile_path)
        .arg(build.out_path());
    exec(&mut command)
}

fn switch(profile: &Profile, build: &Build) -> io::Result<()> {
    let command = match profile {
        Profile::Home { .. } => "activate",
        #[cfg(target_os = "linux")]
        Profile::System { .. } => "bin/switch-to-configuration",
        #[cfg(target_os = "macos")]
        Profile::System { .. } => "activate",
    };

    let mut command = Command::new(build.out_path().join(command));

    #[cfg(target_os = "linux")]
    if let Profile::System {
        operation, args, ..
    } = profile
    {
        command.arg(operation);
        command.args(args);
    }

    exec(&mut command)
}

fn set_profile(profile_path: &Path, build: &Build) -> io::Result<()> {
    let mut command = Command::new("nix");
    command
        .arg("build")
        .arg("--no-link")
        .arg("--profile")
        .arg(profile_path)
        .arg(build.out_path());
    exec(&mut command)
}

fn exec(command: &mut Command) -> io::Result<()> {
    eprintln!("{command:?}");
    command.spawn()?.wait()?;
    Ok(())
}
