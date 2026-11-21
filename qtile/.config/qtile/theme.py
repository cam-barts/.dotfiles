"""Design tokens for the qtile session.

Observatory leads (desktop chrome); Night Market supplies the semantic colours
(urgent / warning / ok / info). Names follow the design docs in SilverBullet:
  - Projects/SilverBullet Observatory Refresh
  - AI Generated/Barbossa/SilverBullet Tooling/Design System Analysis
mako and swaylock can't import Python, so derived.py renders their configs from these
tokens whenever qtile loads its config.
"""

# --- Observatory surfaces ---------------------------------------------------
CANVAS = "#07090d"
BASE = "#0d0e14"
PANEL = "#1f2335"
RAISED = "#292e42"
HAIR = "#2a2e42"
HAIR2 = "#3b4261"

# --- Observatory text -------------------------------------------------------
TXT = "#c0caf5"
LABEL = "#aeb7e0"  # bar labels
MUTED = "#9aa5ce"
FAINT = "#565f89"

# --- Accent -----------------------------------------------------------------
ORANGE = "#ffaa00"  # the single focal accent
SORANGE = "#ff9e64"

# --- Night Market semantics -------------------------------------------------
MAGENTA = "#ff0d8a"  # urgent / error / critical
AMBER = "#ffaa00"  # warning / low
GREEN = "#23d188"  # ok
CYAN = "#28b8db"  # info / navigation
PURPLE = "#5D4FBA"

# --- Type -------------------------------------------------------------------
FONT = "Space Grotesk"
FONT_BOLD = "Space Grotesk Bold"
MONO = "Monaspace Argon"
FONTSIZE = 13

# --- Geometry (Night Market 8px base) ---------------------------------------
BORDER = 2
GAP = 8
BAR_HEIGHT = 26
BAR_BG = CANVAS + "e6"  # slightly translucent
RADIUS = 14  # notification corners

# --- Panels (notifications, lock screen) ------------------------------------
PANEL_ALPHA = "f2"  # mako background opacity
SCRIM_ALPHA = "cc"  # swaylock ring fill over the wallpaper

WALLPAPER_DIR = "~/Pictures/Wallpapers"
WALLPAPER_SMALL = "observatory-aurora-1366x768.png"  # laptop panel (eDP-1)
WALLPAPER_LARGE = "observatory-aurora-3840x2160.png"  # external monitors
