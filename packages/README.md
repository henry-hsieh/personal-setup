# Package Specification

This document describes the specification for `package.yaml` files used in the personal-setup build system.

## Overview

Each package is defined in a `package.yaml` file located in its own subdirectory under `packages/`. The build system processes these files to download, build, and install software packages into a user environment.

## Schema

### Required Fields

- `name` (string): The name of the package.
- `version` (string): The version of the package to install.
- `datasource` (string): The data source for version updates (used by Renovate). Common values:
  - `github-releases`: For GitHub releases
  - `github-tags`: For GitHub tags
  - `git-refs`: For Git repositories
  - `custom.<name>`: Custom data sources (e.g., `custom.unofficial_node`, `custom.jdk_lts`)
- `package` (string): The package identifier, typically the GitHub repository in `owner/repo` format.
- `url` (string): The download URL template. Use `{version}` as a placeholder for the version.
- `extract` (boolean): Whether the downloaded file should be extracted (true for archives, false for single files or git repos).
- `checksum_source` (string): How to obtain checksums for verification. Options:
  - `github-release`: Use GitHub release checksums
  - `git-refs`: Use git commit hashes (for git repositories)
  - A URL template for checksum files
  - Embedded 64 hex chars for sha256
  - `none`: Skip checksum verification
- `files` (list): A list of file mappings to install.

### File Mappings

Each item in the `files` list is a dictionary with:

- `src` (string): Source path. Can be:
  - A path within the extracted archive
  - A URL to download
  - A local path (must start with `{pkg_dir}` for downloadless packages)
- `dst` (string): Destination path relative to the user's home directory (typically starts with `.local/`).

### Optional Fields

- `build_cmds` (list of strings): Commands to execute during the build process. Run in the package's workspace directory.
- `init_cmds` (list of strings): Commands to execute after installation. Run in the user's environment.
- `cache` (list of strings): Directory patterns to cache between builds.
- `branch` (string): Branch name for git-based packages (used with `git-refs` datasource).
- `versioning` (string): Versioning scheme for Renovate (default: `semver`).

## Template Variables

The following variables can be used in URL templates, file paths, and commands:

- `{version}`: Replaced with the package version
- `{pkg_dir}`: Replaced with the absolute path to the package directory

## Package Types

### Archive Packages
For packages distributed as archives (tar.gz, zip, etc.):

```yaml
name: example
version: 1.0.0
datasource: github-releases
package: owner/repo
url: https://github.com/owner/repo/releases/download/v{version}/example-{version}.tar.gz
extract: true
checksum_source: github-release
files:
  - src: bin/example
    dst: .local/bin/example
```

### Git Packages
For packages built from git repositories:

```yaml
name: example
version: v1.0.0
datasource: git-refs
package: owner/repo
url: https://github.com/owner/repo.git
extract: false
checksum_source: git-refs
build_cmds:
  - make
  - make install DESTDIR={out_dir}
files:
  - src: bin/example
    dst: .local/bin/example
cache:
  - build
```

### Single File Packages
For packages that are single executable files:

```yaml
name: example
version: 1.0.0
datasource: github-releases
package: owner/repo
url: https://github.com/owner/repo/releases/download/v{version}/example
extract: false
checksum_source: github-release
files:
  - src: example
    dst: .local/bin/example
```

### Downloadless Packages
For packages that only copy local files or download from URLs:

```yaml
name: example
version: 1.0.0
files:
  - src: https://example.com/script.sh
    dst: .local/bin/script.sh
  - src: {pkg_dir}/local-file.txt
    dst: .local/share/example/file.txt
init_cmds:
  - chmod +x $HOME/.local/bin/script.sh
```

## Examples

See the existing packages in this directory for real-world examples of different package types.
