#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
set -eu

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/hidpi-amber-desktop"
ORIGINALS="$STATE/originals"
SETTINGS="$STATE/settings"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
RESTORE_SETTINGS=true

usage() {
    echo "Usage: $0 [--keep-settings]" >&2
}

case "${1:-}" in
    "") ;;
    --keep-settings) RESTORE_SETTINGS=false ;;
    -h|--help) usage; exit 0 ;;
    *) usage; exit 2 ;;
esac

if [ ! -d "$STATE" ]; then
    echo "No installation state found at $STATE" >&2
    exit 1
fi

restore_path() {
    key=$1
    target=$2
    status="$ORIGINALS/$key.status"
    [ -e "$status" ] || return 0

    rm -rf -- "$target"
    if [ "$(cat "$status")" = present ]; then
        mkdir -p -- "$(dirname -- "$target")"
        cp -a -- "$ORIGINALS/$key" "$target"
    fi
}

gtk_root="$CONFIG_HOME/gtk-3.0/gtk.css"
if [ -e "$gtk_root" ]; then
    python3 - "$gtk_root" "$ORIGINALS/gtk-root-css.status" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
status = Path(sys.argv[2])
text = path.read_text()
pattern = re.compile(
    r"/\* hidpi-amber-desktop:start \*/\s*"
    r'@import url\("hidpi-amber\.css"\);\s*'
    r"/\* hidpi-amber-desktop:end \*/\s*",
    re.MULTILINE,
)
text = pattern.sub("", text).lstrip("\n")
if not text.strip() and status.exists() and status.read_text().strip() == "absent":
    path.unlink()
else:
    path.write_text(text)
PY
fi

restore_path theme-adwaita "$HOME/.themes/Adwaita-dark-amber"
restore_path theme-minimal "$HOME/.themes/Minimal-hdpi"
restore_path fcitx-theme "$DATA_HOME/fcitx5/themes/minimal-amber"
restore_path gtk-module "$CONFIG_HOME/gtk-3.0/hidpi-amber.css"
restore_path fcitx-qss "$CONFIG_HOME/fcitx5/amber-selection.qss"
restore_path fcitx-wrapper "$HOME/.local/bin/fcitx5-config-qt-amber"
restore_path desktop-fcitx-qt "$DATA_HOME/applications/org.fcitx.fcitx5-config-qt.desktop"
restore_path desktop-fcitx-tool "$DATA_HOME/applications/fcitx5-configtool.desktop"

restore_config() {
    key=$1
    target=$2
    status="$SETTINGS/$key.status"
    [ -e "$status" ] || return 0
    if [ "$(cat "$status")" = present ]; then
        mkdir -p "$(dirname "$target")"
        cp -a "$SETTINGS/$key" "$target"
    else
        rm -f "$target"
    fi
}

if [ "$RESTORE_SETTINGS" = true ]; then
    if command -v xfconf-query >/dev/null 2>&1; then
        if [ -s "$SETTINGS/gtk-theme" ]; then
            xfconf-query -c xsettings -p /Net/ThemeName \
                -s "$(cat "$SETTINGS/gtk-theme")"
        fi
        if [ -s "$SETTINGS/xfwm-theme" ]; then
            xfconf-query -c xfwm4 -p /general/theme \
                -s "$(cat "$SETTINGS/xfwm-theme")"
        fi
    fi
    restore_config fcitx-classic "$CONFIG_HOME/fcitx5/conf/classicui.conf"
    restore_config fcitx-global "$CONFIG_HOME/fcitx5/config"
fi

rm -rf -- "$STATE"

if command -v xfce4-panel >/dev/null 2>&1; then
    xfce4-panel -r || :
fi
if command -v fcitx5-remote >/dev/null 2>&1; then
    fcitx5-remote -r || :
fi

echo "Uninstalled HiDPI Amber Desktop assets."
if [ "$RESTORE_SETTINGS" = true ]; then
    echo "Previously captured settings were restored."
fi
