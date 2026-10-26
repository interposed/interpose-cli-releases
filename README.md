# interpose-cli-releases

Public release binaries for the **interpose CLI** — the thin client for the
interposed governed-sandbox control plane. The CLI source is private; this repo
holds only the published binaries so the installer can fetch them with no auth.

## Install

```sh
curl -fsSL https://interposed.ai/cli | sh
```

Detects your OS/arch (Linux + macOS, amd64 + arm64), downloads the matching
binary from the latest release, verifies its checksum, and installs it. Or grab
a binary directly from the [Releases](../../releases) page.

## Usage

```sh
interpose login                  # authenticate (opens your browser)
interpose workspace ls           # your machines
interpose sandbox new <machine>  # start a governed session
```

Docs: https://interposed.ai/docs.html

## License

Distributed under the interpose CLI Binary Distribution License — see
[LICENSE](LICENSE). Free for personal, educational, non-commercial, and 90-day
internal evaluation; a commercial license is required for ongoing production or
multi-user commercial use. Questions: contact@interposed.ai
