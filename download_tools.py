#!/usr/bin/env python3
"""
Universal File Converter - Tool Downloader

This script downloads the required external tools (FFmpeg, Pandoc, LibreOffice) 
and sets them up in the portable_tools directory for packaging.
"""

import os
import sys
import platform
import argparse
from pathlib import Path

# Add src directory to path to import the tool_downloader module
sys.path.insert(0, str(Path(__file__).parent / 'src'))

# Try to import required modules, installing them if necessary
try:
    import requests
    import tqdm
except ImportError:
    print("Installing required packages...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "tqdm"])
    import requests
    import tqdm

# Import the tool downloader module
try:
    from utils.tool_downloader import (download_and_setup_tool, 
                                      check_for_updates, 
                                      get_installed_version,
                                      download_all_tools)
except ImportError:
    print("Error: Could not import tool_downloader module.")
    print("Please ensure you're running this script from the project root directory.")
    sys.exit(1)

def progress_callback(tool_name, stage, percentage):
    """Display progress information."""
    print(f"\r{tool_name}: {stage.capitalize()} - {percentage}%", end="")
    if percentage >= 100:
        print()  # Add newline when complete

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Download and set up converter tools")
    parser.add_argument("--tool", choices=["ffmpeg", "pandoc", "libreoffice", "all"],
                       default="all", help="Tool to download (default: all)")
    parser.add_argument("--check-updates", action="store_true", 
                       help="Check for available updates")
    parser.add_argument("--force", action="store_true",
                       help="Force download even if tools are already installed")
    
    args = parser.parse_args()
    
    print("Universal File Converter - Tool Downloader")
    print("==========================================")
    
    # Check for updates
    if args.check_updates:
        print("\nChecking for updates...")
        updates = check_for_updates()
        
        for tool, info in updates.items():
            if info["installed"]:
                status = f"v{info['installed']} → v{info['latest']}" if info["update_available"] else "Up to date"
            else:
                status = "Not installed"
            print(f"{tool.capitalize()}: {status}")
        
        # If no tools need updating and not forcing, exit
        if not args.force and not any(info["update_available"] for info in updates.values() if info["installed"]):
            print("\nAll tools are up to date.")
            return
    
    # Download tools
    if args.tool == "all":
        print("\nDownloading all tools...")
        for tool in ["ffmpeg", "pandoc", "libreoffice"]:
            # Skip download if already installed and not forcing
            if not args.force and get_installed_version(tool) is not None:
                print(f"\n{tool.capitalize()}: Already installed, skipping. Use --force to reinstall.")
                continue
                
            print(f"\nDownloading {tool.capitalize()}...")
            success = download_and_setup_tool(
                tool,
                lambda stage, percentage: progress_callback(tool, stage, percentage)
            )
            
            if success:
                print(f"{tool.capitalize()}: Successfully downloaded and installed.")
            else:
                print(f"{tool.capitalize()}: Download or installation failed.")
    else:
        # Download specific tool
        tool = args.tool
        
        # Skip download if already installed and not forcing
        if not args.force and get_installed_version(tool) is not None:
            print(f"\n{tool.capitalize()}: Already installed, skipping. Use --force to reinstall.")
            return
            
        print(f"\nDownloading {tool.capitalize()}...")
        success = download_and_setup_tool(
            tool,
            lambda stage, percentage: progress_callback(tool, stage, percentage)
        )
        
        if success:
            print(f"{tool.capitalize()}: Successfully downloaded and installed.")
        else:
            print(f"{tool.capitalize()}: Download or installation failed.")
    
    print("\nAll operations completed.")

if __name__ == "__main__":
    main()