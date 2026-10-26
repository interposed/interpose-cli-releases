#!/bin/sh
# interpose CLI installer.
#
#   curl -fsSL https://interposed.ai/cli | sh        # once the script is hosted there
#
# The interpose-cli source repo is PRIVATE, so binaries are published to a
# separate PUBLIC releases repo that this script downloads from (no auth needed).
#
# Environment:
#   INTERPOSE_CLI_VERSION       version tag to install (default: latest)
#   INTERPOSE_CLI_INSTALL_DIR   install directory (default: ~/.local/bin; the client never needs root)
#   INTERPOSE_CLI_RELEASES_REPO override the public releases repo
set -eu

# Public releases repo (NOT the private source repo). Override to taste.
REPO="${INTERPOSE_CLI_RELEASES_REPO:-interposed/interpose-cli-releases}"
BIN="interpose"

err() { echo "install: $*" >&2; exit 1; }

# --- detect platform ---
os=$(uname -s)
case "$os" in
	Linux) os=linux ;;
	Darwin) os=darwin ;;
	*) err "unsupported OS '$os' (on Windows, download the .exe from the releases page)" ;;
esac

arch=$(uname -m)
case "$arch" in
	x86_64 | amd64) arch=amd64 ;;
	arm64 | aarch64) arch=arm64 ;;
	*) err "unsupported architecture '$arch'" ;;
esac

asset="${BIN}-${os}-${arch}"
ver="${INTERPOSE_CLI_VERSION:-latest}"
if [ "$ver" = "latest" ]; then
	url="https://github.com/${REPO}/releases/latest/download/${asset}"
else
	url="https://github.com/${REPO}/releases/download/${ver}/${asset}"
fi

# --- downloader ---
if command -v curl >/dev/null 2>&1; then
	dl() { curl -fsSL "$1" -o "$2"; }
elif command -v wget >/dev/null 2>&1; then
	dl() { wget -qO "$2" "$1"; }
else
	err "need curl or wget"
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "downloading ${asset} (${ver}) ..."
dl "$url" "$tmp/$BIN" || err "download failed: $url"
chmod +x "$tmp/$BIN"

# --- verify checksum when the release publishes one ---
sum_url="${url%/*}/checksums.txt"
if command -v sha256sum >/dev/null 2>&1 && dl "$sum_url" "$tmp/checksums.txt" 2>/dev/null; then
	want=$(grep " ${asset}$" "$tmp/checksums.txt" 2>/dev/null | awk '{print $1}' || true)
	if [ -n "${want:-}" ]; then
		got=$(sha256sum "$tmp/$BIN" | awk '{print $1}')
		[ "$want" = "$got" ] || err "checksum mismatch for ${asset}"
		echo "checksum ok"
	fi
fi

# --- install (user-writable by default; the client never needs root) ---
dir="${INTERPOSE_CLI_INSTALL_DIR:-$HOME/.local/bin}"
mkdir -p "$dir" || err "cannot create install dir $dir"
mv "$tmp/$BIN" "$dir/$BIN" || err "cannot write to $dir (set INTERPOSE_CLI_INSTALL_DIR to a writable dir)"

echo "installed ${BIN} -> ${dir}/${BIN}"
case ":$PATH:" in
	*":$dir:"*) ;;
	*) echo "note: ${dir} is not on your PATH yet - add it:"
	   echo "      export PATH=\"${dir}:\$PATH\"   # add to ~/.zshrc or ~/.bashrc, then restart your shell" ;;
esac
echo "next: interpose login"
