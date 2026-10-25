# ###################
# The Eclipse palette: every color in the setup comes from here. Change a value, then run
# theme/generate.sh, which writes it in each tool's own format. Eclipse Night: near-black with a
# violet tint, a rose accent that runs into plum for gradients, and the terminal's 16 colors
# ###################

# surfaces, darkest to lightest
HEADER=0f0d14      # the bar, title areas: the darkest
BG=14121a          # windows, menus
PANEL=17151e       # side areas
SURFACE=1c1924     # raised things: popups, the launcher's box
LINE=2a2433        # borders
LINE_SOFT=211c29   # faint dividers

# text
INK=e8e2ee         # normal text
MUTED=a79fb5       # secondary text
FAINT=6c6479       # hints, inactive things

# the accent: rose, and plum where it runs into a gradient (rose → plum); then states
ACCENT=f06595
ACCENT_HOVER=ff7aa8
PLUM=9d4edd
SELECT=3a2148      # selected text: a dark plum
OK=69db7c
WARN=ffa94d
ERROR=ff6b8a

# fonts
FONT="IBM Plex Sans"
MONO="IBM Plex Mono"
FONT_SIZE=11

# the terminal's 16 colors: black red green yellow blue magenta cyan white, then the bright ones
ANSI=(2a2433 ff6b8a 8ce99a ffd480 82aaff f06595 7fdbca e8e2ee
      4a4157 ff8fa3 b2f2bb ffe3a3 a5c4ff ff9ec0 a3f0e1 ffffff)
