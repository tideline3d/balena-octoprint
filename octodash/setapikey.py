#!/usr/bin/env python

import json
import os

with open('/root/.config/octodash/config.json', 'r+') as f:
    json_data = json.load(f)
    json_data["config"]["octoprint"]["accessToken"] = os.environ["OCTOPRINT_APIKEY"]
    f.seek(0)
    f.write(json.dumps(json_data, indent=4))
    f.truncate()
