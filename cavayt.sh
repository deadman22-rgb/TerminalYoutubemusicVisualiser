#!/bin/bash

# === Configuration ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COVER_PATH="$SCRIPT_DIR/album_cover.jpg"
SONG_INFO_PATH="/tmp/song_info.txt"
CURRENT_SONG_ID=""
PYTHON_SCRIPT_PATH="$SCRIPT_DIR/get_cover.py"
DEBUG_LOG="/tmp/music_viz_debug.log"
ALBUM_SCRIPT="/tmp/display_album.sh"

# Enable logging
exec > >(tee -a "$DEBUG_LOG") 2>&1
echo "=== Starting script at $(date) ==="

# === Setup ===
# Clean up any existing session
echo "Cleaning up previous session..."
tmux kill-session -t music_viz 2>/dev/null
rm -f "$SONG_INFO_PATH" "$ALBUM_SCRIPT"
touch "$SONG_INFO_PATH"

# Create album art display script
cat > "$ALBUM_SCRIPT" << 'EOL'
#!/bin/bash
# Script to display album art without showing terminal prompt
clear
TERM=xterm-kitty kitty +kitten icat --align=center "$1"
# Keep terminal busy without showing prompt
sleep infinity
EOL
chmod +x "$ALBUM_SCRIPT"

# === Function to update song info ===
update_song_info() {
    # Get metadata from playerctl
    local title=$(playerctl metadata title 2>/dev/null)
    local artist=$(playerctl metadata artist 2>/dev/null)
    local album=$(playerctl metadata album 2>/dev/null)
    local art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)
    
    # Skip if no data
    if [ -z "$title" ]; then
        return 1
    fi
    
    # Create a unique ID for the song
    local new_song_id="${title}::${artist}::${album}"
    
    # Only update if song changed
    if [ "$new_song_id" != "$CURRENT_SONG_ID" ]; then
        echo "Song changed to: $title by $artist" >> "$DEBUG_LOG"
        CURRENT_SONG_ID="$new_song_id"
        
        # Save for display
        {
            echo -e "\n"
            echo -e "  🎵 ${title:-Unknown}"
            echo -e "\n"
            echo -e "  🎤 ${artist:-Unknown}"
            echo -e "\n"
            echo -e "  💿 ${album:-Unknown}"
        } > "$SONG_INFO_PATH"
        
        # Get album art 
        if [ -n "$art_url" ]; then
            echo "Getting album art from: $art_url" >> "$DEBUG_LOG"
            python3 "$PYTHON_SCRIPT_PATH" "$art_url" "$COVER_PATH" 2>> "$DEBUG_LOG"
        fi
        
        # Display album art if it exists
        if [ -f "$COVER_PATH" ]; then
            echo "Displaying album art in tmux pane" >> "$DEBUG_LOG"
            # Stop any existing display process and start a new one
            tmux select-pane -t music_viz:0.1
            tmux send-keys -t music_viz:0.1 C-c  # Clear any running commands
            # Run our script that will keep the terminal busy
            tmux send-keys -t music_viz:0.1 "$ALBUM_SCRIPT \"$COVER_PATH\"" C-m
        else
            echo "Album art file not found: $COVER_PATH" >> "$DEBUG_LOG"
        fi
        
        return 0
    fi
    
    return 1
}

echo "Creating tmux session..."

# Create a new tmux session with cava
if command -v cava >/dev/null 2>&1; then
    tmux new-session -d -s music_viz "exec cava" || {
        echo "Failed to start tmux session with cava. Trying alternative..."
        tmux new-session -d -s music_viz "while true; do printf '█%.0s' {1..$(tput cols)}; sleep 0.1; clear; done"
    }
else
    echo "Cava not found. Using simple visualization..."
    tmux new-session -d -s music_viz "while true; do printf '█%.0s' {1..$(tput cols)}; sleep 0.1; clear; done"
fi
sleep 1

# Create right pane with 30% width for album art and info
tmux split-window -h -p 30 -t music_viz:0.0
sleep 0.5

# Initialize the album art pane simply
tmux select-pane -t music_viz:0.1
tmux send-keys -t music_viz:0.1 "clear && echo 'Waiting for music...' && sleep infinity" C-m
sleep 0.5

# Create bottom pane in right side for song info
tmux split-window -v -p 50 -t music_viz:0.1
sleep 0.5

# Set up song info display loop
tmux select-pane -t music_viz:0.2
tmux send-keys -t music_viz:0.2 "clear && echo 'Loading song info...'" C-m
tmux send-keys -t music_viz:0.2 "while true; do clear; cat \"$SONG_INFO_PATH\" 2>/dev/null; sleep 1; done" C-m
sleep 0.5

# Setup background process to update info
(
while true; do
    update_song_info
    sleep 1
done
) &
UPDATE_PID=$!

# Store PID for cleanup
echo $UPDATE_PID > /tmp/music_viz_pid

# Handle cleanup
trap 'echo "Cleaning up..."; tmux kill-session -t music_viz 2>/dev/null; kill $(cat /tmp/music_viz_pid 2>/dev/null) 2>/dev/null; rm -f "$SONG_INFO_PATH" "$ALBUM_SCRIPT" /tmp/music_viz_pid' EXIT INT TERM

# Attach to tmux session
echo "Starting music visualizer..."
tmux attach-session -t music_viz

# Cleanup after tmux exits
kill $(cat /tmp/music_viz_pid 2>/dev/null) 2>/dev/null
rm -f "$SONG_INFO_PATH" "$ALBUM_SCRIPT" /tmp/music_viz_pid
exit 0