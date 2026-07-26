#!/usr/bin/env bash

set -u

IMG="${1:-}"
SCHEME="scheme-fidelity"

if [ -z "$IMG" ] || [ ! -f "$IMG" ]; then
    echo "usage: apply-theme.sh <image>" >&2
    exit 1
fi

HIST=$(magick "$IMG" -resize 128x128 -colors 12 -depth 8 -format "%c" histogram:info:- 2>/dev/null)

read -r ACCENT DARK_HUE ACC2_HUE ACC2_SAT <<<"$(printf '%s\n' "$HIST" | python3 -c "
import sys, re, colorsys
cands = []
dark = None
for line in sys.stdin:
    m = re.search(r'(\d+):.*#([0-9A-Fa-f]{6})', line)
    if not m:
        continue
    count, hexc = int(m.group(1)), m.group(2)
    r, g, b = (int(hexc[i:i + 2], 16) / 255 for i in (0, 2, 4))
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    score = count * ((s * v) ** 2)
    cands.append((score, h, s, v, hexc))
    if v < 0.55 and s > 0.12:
        ds = count * (1 - v)
        if dark is None or ds > dark[0]:
            dark = (ds, h)
vivid = sorted((c for c in cands if c[2] >= 0.2 and c[3] >= 0.2), reverse=True)
pool = vivid or sorted(cands, reverse=True)
if not pool:
    sys.exit(1)
best = pool[0]
second = None
for c in pool[1:]:
    d = abs(c[1] - best[1])
    d = min(d, 1 - d)
    if d > 50 / 360 and c[0] > best[0] * 0.03:
        second = c
        break
print('#' + best[4],
      round(dark[1], 4) if dark else -1,
      round(second[1], 4) if second else -1,
      round(second[2], 3) if second else -1)
" 2>/dev/null)"

if [ -z "${ACCENT:-}" ]; then
    matugen image "$IMG" -t "$SCHEME" --source-color-index 0 >/dev/null 2>&1
    exit 0
fi

matugen color hex "$ACCENT" -t "$SCHEME" >/dev/null 2>&1

matugen color hex "$ACCENT" -t "$SCHEME" --dry-run --json hex 2>/dev/null | python3 -c "
import sys, json, re, colorsys, os

DARK_HUE = float('$DARK_HUE')
ACC2_HUE = float('$ACC2_HUE')
ACC2_SAT = float('$ACC2_SAT')
SURFACE_SAT = 0.40
SURFACE_TOKENS = ('background', 'surface', 'surface_dim', 'surface_bright',
                  'surface_container_lowest', 'surface_container_low',
                  'surface_container', 'surface_container_high',
                  'surface_container_highest', 'surface_variant')
FILES = ('~/.config/waybar/tokens/colors.css',
         '~/.config/hypr/hyprland/theme.lua',
         '~/.config/rofi/colors.rasi',
         '~/.config/hypr/hyprlock-colors.conf',
         '~/.config/gtk-3.0/gtk.css',
         '~/.config/gtk-4.0/gtk.css',
         '~/.config/eww/_colors.scss',
         '~/.config/kitty/kitty-theme.conf',
         '~/.config/swaync/tokens/variables.css',
         '~/.config/wlogout/colors.css',
         '~/.config/sddm/theme-colors.conf')

colors = json.load(sys.stdin)['colors']
mapping = {}

def retint(token, hue, sat):
    old = colors[token]['default']['color'].lstrip('#')
    r, g, b = (int(old[i:i + 2], 16) / 255 for i in (0, 2, 4))
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    nr, ng, nb = colorsys.hls_to_rgb(hue, l, sat)
    mapping[old.lower()] = '%02x%02x%02x' % (round(nr * 255), round(ng * 255), round(nb * 255))

if DARK_HUE >= 0:
    for tok in SURFACE_TOKENS:
        if tok in colors:
            retint(tok, DARK_HUE, SURFACE_SAT)

if ACC2_HUE >= 0:
    sat = max(0.35, min(0.85, ACC2_SAT))
    for tok in colors:
        if 'tertiary' in tok:
            retint(tok, ACC2_HUE, sat)

for path in FILES:
    path = os.path.expanduser(path)
    if not os.path.isfile(path):
        continue
    text = open(path).read()
    for old, new in mapping.items():
        text = re.sub(old, new, text, flags=re.IGNORECASE)
    open(path, 'w').write(text)
" 2>/dev/null

hyprctl reload >/dev/null 2>&1
pkill -SIGUSR2 -x waybar 2>/dev/null
pkill -SIGUSR1 -x kitty 2>/dev/null
eww reload >/dev/null 2>&1
swaync-client -rs >/dev/null 2>&1

AVATAR="$HOME/.config/hypr/avatar.png"
MARK="$HOME/.config/hypr/.avatar-auto"
if [ ! -f "$AVATAR" ] || [ -f "$MARK" ]; then
    initial=$(printf '%s' "${USER:0:1}" | tr '[:lower:]' '[:upper:]')
    magick -size 440x440 xc:"$ACCENT" \
        -gravity center -pointsize 250 -fill white -annotate +0+10 "$initial" \
        "$AVATAR" 2>/dev/null && touch "$MARK"
fi
