import json
from os import execv
from shutil import which
import sys
from subprocess import run
from typing import Any


def main():
    ghostty_path = which("ghostty")

    if ghostty_path is None:
        sys.exit(1)

    def run_ghostty_default():
        print("Running ghostty with default settings")
        execv(ghostty_path, ["ghostty"] + sys.argv[1:])

    result = run(["hyprctl", "-j", "activeworkspace"], capture_output=True)

    if result.returncode != 0:
        run_ghostty_default()

    workspace = json.loads(result.stdout)
    monitor_id = workspace.get("monitorID", None)

    if monitor_id is None:
        run_ghostty_default()

    result = run(["hyprctl", "-j", "monitors"], capture_output=True)
    if result.returncode != 0:
        run_ghostty_default()

    monitors = json.loads(result.stdout)

    monitor: Any = None
    for monitor in monitors:
        if monitor.get("id", None) == monitor_id:
            break

    if monitor is None:
        run_ghostty_default()

    height = monitor.get("height", 1080)

    match height:
        case 2160:
            font_size = "18"
            font_size_small = "13.7"
        case 1440:
            font_size = "18.7"
            font_size_small = "14.2"
        case 1080 | _:
            font_size = "14"
            font_size_small = "8.7"

    print(f"font size {font_size}, monitor height {height}")
    execv(
        ghostty_path,
        [
            "ghostty",
            f"--font-size={font_size}",
            f"--keybind=ctrl+9=set_font_size:{font_size_small}",
        ]
        + sys.argv[1:],
    )


if __name__ == "__main__":
    main()
