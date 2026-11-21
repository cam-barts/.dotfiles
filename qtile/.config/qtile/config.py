"""qtile (Wayland) config for scrapulance.

Keymap (see SilverBullet: Inbox/Revisit QTile With Claude Access -> Keymap):
  Alt         directional navigation (hjkl), cycle/close/fullscreen, mouse
  Super       launchers, groups, session; Super+l = lock
  Super+Ctrl  window grid on the left-hand 3x3 block (q w e / a s d / z x c)
"""

from __future__ import annotations

import math
import os
import subprocess
import time
from pathlib import Path
from typing import TYPE_CHECKING, ClassVar

from libqtile import bar, hook, layout, qtile, widget
from libqtile.backend.wayland import InputConfig
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.widget.battery import BatteryState
from libqtile.widget.wlan import get_status as wlan_status

import derived
import theme as t

if TYPE_CHECKING:
    from libqtile.backend.base.window import Window
    from libqtile.core.manager import Qtile
    from libqtile.widget.battery import BatteryStatus

ALT = "mod1"
SUPER = "mod4"
CTRL = "control"
SHIFT = "shift"

HERE = Path(__file__).resolve().parent
TERM = "kitty"
JOURNAL_CLASS = "floating-journal"
VOL_UP = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
VOL_DOWN = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
KEYMAP_FILE = (
    Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
    / "qtile"
    / "keymap.txt"
)
KEYMAP_THEME = 'window { width: 720px; } element-text { font: "Monaspace Argon 11"; }'


# --- helpers ----------------------------------------------------------------
@lazy.function
def place(qtile: Qtile, fx: float, fy: float, fw: float, fh: float) -> None:
    """Float the focused window into a fraction of the screen's usable area."""
    win = qtile.current_window
    if win is None:
        return
    s = qtile.current_screen
    g, b = t.GAP, win.borderwidth
    x0 = s.dx + round(s.dwidth * fx)
    y0 = s.dy + round(s.dheight * fy)
    x1 = s.dx + round(s.dwidth * (fx + fw))
    y1 = s.dy + round(s.dheight * (fy + fh))
    # full gap at screen edges, half gap between neighbouring regions
    gl = g if fx == 0 else g // 2
    gt = g if fy == 0 else g // 2
    gr = g if fx + fw >= 1 else g // 2
    gb = g if fy + fh >= 1 else g // 2
    win.enable_floating()
    win.set_position_floating(x0 + gl, y0 + gt)
    win.set_size_floating(x1 - x0 - gl - gr - 2 * b, y1 - y0 - gt - gb - 2 * b)
    win.bring_to_front()


@lazy.function
def to_adjacent_screen(qtile: Qtile, delta: int) -> None:
    """Send the focused window to the monitor left (-1) or right (+1)."""
    win = qtile.current_window
    screens = sorted(qtile.screens, key=lambda s: (s.x, s.y))
    if win is None or len(screens) <= 1:
        return
    i = screens.index(qtile.current_screen)
    target = screens[(i + delta) % len(screens)]
    win.togroup(target.group.name)
    qtile.focus_screen(target.index)


def _is_term(win: Window) -> bool:
    """Kitty windows, excluding the floating journal."""
    cls = win.get_wm_class() or []
    return "kitty" in cls and JOURNAL_CLASS not in cls


@lazy.function
def raise_or_launch_term(qtile: Qtile) -> None:
    """Focus an existing kitty (current group first), otherwise start one."""
    cur = qtile.current_group
    candidates = [w for w in cur.windows if _is_term(w)]
    if not candidates:
        candidates = [w for g in qtile.groups for w in g.windows if _is_term(w)]
    if not candidates:
        qtile.spawn(TERM)
        return
    win = candidates[0]
    if win.group is not cur:
        win.group.toscreen()
    win.group.focus(win)
    win.bring_to_front()


@lazy.function
def screenshot_window(qtile: Qtile) -> None:
    """Screenshot the focused window, borders included."""
    win = qtile.current_window
    if win is None:
        return
    b2 = 2 * win.borderwidth
    geom = f"{win.x},{win.y} {win.width + b2}x{win.height + b2}"
    qtile.spawn(["qtile-shot", "geom", geom])


# --- keys -------------------------------------------------------------------
keys = [
    # --- Alt does directional navigation
    Key([ALT], "h", lazy.layout.left(), desc="Focus left"),
    Key([ALT], "j", lazy.layout.down(), desc="Focus down"),
    Key([ALT], "k", lazy.layout.up(), desc="Focus up"),
    Key([ALT], "l", lazy.layout.right(), desc="Focus right"),
    Key(
        [ALT, SHIFT],
        "h",
        lazy.layout.shuffle_left(),
        lazy.layout.swap_left().when(layout="monadtall"),
        desc="Move left",
    ),
    Key([ALT, SHIFT], "j", lazy.layout.shuffle_down(), desc="Move down"),
    Key([ALT, SHIFT], "k", lazy.layout.shuffle_up(), desc="Move up"),
    Key(
        [ALT, SHIFT],
        "l",
        lazy.layout.shuffle_right(),
        lazy.layout.swap_right().when(layout="monadtall"),
        desc="Move right",
    ),
    Key(
        [ALT, CTRL],
        "h",
        lazy.layout.grow_left().when(layout="columns"),
        lazy.layout.shrink_main().when(layout="monadtall"),
        desc="Grow left",
    ),
    Key(
        [ALT, CTRL],
        "l",
        lazy.layout.grow_right().when(layout="columns"),
        lazy.layout.grow_main().when(layout="monadtall"),
        desc="Grow right",
    ),
    Key(
        [ALT, CTRL],
        "j",
        lazy.layout.grow_down().when(layout="columns"),
        lazy.layout.shrink().when(layout="monadtall"),
        desc="Grow down",
    ),
    Key(
        [ALT, CTRL],
        "k",
        lazy.layout.grow_up().when(layout="columns"),
        lazy.layout.grow().when(layout="monadtall"),
        desc="Grow up",
    ),
    Key([ALT], "Tab", lazy.group.next_window(), desc="Cycle windows"),
    Key([ALT, SHIFT], "Tab", lazy.group.prev_window(), desc="Cycle windows back"),
    Key([ALT], "F4", lazy.window.kill(), desc="Close window"),
    Key([ALT], "F11", lazy.window.toggle_fullscreen(), desc="Fullscreen"),
    # --- Super launches things
    Key([SUPER], "l", lazy.spawn("swaylock -f"), desc="Lock"),
    Key([SUPER], "Return", raise_or_launch_term(), desc="Raise or launch kitty"),
    Key([SUPER, SHIFT], "Return", lazy.spawn(TERM), desc="New kitty"),
    Key([SUPER], "space", lazy.spawn("rofi -show combi"), desc="Launcher"),
    Key([SUPER], "r", lazy.spawn("rofi -show combi"), desc="Launcher"),
    Key([SUPER], "b", lazy.spawn("rofi_bookmarks.sh"), desc="Bookmarks"),
    Key([SUPER], "j", lazy.spawn("rofi-journal"), desc="Journal: one line"),
    Key(
        [SUPER, SHIFT],
        "j",
        lazy.spawn(
            f"kitty --class {JOURNAL_CLASS} -e env EDITOR=nvim sb daily --sign @cam"
        ),
        desc="Journal: today's note",
    ),
    Key([SUPER], "Tab", lazy.next_layout(), desc="Next layout"),
    Key([SUPER], "f", lazy.window.toggle_floating(), desc="Toggle floating"),
    Key([SUPER], "n", lazy.layout.normalize(), desc="Reset sizes"),
    Key([SUPER], "p", lazy.spawn("wdisplays"), desc="Display settings"),
    Key(
        [SUPER],
        "slash",
        lazy.spawn(
            [
                "rofi",
                "-dmenu",
                "-i",
                "-p",
                "keys",
                "-input",
                str(KEYMAP_FILE),
                "-theme-str",
                KEYMAP_THEME,
            ]
        ),
        desc="Show this keymap",
    ),
    Key([SUPER, CTRL], "r", lazy.reload_config(), desc="Reload config"),
    Key([SUPER, SHIFT], "Delete", lazy.shutdown(), desc="Log out"),
    # --- Super+Ctrl is the window grid
    Key([SUPER, CTRL], "q", place(0, 0, 0.5, 0.5), desc="Top-left"),
    Key([SUPER, CTRL], "w", place(0, 0, 1, 0.5), desc="Top half"),
    Key([SUPER, CTRL], "e", place(0.5, 0, 0.5, 0.5), desc="Top-right"),
    Key([SUPER, CTRL], "a", place(0, 0, 0.5, 1), desc="Left half"),
    Key([SUPER, CTRL], "s", lazy.window.toggle_maximize(), desc="Maximize"),
    Key([SUPER, CTRL], "d", place(0.5, 0, 0.5, 1), desc="Right half"),
    Key([SUPER, CTRL], "z", place(0, 0.5, 0.5, 0.5), desc="Bottom-left"),
    Key([SUPER, CTRL], "x", place(0, 0.5, 1, 0.5), desc="Bottom half"),
    Key([SUPER, CTRL], "c", place(0.5, 0.5, 0.5, 0.5), desc="Bottom-right"),
    Key([SUPER, CTRL], "Left", to_adjacent_screen(-1), desc="Window to left monitor"),
    Key([SUPER, CTRL], "Right", to_adjacent_screen(1), desc="Window to right monitor"),
    # Kept from XFCE
    Key([CTRL, ALT], "t", lazy.spawn(TERM), desc="Terminal"),
    Key([CTRL, SHIFT], "Escape", lazy.spawn(f"{TERM} -e btm"), desc="Task manager"),
    # Screenshots
    Key([], "Print", lazy.spawn("qtile-shot full"), desc="Screenshot"),
    Key([SHIFT], "Print", lazy.spawn("qtile-shot region"), desc="Screenshot region"),
    Key([ALT], "Print", screenshot_window(), desc="Screenshot window"),
    # Laptop keys
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn(VOL_UP),
        desc="Volume up",
    ),
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn(VOL_DOWN),
        desc="Volume down",
    ),
    Key(
        [],
        "XF86AudioMute",
        lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
        desc="Mute",
    ),
    Key(
        [],
        "XF86AudioMicMute",
        lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
        desc="Mute microphone",
    ),
    Key(
        [],
        "XF86MonBrightnessUp",
        lazy.spawn("brightnessctl -q set 5%+"),
        desc="Brightness up",
    ),
    Key(
        [],
        "XF86MonBrightnessDown",
        lazy.spawn("brightnessctl -q -n1 set 5%-"),
        desc="Brightness down",
    ),
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc="Play/pause"),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next"), desc="Next track"),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous"), desc="Previous track"),
    Key([], "XF86Display", lazy.spawn("wdisplays"), desc="Display settings"),
    Key([], "XF86Search", lazy.spawn("rofi -show combi"), desc="Launcher"),
]

# Ctrl+Alt+Fn switches VTs on Wayland (the TTY escape hatch).
keys.extend(
    Key([CTRL, ALT], f"f{vt}", lazy.core.change_vt(vt), desc=f"VT {vt}")
    for vt in range(1, 8)
)

groups = [Group(str(i)) for i in range(1, 4)]
for g in groups:
    keys += [
        Key([SUPER], g.name, lazy.group[g.name].toscreen(), desc=f"Group {g.name}"),
        Key(
            [SUPER, SHIFT],
            g.name,
            lazy.window.togroup(g.name),
            desc=f"Send to group {g.name}",
        ),
    ]

mouse = [
    Drag(
        [ALT],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [ALT], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([ALT], "Button2", lazy.window.bring_to_front()),
]


# --- Super+/ keymap ---------------------------------------------------------
MOD_NAMES = {SUPER: "Super", CTRL: "Ctrl", ALT: "Alt", SHIFT: "Shift"}
KEY_NAMES = {
    "Return": "Enter",
    "space": "Space",
    "slash": "/",
    "Escape": "Esc",
    "Print": "PrtSc",
}
# Bindings generated per group / VT, shown as one summary row each instead.
COLLAPSED_PREFIXES = ("Group ", "Send to group ", "VT ")
SUMMARY_ROWS = [
    ("Super+1-3", "Go to group"),
    ("Super+Shift+1-3", "Send window to group"),
    ("Ctrl+Alt+F1-F7", "Switch to VT (text console)"),
    ("Alt+drag", "Move floating window"),
    ("Alt+right-drag", "Resize floating window"),
]


def chord(modifiers: list[str], key: str) -> str:
    """Render a binding as e.g. ``Super+Shift+Enter``."""
    mods = [MOD_NAMES.get(m, m) for m in MOD_NAMES if m in modifiers]
    name = KEY_NAMES.get(key, key.removeprefix("XF86"))
    return "+".join([*mods, name[:1].upper() + name[1:]])


def write_keymap(bindings: list[Key]) -> None:
    """Write the Super+/ cheat sheet, generated from the live key list."""
    rows = [
        (chord(k.modifiers, k.key), k.desc)
        for k in bindings
        if k.desc and not k.desc.startswith(COLLAPSED_PREFIXES)
    ]
    rows += SUMMARY_ROWS
    width = max(len(c) for c, _ in rows)
    KEYMAP_FILE.parent.mkdir(parents=True, exist_ok=True)
    KEYMAP_FILE.write_text("".join(f"{c:<{width}}  {d}\n" for c, d in rows))


write_keymap(keys)
derived.write_all()  # mako + swaylock configs from theme.py


# --- layouts ----------------------------------------------------------------
_borders = {
    "border_focus": t.ORANGE,
    "border_normal": t.HAIR2,
    "border_width": t.BORDER,
}
layouts = [
    layout.MonadTall(margin=t.GAP, single_border_width=t.BORDER, **_borders),
    layout.Columns(
        margin=t.GAP,
        border_on_single=True,
        border_focus_stack=t.ORANGE,
        border_normal_stack=t.HAIR2,
        **_borders,
    ),
    layout.Max(margin=t.GAP, **_borders),
]

floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class=JOURNAL_CLASS),
        Match(wm_class="pinentry-qt"),
        Match(
            wm_class="org.keepassxc.KeePassXC",
            title="KeePassXC - Browser Access Request",
        ),
        Match(wm_class="blueman-manager"),
        Match(wm_class="nm-connection-editor"),
        Match(wm_class="wdisplays"),
        Match(wm_class="lxqt-policykit-agent"),
        Match(title="Picture-in-Picture"),
    ],
    **_borders,
)


# --- bar --------------------------------------------------------------------
widget_defaults = {
    "font": t.FONT,
    "fontsize": t.FONTSIZE,
    "foreground": t.LABEL,
    "padding": 6,
}
extension_defaults = widget_defaults.copy()


def num(text: str) -> str:
    """Set a number in the mono face (labels stay Space Grotesk), as Pango markup."""
    return f"<span font_family='{t.MONO}'>{text}</span>"


def sep() -> widget.TextBox:
    """Faint middle-dot separator."""
    return widget.TextBox("·", foreground=t.FAINT, padding=2)


def volume() -> str:
    """Default sink volume for the bar, via wpctl."""
    try:
        out = subprocess.run(
            ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"],
            capture_output=True,
            text=True,
            timeout=1,
            check=True,
        ).stdout
        # wpctl prints the volume as a 0..1 fraction, plus a MUTED tag when muted
        vol = round(float(out.split()[1]) * 100)
    except (OSError, subprocess.SubprocessError, ValueError, IndexError):
        return "vol ?"
    else:
        return "muted" if "MUTED" in out else f"vol {num(f'{vol}%')}"


class TriBattery(widget.Battery):
    """Battery coloured by state: green normal, amber low, magenta critical."""

    _tri_defaults: ClassVar[list[tuple[str, object, str]]] = [
        ("critical_percentage", 0.1, "Below this, discharging, use critical colour"),
        ("critical_foreground", t.MAGENTA, "Font colour on critical battery"),
    ]

    def __init__(self, **config: object) -> None:
        """Add the critical-level options on top of Battery's."""
        super().__init__(**config)
        self.add_defaults(TriBattery._tri_defaults)

    def build_string(self, status: BatteryStatus) -> str:
        """Build the text, then recolour it when critically low."""
        text = super().build_string(status)
        critical = (
            status.state == BatteryState.DISCHARGING
            and status.percent < self.critical_percentage
        )
        if self.layout is not None and critical:
            self.layout.colour = self.critical_foreground
        return text


WIFI_BARS = "▂▄▆█"
WIFI_MAX_QUALITY = 70  # iwlib link quality scale


def signal_bars(fraction: float) -> str:
    """Render 0..1 signal as four bars, unfilled ones faint (Pango markup)."""
    filled = min(len(WIFI_BARS), max(1, math.ceil(fraction * len(WIFI_BARS))))
    lit, dim = WIFI_BARS[:filled], WIFI_BARS[filled:]
    return lit + (f'<span foreground="{t.FAINT}">{dim}</span>' if dim else "")


class WifiBars(widget.Wlan):
    """Wi-Fi signal strength as bars instead of the network name."""

    def poll(self) -> str:
        """Return the bars, or the disconnected message."""
        try:
            essid, quality = wlan_status(self.interface)
        except OSError:
            return self.disconnected_message
        if essid is None:
            return self.disconnected_message
        return signal_bars((quality or 0) / WIFI_MAX_QUALITY)


def make_bar() -> bar.Bar:
    """Build the top bar."""
    return bar.Bar(
        [
            widget.GroupBox(
                font=t.MONO,
                highlight_method="text",
                this_current_screen_border=t.ORANGE,
                this_screen_border=t.ORANGE,
                other_current_screen_border=t.SORANGE,
                other_screen_border=t.MUTED,
                active=t.MUTED,
                inactive=t.FAINT,
                urgent_alert_method="text",
                urgent_text=t.MAGENTA,
                disable_drag=True,
                padding=4,
            ),
            widget.CurrentLayout(foreground=t.FAINT, mode="text"),
            sep(),
            widget.WindowName(
                foreground=t.MUTED, max_chars=80, empty_group_string="", format="{name}"
            ),
            widget.StatusNotifier(icon_size=16, padding=4, icon_theme="breeze-dark"),
            sep(),
            WifiBars(
                interface="wlp1s0",
                font=t.MONO,
                disconnected_message="offline",
                foreground=t.CYAN,
                update_interval=5,
            ),
            sep(),
            widget.GenPollText(
                func=volume,
                update_interval=1,
                name="vol",
                mouse_callbacks={
                    "Button1": lazy.spawn("rofi-level volume"),
                    "Button3": lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
                    "Button4": lazy.spawn(VOL_UP),
                    "Button5": lazy.spawn(VOL_DOWN),
                },
            ),
            sep(),
            widget.Backlight(
                backlight_name="intel_backlight",
                format=f"bri {num('{percent:2.0%}')}",
                change_command="brightnessctl -q set {0:.0f}%",
                step=5,
                min_brightness=1,
                mouse_callbacks={"Button1": lazy.spawn("rofi-level brightness")},
            ),
            sep(),
            TriBattery(
                font=t.MONO,
                format="{char}{percent:2.0%}",
                charge_char="+",
                discharge_char="",
                full_char="",
                unknown_char="",
                empty_char="!",
                not_charging_char="",
                foreground=t.GREEN,
                low_foreground=t.AMBER,
                low_percentage=0.2,
                notify_below=10,
                update_interval=30,
            ),
            sep(),
            widget.Clock(font=t.MONO, format="%a %d %b  %H:%M", foreground=t.TXT),
        ],
        t.BAR_HEIGHT,
        background=t.BAR_BG,
        border_width=[0, 0, 1, 0],
        border_color=t.HAIR,
    )


screens = [Screen(top=make_bar())]


# --- Wayland ----------------------------------------------------------------
wl_input_rules = {
    "type:touchpad": InputConfig(
        tap=True,
        natural_scroll=True,
        dwt=True,
        middle_emulation=True,
    ),
    "type:keyboard": InputConfig(kb_repeat_rate=30, kb_repeat_delay=300),
}
wl_xcursor_theme = "breeze_cursors"
wl_xcursor_size = 24


# --- behaviour --------------------------------------------------------------
dgroups_key_binder = None
dgroups_app_rules: list = []
follow_mouse_focus = True
bring_front_click = "floating_only"
floats_kept_above = True
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wmname = "qtile"


# Apps that remember their last state (kitty, browsers) reopen maximized, which
# qtile treats as a full-screen float, so each new window stacks invisibly on top
# of the last. Their maximize request arrives just after the window is managed,
# so remember new windows briefly and tile any that turn maximized in that time.
# Maximizing later (Super+Ctrl+s, a title-bar double-click) still works.
RESTORE_GRACE_S = 3.0
_new_windows: dict[int, float] = {}


@hook.subscribe.client_managed
def _track_new_window(win: Window) -> None:
    """Note when a window appeared; tile it if it's already maximized."""
    _new_windows[win.wid] = time.monotonic()
    if win.maximized:
        win.disable_floating()


@hook.subscribe.float_change
def _tile_restored_maximized() -> None:
    """Tile windows that went maximized within the grace period after opening."""
    now = time.monotonic()
    for wid, opened in list(_new_windows.items()):
        win = qtile.windows_map.get(wid)
        if win is None or now - opened > RESTORE_GRACE_S:
            del _new_windows[wid]
        elif getattr(win, "maximized", False):
            del _new_windows[wid]
            win.disable_floating()


@hook.subscribe.startup_once
def autostart() -> None:
    """Start session services once per login (see autostart.sh)."""
    if os.environ.get("QTILE_NO_AUTOSTART"):  # nested test runs
        return
    subprocess.Popen([str(HERE / "autostart.sh")])
