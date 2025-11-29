#!/usr/bin/env python3

# Written by Richard Kelsch (converted to Python)
# Copyright 2023-2025 Richard Kelsch
# Freely usable under the MIT License

import sys
import platform
import psutil  # Requires: pip install psutil

__version__ = '2.00'

def get_http_server():
    """Attempt to detect the running HTTP server (simplified version)"""
    # Note: This is a simplified approach compared to Perl's Sys::Info
    try:
        # Check common process names
        for proc in psutil.process_iter(['name']):
            name = proc.info['name'].lower()
            if 'apache' in name or 'httpd' in name:
                return 'Apache'
            elif 'nginx' in name:
                return 'Nginx'
            elif 'lighttpd' in name:
                return 'Lighttpd'
    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
        pass
    return None

def main():
    if len(sys.argv) > 1:
        # Print HTTP server info if available
        if httpd := get_http_server():
            print(f"HTTP Server is {httpd}")

        # Print OS information
        os_name = platform.system()
        if os_name == 'Linux':
            os_name = platform.linux_distribution()[0] if hasattr(platform, 'linux_distribution') else os_name
        print(f"\n OS:  {platform.platform()}")

        # Print CPU information
        cpu_info = f"{platform.processor()} ({psutil.cpu_count(logical=False)} cores, {psutil.cpu_count(logical=True)} logical)"
        print(f"CPU:  {cpu_info}\n")
    else:
        # Just print CPU count
        print(psutil.cpu_count(logical=True))

if __name__ == '__main__':
    main()
