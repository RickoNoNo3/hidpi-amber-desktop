#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
set -eu

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/hidpi-amber-desktop"
SETTINGS="$STATE/settings"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$SETTINGS"

capture_value() {
    name=$1
    channel=$2
    property=$3
    file="$SETTINGS/$name"
    if [ ! -e "$file" ] && command -v xfconf-query >/dev/null 2>&1; then
        xfconf-query -c "$channel" -p "$property" > "$file" 2>/dev/null || :
    fi
}

capture_file() {
    name=$1
    file=$2
    status="$SETTINGS/$name.status"
    [ -e "$status" ] && return 0
    if [ -e "$file" ]; then
        cp -a "$file" "$SETTINGS/$name"
        printf '%s\n' present > "$status"
    else
        printf '%s\n' absent > "$status"
    fi
}

capture_value gtk-theme xsettings /Net/ThemeName
capture_value xfwm-theme xfwm4 /general/theme

classic="$CONFIG_HOME/fcitx5/conf/classicui.conf"
global="$CONFIG_HOME/fcitx5/config"
capture_file fcitx-classic "$classic"
capture_file fcitx-global "$global"

if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xsettings -p /Net/ThemeName -s Adwaita-dark-amber
    xfconf-query -c xfwm4 -p /general/theme -s Minimal-hdpi
else
    echo "Warning: xfconf-query not found; GTK and Xfwm4 themes were not selected." >&2
fi

mkdir -p "$(dirname "$classic")"
python3 - "$classic" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
values = {
    "Theme": "minimal-amber",
    "DarkTheme": "minimal-amber",
    "UseDarkTheme": "True",
    "UseAccentColor": "False",
}
lines = path.read_text().splitlines() if path.exists() else []
seen = set()
out = []
for line in lines:
    stripped = line.strip()
    if "=" in line and not stripped.startswith("#"):
        key = line.split("=", 1)[0].strip()
        if key in values:
            out.append(f"{key}={values[key]}")
            seen.add(key)
            continue
    out.append(line)
for key, value in values.items():
    if key not in seen:
        out.append(f"{key}={value}")
path.write_text("\n".join(out) + "\n")
PY

mkdir -p "$(dirname "$global")"
python3 - "$global" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
lines = path.read_text().splitlines() if path.exists() else []
out = []
inside = False
found_section = False
found_key = False

for line in lines:
    stripped = line.strip()
    if stripped.startswith("[") and stripped.endswith("]"):
        if inside and not found_key:
            out.append("PreeditEnabledByDefault=False")
            found_key = True
        inside = stripped == "[Behavior]"
        found_section |= inside
    if inside and stripped.startswith("PreeditEnabledByDefault="):
        out.append("PreeditEnabledByDefault=False")
        found_key = True
    else:
        out.append(line)

if inside and not found_key:
    out.append("PreeditEnabledByDefault=False")
elif not found_section:
    if out and out[-1]:
        out.append("")
    out.extend(["[Behavior]", "PreeditEnabledByDefault=False"])

path.write_text("\n".join(out) + "\n")
PY

if command -v xfce4-panel >/dev/null 2>&1; then
    xfce4-panel -r || :
fi
if command -v fcitx5-remote >/dev/null 2>&1; then
    fcitx5-remote -r || :
fi

echo "Activated Adwaita-dark-amber, Minimal-hdpi, and Minimal Amber Fcitx."
echo "Restart already-running GTK 3 applications to reload user CSS."
