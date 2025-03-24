# 🎵 Terminal Music Visualizer

A minimal terminal-based music player visualization tool that displays album art alongside audio visualizations.

![Terminal Music Visualizer Demo](docs/demo.gif)

## ✨ Features

- **Audio Visualization** - Beautiful audio waveform using Cava
- **Album Art Display** - Shows album cover of currently playing music in the terminal
- **Song Information** - Displays title, artist, and album information
- **Minimal Dependencies** - Uses tools likely already on your system
- **Automatic Updates** - Refreshes when songs change

## 📋 Requirements

- **Linux** (Tested on Arch Linux)
- **Kitty Terminal** - For image display capabilities
- **TMux** - For terminal multiplexing
- **Python 3** - For album art processing
- **Cava** - For audio visualization
- **playerctl** - For media info retrieval
- **PIL/Pillow** - Python imaging library

## 🚀 Installation

1. Clone this repository:
```bash
git clone https://github.com/deadman22th08/yt-terminal.git
cd yt-terminal
```

2. Install dependencies (Arch Linux example):
```bash
sudo pacman -S tmux cava playerctl python-pillow kitty
```

3. Make scripts executable:
```bash
chmod +x cavayt.sh get_cover.py
```

## 🎮 Usage

Simply run the script:

```bash
./cavayt.sh
```

The script will:
1. Create a tmux session with a 70/30 split layout
2. Run Cava in the left pane (70% width)
3. Display album art and song info in the right pane (30% width)
4. Automatically update when the song changes

Press `Ctrl+C` to quit.

## ⚙️ How It Works

The visualizer consists of two main components:

1. **cavayt.sh**: The main Bash script that:
   - Creates and manages the tmux layout
   - Monitors for song changes using playerctl
   - Updates album art and song information
   - Handles window management and cleanup

2. **get_cover.py**: Python script that:
   - Retrieves album artwork from local paths
   - Processes images for terminal display
   - Saves artwork to a temporary location

The script monitors your currently playing media using `playerctl` and updates the display whenever a new song starts playing.

## 🧩 File Structure

```
yt-terminal/
├── cavayt.sh         # Main script
├── get_cover.py      # Album art processor
└── README.md         # This documentation
```

## 🔧 Customization

You can customize the appearance by editing the following:

- Adjust the split ratio by changing the `-p 30` value in the tmux split window command
- Modify the song info formatting in the `update_song_info` function
- Change album art size by modifying the kitty icat parameters

## ❓ Troubleshooting

- **No album art displayed**: Ensure your media player provides album art via MPRIS
- **Cava segmentation fault**: Try updating Cava or using the fallback visualization
- **Kitty icat errors**: Ensure you're running in Kitty terminal with kitty remote control enabled
- **Album art shows in wrong pane**: Check the debug logs at `/tmp/music_viz_debug.log`

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## 🙏 Acknowledgements

- [Cava](https://github.com/karlstav/cava) - Console-based Audio Visualizer
- [playerctl](https://github.com/altdesktop/playerctl) - Media player controller
- [Kitty Terminal](https://sw.kovidgoyal.net/kitty/) - GPU-based terminal emulator 