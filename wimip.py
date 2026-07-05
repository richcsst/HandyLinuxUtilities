#!/usr/bin/env python3
import os
import sys
import json
from urllib.request import urlopen
from urllib.error import URLError

# 1. Check if any environment variables starting with WHATISMYIP_ already exist
existing_vars = [key for key in os.environ if key.startswith("WHATISMYIP_")]

if existing_vars:
    sys.exit("WHATISMYIP variables already exist. Skipping API call.")

# 2. Check for the API key argument
if len(sys.argv) < 2:
    sys.exit("Missing key")

key = sys.argv[1]

try:
    # 3. Fetch the IP address
    wimip_url = f"https://wimi-api.whatismyip.com/ip?key={key}"
    with urlopen(wimip_url) as response:
        ip_data = json.loads(response.read().decode())
    
    # 4. Fetch the IP metadata lookup
    ip_address = ip_data.get("ip")
    wimip_info_url = f"https://wimi-api.whatismyip.com/ip-address-lookup/{ip_address}?key={key}"
    
    with urlopen(wimip_info_url) as response:
        ip_info = json.loads(response.read().decode())
        
    # 5. Print the export statements for the shell to evaluate
    for name, value in ip_info.items():
        print(f'export WHATISMYIP_{name.upper()}="{value}"')

except URLError as e:
    sys.exit(f"API request failed: {e}")
except (json.JSONDecodeError, KeyError) as e:
    sys.exit(f"Failed to parse API response: {e}")

