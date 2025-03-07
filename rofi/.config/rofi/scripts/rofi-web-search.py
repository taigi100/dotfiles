#!/usr/bin/env python3

import html
import json
import os
import subprocess as sp
import sys
import urllib.parse

################################################################################
#####                      C O N F I G U R A T I O N                      ######
################################################################################
BROWSER = "firefox"
DEFAULT_SEARCH = "kagi"
################################################################################

CONFIG = {
    "BROWSER_PATH": ["firefox"],
    "SEARCH_URL": "https://kagi.com/search?q=",
    "BANGS": {
        "k": "https://kagi.com/search?q=",
        "chat": "https://kagi.com/assistant?q=",
        # Add more bangs here in the format:
        # 'bang': 'url'
    },
}


def handle_bang(search_string):
    parts = search_string.split(None, 1)
    if len(parts) < 2:
        return None

    bang = parts[0][1:]  # Remove the ! from the beginning
    query = parts[1]

    if bang in CONFIG["BANGS"]:
        return CONFIG["BANGS"][bang] + urllib.parse.quote_plus(query)
    return None


def main():
    search_string = html.unescape((" ".join(sys.argv[1:])).strip())

    if search_string == "":
        print("Type something to search")
    else:
        if search_string.startswith("!"):
            url = handle_bang(search_string)
            if url is None:
                url = CONFIG["SEARCH_URL"] + urllib.parse.quote_plus(search_string)
        else:
            url = CONFIG["SEARCH_URL"] + urllib.parse.quote_plus(search_string)

        sp.Popen(
            CONFIG["BROWSER_PATH"] + [url],
            stdout=sp.DEVNULL,
            stderr=sp.DEVNULL,
            shell=False,
        )


if __name__ == "__main__":
    try:
        fname = os.path.expanduser("~/.config/rofi-web-search/config.json")
        if os.path.exists(fname):
            try:
                with open(fname, "r") as f:
                    config = json.loads(f.read())
                    if "BANGS" in config:
                        CONFIG["BANGS"].update(config["BANGS"])
            except json.JSONDecodeError:
                print(
                    "Configuration file %s is not a valid JSON" % fname, file=sys.stderr
                )
                sys.exit(1)
        else:
            os.makedirs(os.path.dirname(fname), exist_ok=True)
            with open(fname, "w") as f:
                json.dump({"BANGS": CONFIG["BANGS"]}, f, indent=4)
                f.write("\n")
        main()
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)
