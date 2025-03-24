#!/usr/bin/env python3
# Simple album art fetcher using playerctl

import os
import sys
import subprocess
from PIL import Image

# Get the directory where this script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

def get_art_url_from_playerctl():
    """Get the album art URL from playerctl"""
    try:
        result = subprocess.run(
            ["playerctl", "metadata", "mpris:artUrl"], 
            capture_output=True, 
            text=True, 
            check=True
        )
        url = result.stdout.strip()
        return url if url else None
    except subprocess.CalledProcessError:
        print("Error: No media player is running or no metadata available")
        return None
    except Exception as e:
        print(f"Error getting metadata: {e}")
        return None

def save_image(file_path, output_path=None):
    """Process and save the album art"""
    # If no output path is provided, save in the script's directory
    if output_path is None:
        output_path = os.path.join(SCRIPT_DIR, "album_cover.jpg")
    
    try:
        # Handle file:// URLs
        if file_path.startswith("file://"):
            file_path = file_path.replace("file://", "")
            
        # Check if file exists
        if not os.path.exists(file_path):
            print(f"File not found: {file_path}")
            return False
            
        # Open and process the image
        with open(file_path, "rb") as f:
            img = Image.open(f)
            
            # Convert to RGB if needed
            if img.mode != "RGB":
                img = img.convert("RGB")
                
            # Save to the output path
            img.save(output_path, "JPEG", quality=95)
            print(f"Album art saved to {output_path}")
            return True
    except Exception as e:
        print(f"Error processing image: {e}")
        return False

def main():
    # Get the default cover path (can be overridden by argument)
    default_cover_path = os.path.join(SCRIPT_DIR, "album_cover.jpg")
    
    # If output path is provided as second argument, use that
    output_path = sys.argv[2] if len(sys.argv) > 2 else default_cover_path
    
    # If URL is provided as argument, use that
    if len(sys.argv) > 1:
        url = sys.argv[1]
    # Otherwise get URL from playerctl
    else:
        url = get_art_url_from_playerctl()
        if not url:
            return False
            
    # Process and save the image
    return save_image(url, output_path)

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
