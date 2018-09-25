# Aural Player

![App demo](/Documentation/Demos/newestDemo.gif?raw=true "App demo")

## Overview

Aural Player is a free and open source audio player application for the macOS platform. Inspired by the classic Winamp player for Windows, it is designed to be to-the-point, easy to use, and highly customizable, with some sound tuning capabilities for audio enthusiasts.

## Download

Download the disk image file [Aural.dmg](https://github.com/maculateConception/aural-player/blob/master/Aural.dmg?raw=true). Just mount it and run the app !

## Features

- Playback of MP3, AAC, AIFF/AIFC, WAV, and CAF audio files
- Supports M3U/M3U8 playlists
- Sound effects: Graphic equalizer, Pitch shift, Time stretch, Reverb, Delay, Filter
- Effects units let you save your settings as presets, so you can use them later without having to remember them **(New!)**
- Track segment looping, to allow you to loop your favorite parts of a track
- Display of ID3 and iTunes metadata, including artwork (when available)
- Bookmarking, so you can mark a specific position within a track, and come back to it later, which is great for long tracks like audiobooks **(New!)**
- Recording of clips in AAC/ALAC/AIFF formats, so you can capture your applied sound effects and create a customized version of your track.
- Configurable autoplay (on app startup and/or when tracks are added)
- Grouping of tracks by artist/album/genre for convenient playlist browsing
- Searching and sorting of playlist
- Playlist type selection: Just start typing the name of a track to try to find it within the playlist
- Favorites list and recent items lists for added convenience
- Multiple compact and flexible view options - several built-in window layout presets, window snapping with configurable spacing, collapsible views. Plus, you can save your customized window layouts as presets so you can use them again at any time. **(New!)**
- Gesture recognition for essential player/playlist controls (trackpad/MagicMouse). e.g. two finger vertical scroll for volume control, horizontal scroll for seeking, three finger horizontal swipe to change tracks
- Extensive set of keyboard shortcuts and menu items for quick and convenient access to functionality
- Numerous preferences to allow user to highly customize functionality (e.g. seek/volume/pan increment, enabling/disabling and mouse sensitivity for gestures, configurable window layout and snapping behavior, remembered/default volume on startup, etc.)

### Compatibility

**User**: Running Aural Player requires OS X 10.10 (Yosemite) or later macOS versions.

**Developer**: To develop Aural Player with Swift 3 (master branch) requires macOS 10.12 (Sierra) and XCode 8.x. To develop Aural Player with Swift 2 ("swift2" branch) requires OS X 10.10 (Yosemite) or later and XCode 7.x.

### Recent updates

- **9/25/2018: New release:**
  * New features:
    * **Configurable window spacing**: The user can now configure the spacing between windows when windows are snapped together. The user can specify a value between 0 and 25 pixels, as per his visual preference.
    * **Layouts editor**: The user can now manage user-defined window layouts (preview, rename, and/or delete them) within a new editor window.

- **9/24/2018: New release:**
  * New features:
    * **Bookmarks editor and Favorites editor**: The user can now manage bookmarks (rename and/or delete them) and favorites (delete unwanted ones) with a new editor window.
    * **Playlist file on startup**: The user can now specify a preference that, on app startup, the playlist should load tracks from a specific (M3U/M3U8) playlist file. This option can be found in the Playlist tab of the Preferences dialog.
    * **Seeking/looping/replaying tracks when paused**: Previously, seeking, looping, and replaying tracks could only be done while the player was playing (as opposed to paused). This limitation no longer exists.
    
  * Bug fixes:
    * **History/Favorites bug**: When history/favorites lists are resized, menus and other UI elements need to be updated. They weren't always being updated, resulting in weird UI states.

- **9/22/2018: New release with lots of updates:**
  * New features:
    * **Bookmarking**: The user can now mark a specific position in a track, and it will be saved with a name/description the user can provide. The user can then return to that track position later with one click. This is great when listening to long files like audiobooks or podcasts.
    * **New window layouts and user-defined layouts**: The way windows are laid out has been simplified and made easier for the user. The user can choose from multiple built-in window layouts, or lay out the windows per his preference and save the layout as a preset for later use. **Window snapping**, to other app windows, and to screen corners and edges for added convenience.
    * **FX unit presets**: Each effects unit now allows the saving of settings as a preset, so the user can save all his sound settings as presets for later use with just one click.
    * **Dynamic tool tips**: The previous/next track buttons of the player controls now show the name of the previous/next track, as tool tips, so the user can know, before clicking the button, which track will play as a result.
    
  * The following bugs have been fixed:
    * Audio engine crash upon app exit, causing corruption of app state file, resulting in loss of all saved settings and user presets/data.
    * When playing a track from Favorites/Recently played list, the first 5 seconds of the track would sometimes play twice in a row, because of a race condition in the code that performed preparation for track playback.
    * The playlist scroll buttons stopped working at some point.


- **9/14/2018: Improved aesthetics -** Touched up the UI. Removed ugly panel borders, redid tab group button selection boxes, changed app title text font.
- **9/14/2018: Playlist docking bug fix -** Fixed a bug that caused the playlist's docking location to not be rememebered across app launches.
- **9/14/2018: Show track in Finder -** Implemented a new function to allow users to show a track in Finder from the playlist's context menu (i.e. the right-click menu).

### Background

Aural Player was written by an audio enthusiast learning to program on OS X, coming to Swift programming from many years of Java programming. This project was inspired by the developer’s desire to create a Winamp-like substitute for the macOS platform. No feature bloat or unnecessary annoyances like iTunes.

### Third party code and contributor attributions

Aural Player makes use of (a modified version of) a reusable UI control called [RangeSlider](https://github.com/matthewreagan/RangeSlider).

Fellow GitHub member [Dunkeeel](https://github.com/Dunkeeel) made significant contributions towards this project - performance optimizations, UX improvements, etc.

## Screenshots

### Default view

![App screenshot](/Documentation/Screenshots/Default.png?raw=true "App screenshot")

### Track segment loop playback (red segment on seek bar)

![App screenshot](/Documentation/Screenshots/SegmentLoop.png?raw=true "Track segment loop playback")

### Playlist-only view w/ detailed track info popover view

![App screenshot w/ more info view](/Documentation/Screenshots/DetailedInfo.png?raw=true "More Info")

### Bookmarking

![App screenshot w/ more info view](/Documentation/Screenshots/Bookmarking.png?raw=true "Bookmarking")

#### Managing bookmarks

![App screenshot w/ more info view](/Documentation/Screenshots/BookmarksEditor.png?raw=true "Bookmarks Editor")

### Saving an effects unit preset

![App screenshot w/ more info view](/Documentation/Screenshots/FXPreset.png?raw=true "Saving an effects preset")

### "Big bottom playlist" window layout

![App screenshot2](/Documentation/Screenshots/BigBottomPlaylist.png?raw=true "Big bottom playlist window layout")

### Changing the window layout with one click

![App screenshot2](/Documentation/Demos/WindowLayout.gif?raw=true "Choosing a window layout")

### Managing window layouts

![App screenshot2](/Documentation/Screenshots/LayoutsEditor.png?raw=true "Managing window layouts")

### Compact view

![App screenshot4](/Documentation/Screenshots/Compact.png?raw=true "App screenshot4")

### Time stretch effects unit

![Time](/Documentation/Screenshots/Time.png?raw=true "Time Stretch")

### Filter effects unit

![Filter](/Documentation/Screenshots/Filter.png?raw=true "Filter")

### Delay effects unit

![Delay](/Documentation/Screenshots/Delay.png?raw=true "Delay")

### Playlist search

![Playlist search](/Documentation/Screenshots/Search.png?raw=true "Delay")

### Playlist sort

![Playlist sort](/Documentation/Screenshots/Sort.png?raw=true "Delay")

### Preferences (Playback tab selected)

![Preferences](/Documentation/Screenshots/Preferences-Playback.png?raw=true "Delay")


