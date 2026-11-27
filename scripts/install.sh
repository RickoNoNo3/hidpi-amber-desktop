#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/hidpi-amber-desktop"
ORIGINALS="$STATE/originals"
APPLY=false

usage() {
    echo "Usage: $0 [--apply]" >&2
}

case "${1:-}" in
    "") ;;
    --apply) APPLY=true ;;
    -h|--help) usage; exit 0 ;;
    *) usage; exit 2 ;;
esac

mkdir -p "$ORIGINALS"

backup_once() {
    key=$1
    target=$2
    status="$ORIGINALS/$key.status"

    [ -e "$status" ] && return 0
    if [ -e "$target" ] || [ -L "$target" ]; then
        cp -a -- "$target" "$ORIGINALS/$key"
        printf '%s\n' present > "$status"
    else
        printf '%s\n' absent > "$status"
    fi
}

install_path() {
    key=$1
    source=$2
    target=$3

    backup_once "$key" "$target"
    rm -rf -- "$target"
    mkdir -p -- "$(dirname -- "$target")"
    cp -a -- "$source" "$target"
}

install_path theme-adwaita \
    "$ROOT/themes/Adwaita-dark-amber" \
    "$HOME/.themes/Adwaita-dark-amber"
install_path theme-minimal \
    "$ROOT/themes/Minimal-hdpi" \
    "$HOME/.themes/Minimal-hdpi"
install_path fcitx-theme \
    "$ROOT/fcitx5/themes/minimal-amber" \
    "${XDG_DATA_HOME:-$HOME/.local/share}/fcitx5/themes/minimal-amber"
install_path gtk-module \
    "$ROOT/config/gtk-3.0/hidpi-amber.css" \
    "${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/hidpi-amber.css"
install_path fcitx-qss \
    "$ROOT/config/fcitx5/amber-selection.qss" \
    "${XDG_CONFIG_HOME:-$HOME/.config}/fcitx5/amber-selection.qss"
install_path fcitx-wrapper \
    "$ROOT/bin/fcitx5-config-qt-amber" \
    "$HOME/.local/bin/fcitx5-config-qt-amber"
install_path desktop-fcitx-qt \
    "$ROOT/config/applications/org.fcitx.fcitx5-config-qt.desktop" \
    "${XDG_DATA_HOME:-$HOME/.local/share}/applications/org.fcitx.fcitx5-config-qt.desktop"
install_path desktop-fcitx-tool \
    "$ROOT/config/applications/fcitx5-configtool.desktop" \
    "${XDG_DATA_HOME:-$HOME/.local/share}/applications/fcitx5-configtool.desktop"

chmod +x "$HOME/.local/bin/fcitx5-config-qt-amber"

gtk_root="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/gtk.css"
backup_once gtk-root-css "$gtk_root"
mkdir -p "$(dirname "$gtk_root")"
python3 - "$gtk_root" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text() if path.exists() else ""
pattern = re.compile(
    r"/\* hidpi-amber-desktop:start \*/\s*"
    r'@import url\("hidpi-amber\.css"\);\s*'
    r"/\* hidpi-amber-desktop:end \*/\s*",
    re.MULTILINE,
)
text = pattern.sub("", text).lstrip("\n")
block = (
    "/* hidpi-amber-desktop:start */\n"
    '@import url("hidpi-amber.css");\n'
    "/* hidpi-amber-desktop:end */\n\n"
)
path.write_text(block + text)
PY

echo "Installed HiDPI Amber Desktop assets."
echo "Original files are recorded in: $ORIGINALS"

if [ "$APPLY" = true ]; then
    "$ROOT/scripts/apply.sh"
else
    echo "Run ./scripts/apply.sh to activate the installed themes."
fi
