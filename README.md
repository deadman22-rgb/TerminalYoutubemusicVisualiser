# 🎵 Terminal Music Visualizer

A fun terminal-based visualization tool that shows album art alongside audio waveforms while you jam to your tunes.

![Terminal Music Visualizer Demo](showcase.gif)

## ✨ What's This?

Ever wanted your terminal to look awesome while playing music? This tool creates a split view with:

- A cool audio waveform that bounces to your music on the left
- Album art and song details on the right
- Clean layout with no pesky terminal prompts to ruin the vibe

Works great with YouTube Music and other media players that support playerctl!

now you might be wondering why make something like this ?? becasue well 
![Monkey Neuron Activation](https://media.tenor.com/Tx7ph1gRGFQAAAAM/monkey-monke.gif)

## 🚀 Quick Install (Arch Linux)

I've made installation super easy. Just double-click the `install.sh` script or run:

```bash
./install.sh
```

The installer will:
- Check and install all required packages using pacman
- Install YouTube Music from AUR if you want it (and you have yay youtube-music-bin)
- Create a desktop entry so you can launch from your app menu
- Set up a launcher script for easy double-clicking

## 📋 What You'll Need

- **Arch Linux** (or other Linux with slight modifications)
- **Kitty Terminal** - For showing images in the terminal
- **TMux** - For the split-screen magic
- **Cava** - For the audio visualizations
- **Python with Pillow** - For handling album artwork
- **playerctl** - To grab song info

## 🎮 How to Use It

After installation, you have three easy ways to start:

1. **Double-click** the `launch-visualizer.sh` file
2. Launch from your **applications menu**
3. Run it directly with:
   ```bash
   ./cavayt.sh
   ```

Then just sit back and enjoy the show! It automatically detects song changes and updates the display.

Press `Ctrl+C` when you want to quit.

## 🆕 Cool New Features!

- **Persistent Album Art** - Album covers are now saved in the program folder instead of /tmp, so they stick around between sessions
- **Double-Click to Run** - No more command line needed! Just click and enjoy
- **Desktop Integration** - Appears in your application menu like any regular app
- **One-Step Installation** - All dependencies handled automatically

## ⚙️ How It Actually Works

The visualizer is pretty simple but clever:

1. It creates a tmux session with three panes:
   - Left pane (70%): Runs Cava for audio visualization
   - Top-right pane: Shows album art
   - Bottom-right pane: Displays song info

2. In the background, it constantly checks what's playing using playerctl, and when the song changes:
   - Gets the new song info
   - Grabs the album art using the Python helper
   - Updates the display

## 🔧 Want to Tinker?

Feel free to customize things:

- Change the split ratio by tweaking the `-p 30` value in the script
- Modify how song info appears by editing the `update_song_info` function
- The album art is saved to the same folder as the script, so it's easy to find

## 🛠️ File Structure

```
terminal-music-viz/
├── cavayt.sh            # Main script that runs everything
├── get_cover.py         # Python script for album art
├── album_cover.jpg      # The current/last album cover
├── install.sh           # Installation script
├── launch-visualizer.sh # Double-click launcher
└── README.md            # You are here!
```

## ❓ Troubleshooting

- **No visualization?** Make sure Cava is installed
- **No album art?** Check if your player provides artwork via MPRIS
- **Weird display issues?** Make sure you're using Kitty terminal
- **Not working?** Check the debug log at `/tmp/music_viz_debug.log`

## 👾 known bugs 
- **when changing songs, it causes the albumm cover to show in the cava pane which i dont know why is happening if you happen to know why or can help me out, try to make changes i will merge them
![Known bugs](knownbugs.gif)  

## 📜 License

This project uses the MIT License - see the LICENSE file for details.

## 👋 Wrap Up

Enjoy your music with some terminal eye-candy! If you have ideas to make it better, feel free to contribute or just have fun with it. i will probably addd a way here if anyone wants to buy me a coffee or enriched uranium
