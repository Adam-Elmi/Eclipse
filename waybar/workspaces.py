#!/usr/bin/env python3
# ###################
# The bar's workspace buttons (custom/ws1 … ws5): at most five numbers. On workspace 1–5 they show
# 1 up to where you are; past 5, the last button shows the one you're on (on 7: 1 2 3 4 [7]).
# Waybar 0.15's own workspaces module can't do that, and its clicks fail with the Lua config.
#   workspaces.py show N    button N for Waybar: a line of JSON now and on every workspace change
#                           (empty text = hidden); it ends when the bar closes
#   workspaces.py click N   go to button N's workspace
# ###################
import itertools, json, os, socket, subprocess, sys

MAX = 5
HYPR = os.path.join(os.environ["XDG_RUNTIME_DIR"], "hypr", os.environ["HYPRLAND_INSTANCE_SIGNATURE"])


def current():
    s = socket.socket(socket.AF_UNIX)
    s.connect(os.path.join(HYPR, ".socket.sock"))
    s.sendall(b"j/activeworkspace")
    data = b""
    while chunk := s.recv(65536):
        data += chunk
    return max(json.loads(data)["id"], 1)  # a special workspace has a negative id


# the workspace button n stands for, or None when it's hidden
def workspace_of(n):
    cur = current()
    last = min(cur, MAX)
    if n < last:
        return n
    return cur if n == last else None


def show(n):
    events = socket.socket(socket.AF_UNIX)
    events.connect(os.path.join(HYPR, ".socket2.sock"))
    shown = None
    for line in itertools.chain(["workspace>>"], events.makefile()):
        if not line.startswith(("workspace>>", "focusedmon>>")):
            continue
        ws = workspace_of(n)
        state = {"text": "" if ws is None else str(ws), "class": "active" if ws == current() else ""}
        if state != shown:
            print(json.dumps(state), flush=True)
            shown = state


def click(n):
    ws = workspace_of(n)
    if ws is not None:
        subprocess.run(["hyprctl", "dispatch", f"hl.dsp.focus({{ workspace = {ws} }})"], stdout=subprocess.DEVNULL)


if __name__ == "__main__":
    {"show": show, "click": click}[sys.argv[1]](int(sys.argv[2]))
