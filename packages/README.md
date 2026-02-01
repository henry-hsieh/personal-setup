# Package Specification

<context>
This document describes the specification for `package.yaml` files used in the personal-setup build system.

## Overview

Each package MUST be defined in a `package.yaml` file located in its own subdirectory under `packages/`. The build system MUST process these files to download, build, and install software packages into a user environment.

## Template Variables

The following variables MAY be used in URL templates, file paths, and commands:

- `{version}`: Replaced with the package version
- `{pkg_dir}`: Replaced with the absolute path to the package directory
- `{out_dir}`: Replaced with the absolute path to the output directory
</context>

<schema>
<rules>

### Required Fields
The following fields are REQUIRED:

- `name` (string): MUST be the name of the package. REQUIRED.
- `version` (string): MUST be the version of the package to install. REQUIRED.
- `datasource` (string): The datasource for version updates (used by Renovate). REQUIRED. MUST be one of the following:
  - `github-releases`: For GitHub releases
  - `github-tags`: For GitHub tags
  - `git-refs`: For Git repositories
  - `custom.<name>`: Custom datasources (e.g., `custom.unofficial_node`, `custom.jdk_lts`)
- `package` (string): MUST be the package identifier, typically the GitHub repository in `owner/repo` format. REQUIRED.
- `files` (list): MUST be a list of file mappings to install.
</rules>

### Conditionally Required Fields

The following fields are REQUIRED when certain condition is matched:

- `branch` (string): The tracking Git branch name. REQUIRED when the `datasource` field is `git-refs`.

### Optional Fields

The following fields MAY be included in a `package.yaml` file:

- `url` (string): If provided, MUST be the download URL template. The placeholder `{version}` SHOULD be used. Variants:
  - Git repository: `url` MUST end with `.git`. The Git repository will be downloaded.
  - Others: The file will be downloaded.
  - If `url` is not provided, the package will be recognized as a downloadless package.
- `extract` (boolean): Whether the downloaded file SHOULD be extracted. Defaults to `false` if not provided.
- `checksum_source` (string): Defines how to obtain checksums for verification. Defaults to `none` (skipping verification) if not provided. Options:
  - `github-release`: Use GitHub release checksums
  - `git-refs`: Use git commit hashes (for git repositories)
  - A URL template for checksum files
  - Embedded 64 hex chars for sha256
  - `none`: Skip checksum verification
- `build_cmds` (list of strings): Commands to execute during the build process. Run in the package's workspace directory.
- `init_cmds` (list of strings): Commands to execute after installation. Run in the user's environment.
- `cache` (list of strings): Directory patterns to cache between builds.
- `subpackages` (object or list): Declares nested package managers for dependency installation. MAY be a single object or list of objects. Each object MUST include:
  - `manifest` (string): Path to package manifest file (e.g., `package.json`, `requirements.txt`) or `inline` for inline package declarations
  - `manifest_type` (string): Type of package manager. Valid values: `npm`, `lua`, `inline`
  - `test_defaults` (object): Default test configuration for all packages in this manifest. MAY include `type` field (e.g., `version-check`, `nvim-plugin`)
  - `packages` (list): For `inline` manifests, this list defines the subpackages. For other manifest types, this provides configuration overrides for auto-discovered packages. Each object MUST include `name` and MAY include `bin` (executable name) and `test` (test configuration override).
- `test` (object): Test configuration for package verification. MUST include:
  - `type` (string): Test type. Valid values: `cmd`, `lsp-stdio`, `version-check`, `nvim-plugin`
  - `cmd` (string): Command to execute. REQUIRED when `type` is `cmd`
- `versioning` (string): Versioning scheme for Renovate (default: `semver`).
<format>
### File Mappings

Each item in the `files` list MUST be a dictionary with the following fields:

- `src` (string): Source path. REQUIRED. Valid values include:
  - A path within the extracted archive
  - A URL to download
  - A local path (MUST start with `{pkg_dir}` for downloadless packages)
- `dst` (string): Destination path relative to the user's home directory (typically starts with `.local/`). REQUIRED.
</format>
</schema>

<examples>

## Package Types

### Archive Packages
For packages distributed as archives (`tar.gz`, `zip`, etc.):

<example>
<input>Archive Packages</input>
<output>

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
</output>
</example>

### Git Packages
For packages built from git repositories:

<example>
<input>Git Packages</input>
<output>

```yaml
name: example
version: 0123456789abcdef0123456789abcdef01234567
datasource: git-refs
branch: master
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
</output>
</example>

### Single File Packages
For packages that are single executable files:

<example>
<input>Single File Packages</input>
<output>

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
</output>
</example>

### Downloadless Packages
For packages that only copy local files or download from URLs:

<example>
<input>Downloadless Packages</input>
<output>

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
</output>
</example>

### Package Testing
For packages with test configurations:

<example>
<input>Package with Command Test</input>
<output>

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
test:
  type: cmd
  cmd: example --version
```
</output>
</example>

<example>
<input>Package with LSP Test</input>
<output>

```yaml
name: example-lsp
version: 1.0.0
datasource: github-releases
package: owner/lsp-server
url: https://github.com/owner/lsp-server/releases/download/v{version}/lsp-server
extract: false
files:
  - src: lsp-server
    dst: .local/bin/lsp-server
test:
  type: lsp-stdio
```
</output>
</example>

<example>
<input>Package with NPM Subpackages</input>
<output>

```yaml
name: node
version: 20.0.0
datasource: github-releases
package: nodejs/node
url: https://nodejs.org/dist/v{version}/node-v{version}-linux-x64.tar.gz
extract: true
files:
  - src: node-v{version}-linux-x64/bin/node
    dst: .local/bin/node
  - src: node-v{version}-linux-x64/bin/npm
    dst: .local/bin/npm
subpackages:
  manifest: src/path/to/package.json
  manifest_type: npm
  test_defaults:
    type: version-check
  packages:
    - name: typescript
      bin: tsc
      test:
        type: lsp-stdio
```
</output>
</example>

<example>
<input>Package with Inline Subpackages</input>
<output>

```yaml
name: python
version: 3.11.0
datasource: github-releases
package: python/cpython
url: https://www.python.org/ftp/python/{version}/Python-{version}.tar.xz
extract: true
build_cmds:
  - ./configure --prefix={out_dir}
  - make
  - make install
files:
  - src: bin/python3
    dst: .local/bin/python3
subpackages:
  manifest: inline
  manifest_type: inline
  test_defaults:
    type: version-check
  packages:
    - name: requests
    - name: flask
      bin: flask
```
</output>
</example>
</examples>

<reference>

## Examples

See the existing packages in @packages for real-world examples of different package types.
</reference>
