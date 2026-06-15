# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A collection of bash shell utilities intended for use in shell scripts and cron jobs. No build system or test framework — scripts are standalone and run directly.

## Usage

```bash
# command-timeout.sh: run a command only if it hasn't run within the last N seconds
./command-timeout.sh "<command>" <timeout_seconds>

# Example: run a backup script at most once per hour
./command-timeout.sh "/usr/local/bin/backup.sh" 3600
```

## Architecture

Each utility is a self-contained `.sh` file. Listed below are usage patterns for every file.

- The pattern for `command-timeout.sh`:
  - Every time the command is run, a lock file is created
  - **Lock files** are stored under `/tmp/timeout/`, named by a truncated sha256 of the command string.
  - **Elapsed time** is computed from the lock file's mtime (`date -r`), falling back to 0 if missing.
  - **Cross-platform date** handling: GNU `date` (Linux) vs BSD `date` (macOS) is detected via `date --version`.

When adding new utilities, follow the same self-contained single-file pattern. Maintain compatibility with both GNU/Linux and BSD/macOS tooling where relevant.
