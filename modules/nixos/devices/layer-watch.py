# Pass-through layer watcher for kanata.
#
# Polls niri's IPC once a second. When the focused window's size is within
# TOL of its output's logical size (i.e. fullscreen), tells kanata to switch
# to the `nofs` pass-through layer; otherwise back to `main`.
#
# niri's IPC exposes no is_fullscreen field, so size equality is the signal:
# - fullscreen windows cover the output's logical size exactly (border off)
# - maximized tiles are smaller by 2x the 10px gaps, so a 14px tolerance
#   cleanly separates fullscreen from maximized.

import glob
import json
import os
import socket
import subprocess
import time

PORT = 10051
TOL = 14
LAYERS = ("main", "nofs")


def niri_sock():
    socks = glob.glob(f"/run/user/{os.getuid()}/niri.wayland-*.sock")
    return max(socks, key=os.path.getmtime) if socks else None


def niri_json(sub):
    s = niri_sock()
    if not s:
        return None
    env = dict(os.environ, NIRI_SOCKET=s)
    try:
        r = subprocess.run(
            ["niri", "msg", "-j", sub],
            capture_output=True, text=True, timeout=5, env=env,
        )
    except Exception:
        return None
    if r.returncode != 0:
        return None
    try:
        return json.loads(r.stdout)
    except Exception:
        return None


def classify():
    w = niri_json("focused-window")
    if not isinstance(w, dict):
        return "main"
    lay = w.get("layout") or {}
    ws = lay.get("window_size") or []
    if len(ws) != 2:
        return "main"
    o = niri_json("focused-output")
    if not isinstance(o, dict):
        return "main"
    lg = o.get("logical") or {}
    ow, oh = lg.get("width"), lg.get("height")
    if not ow or not oh:
        return "main"
    fw, fh = ws
    return "nofs" if fw >= ow - TOL and fh >= oh - TOL else "main"


def switch(layer):
    # ChangeLayer draws no reply from kanata — fire and forget.
    try:
        with socket.create_connection(("127.0.0.1", PORT), timeout=2) as c:
            c.sendall(json.dumps({"ChangeLayer": {"new": layer}}).encode() + b"\n")
    except OSError as e:
        print(f"switch to {layer} failed: {e}", flush=True)


def main():
    last = None
    while True:
        cur = classify()
        if cur in LAYERS and cur != last:
            switch(cur)
            print(f"layer -> {cur}", flush=True)
            last = cur
        time.sleep(1)


main()
