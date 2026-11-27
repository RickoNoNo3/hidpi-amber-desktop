# Migration guide

## Recommended method

On the destination machine:

```sh
git clone https://github.com/RickoNoNo3/hidpi-amber-desktop.git
cd hidpi-amber-desktop
./scripts/install.sh --apply
```

Log out and back in if an older session keeps cached GTK settings. GTK 3
applications normally need to be fully closed and reopened. The panel and
Fcitx are reloaded by the activation script when their commands are available.

## What is installed

```text
~/.themes/Adwaita-dark-amber/
~/.themes/Minimal-hdpi/
~/.local/share/fcitx5/themes/minimal-amber/
~/.config/gtk-3.0/hidpi-amber.css
~/.config/fcitx5/amber-selection.qss
~/.local/bin/fcitx5-config-qt-amber
~/.local/share/applications/org.fcitx.fcitx5-config-qt.desktop
~/.local/share/applications/fcitx5-configtool.desktop
```

The installer adds one marked `@import` block to
`~/.config/gtk-3.0/gtk.css`. It does not replace unrelated rules in that file.

## What is activated

`scripts/apply.sh`:

1. selects `Adwaita-dark-amber` through Xfce xsettings;
2. selects `Minimal-hdpi` through Xfwm4;
3. selects the `minimal-amber` Fcitx light and dark Classic UI theme;
4. disables Fcitx system-accent substitution;
5. disables client-side embedded preedit for consistent rendering;
6. reloads the panel and Fcitx when possible.

The previous values and Fcitx configuration files are captured before the
first activation.

## Manual activation

If automatic activation is unavailable:

1. In **Appearance**, select `Adwaita-dark-amber`.
2. In **Window Manager**, select `Minimal-hdpi`.
3. In **Panel → Items → Window Buttons**, enable **Show flat buttons**.
4. In **Fcitx Configuration → Addons → Classic User Interface**, select
   `Minimal Amber` for both light and dark themes.
5. Disable **Follow system accent color**.
6. Disable **Show preedit in application** if consistent preedit colors are
   preferred.

## Moving only the theme files

For a machine that already has custom user CSS and Fcitx settings, run:

```sh
./scripts/install.sh
```

Then activate only the desired components through their graphical settings
tools. The installed GTK import can be removed manually from
`~/.config/gtk-3.0/gtk.css` if the tasklist/menu fixes are not wanted.
