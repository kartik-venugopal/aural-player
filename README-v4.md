<img width="225" src="https://raw.githubusercontent.com/maculateConception/aural-player/main/Documentation/Screenshots/readmeLogo.png"/>

### Unified Mode
<img width="900" src="https://github.com/kartik-venugopal/aural-player/raw/main/UnifiedMode.png"/>

<img width="900" src="https://github.com/kartik-venugopal/aural-player/raw/main/UnifiedMode-FX.png"/>

### Compact Mode
<img width="650" src="https://github.com/kartik-venugopal/aural-player/raw/main/CompactMode.png"/>

### Library (in Modular Mode)
<img width="1400" src="https://github.com/kartik-venugopal/aural-player/raw/main/aural4.png"/>

### Tune Browser (in Modular Mode)
<img width="1400" src="https://github.com/kartik-venugopal/aural-player/raw/main/TuneBrowser.png"/>

## The v4.0 goals

As of Jan 12, 2024, Aural Player version 4.0 is in active development, and aims to take the app to the next level ... making the app prettier, more intuitive, and offering more ways to search for and organize tracks and track lists.

### New core features ("MVP")

- 2 new app modes (NOTE - All existing app modes, including the classic modular mode, will remain):
   * A "Unified" mode that combines all of Aural's modules / features into a single resizable window.
   * A "Compact" mode that provides the essentials (player and play queue, plus some theming options) in a compact fixed-size window.
- A rich new full-fledged library for music organization that includes a convenient file system browser and lets the user create and save multiple playlists.
- The old "playlist" becomes the new "play queue".
- The ability to easily copy tracks across modules with drag / drop. Example - from a playlist to the play queue, or from the library to a playlist.
- The ability to easily create new playlists from different places. Example - from a file system folder or from a library album.
- Enhanced Favorites list for tracks, playlists, folders, albums, artists, etc.
- Enhanced history that keeps track of play counts for tracks, playlists, folders, albums, artists, etc.
- Nicer user interface aesthetics (look and feel)
- More compact player and FX panel windows (area reduced by 20%)
- A new app setup screen on first app launch, to help new users with initial setup.
- Simplified theming (fonts and colors)
- Improved usability
- A lot more help and tool tips
- Cleaner source code and use of newer APIs
- Advanced search capabilities (including file system search).
- Better support for multi-screen setups (window layouts)

### Development notes

- Tests will no longer be written / maintained, due to time constraints.
- Version 4.0 will only support macOS 11.0 (Big Sur) and newer versions. This is to:
  * Take advantage of more recent advancements to the AppKit framework and other features unavailable on older platforms.
  * Simplify codebase maintenance.
  * Simplify manual app testing.
  * NOTE - For users on older macOS platforms, the existing 3.x releases will continue to be available and can be used instead.

- The version 3.x code will be put into a new branch, and v4.x will become the master branch.
- There may be a few bug fixes on the 3.x branch if deemed necessary, but no new feature development will occur.

### Beyond MVP

Apart from the core improvements in v4.0, the following features will likely be implemented:

- CUE Sheet support
- Replay Gain
- Gapless queueing of tracks, to reduce audible gaps (NOTE - this is NOT the same as gapless playback, which analyzes audio data or metadata tags).

The following features are possible, but not highly likely:

- A "lite" app version for iOS / iPadOS
- Online streaming
- Plug-in architecture for visualizations (enabling developers to use / share custom visualizations) ? ... TBD

