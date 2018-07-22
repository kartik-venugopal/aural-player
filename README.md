# Aural Player

![App demo](/Documentation/Demos/newDemo.gif?raw=true "App demo")

![App demo 2](/Documentation/Demos/demo2.gif?raw=true "App demo 2")

## Overview

Aural Player is a free and open source audio player application for the macOS platform. Inspired by the classic Winamp player for Windows, it is designed to be to-the-point and easy to use, with a variety of convenient and efficient controls, plus some additional sound tuning capabilities for audio enthusiasts who like to tweak sound.

### Summary of features

- Playback of MP3, AAC, AIFF/AIFC, WAV, and CAF audio files
- Supports M3U/M3U8 playlists
- Sound effects: Graphic equalizer, Pitch shift, Time stretch, Reverb, Delay, Filter
- Recording of clips in AAC/ALAC/AIFF formats
- Track segment looping, to allow users to loop their favorite parts of a track
- Configurable autoplay (on app startup and/or when tracks are added)
- Display of ID3 and iTunes metadata, including artwork (when available)
- Grouping of tracks by artist/album/genre for convenient playlist browsing
- Favorites list and recent items lists for added convenience
- Searching and sorting of playlist
- Multiple compact and flexible view options - playlist docking/maximizing and collapsible views
- Gesture recognition for essential player/playlist controls (trackpad/MagicMouse)
- Extensive set of keyboard shortcuts and menu items for quick and convenient access to functionality
- Extensive set of preferences to allow user to customize functionality (e.g. seek/volume/pan increment, enabling/disabling and mouse sensitivity for gestures, remembered/default volume on startup, remembered/default view on startup, etc.)

### Compatibility

**User**: Running Aural Player requires OS X 10.10 (Yosemite) or later macOS versions.

**Developer**: To develop Aural Player with Swift 3 (master branch) requires macOS 10.12 (Sierra) and XCode 8.x. To develop Aural Player with Swift 2 ("swift2" branch) requires OS X 10.10 (Yosemite) or later and XCode 7.x.

### Background

Aural Player was written by an audio enthusiast learning to program on OS X, coming to Swift programming from many years of Java programming. This project was inspired by the developer’s desire to create a Winamp-like substitute for the macOS platform. No feature bloat or unnecessary annoyances like iTunes.

## Downloadable app bundle

Wanna try it out ? The latest app bundle can be found in the disk image file [Aural.dmg](https://github.com/maculateConception/aural-player/blob/master/Aural.dmg?raw=true). Just download the file, mount it, and run the app !

## Third party code and contributor attributions

Aural Player makes use of (a modified version of) a reusable UI control called [RangeSlider](https://github.com/matthewreagan/RangeSlider).

Fellow GitHub member [Dunkeeel](https://github.com/Dunkeeel) made significant contributions towards this project - performance optimizations, UX improvements, etc.

## Screenshots

### Default view

![App screenshot](/Documentation/Screenshots/Default.png?raw=true "App screenshot")

### Track segment loop playback (red segment on seek bar)

![App screenshot](/Documentation/Screenshots/SegmentLoop.png?raw=true "Track segment loop playback")

### Playlist-only view w/ detailed track info popover view

![App screenshot w/ more info view](/Documentation/Screenshots/DetailedInfo.png?raw=true "More Info")

### Playlist docked to the left

![App screenshot2](/Documentation/Screenshots/DockedLeft.png?raw=true "App screenshot2")

### Detached playlist

![App screenshot3](/Documentation/Screenshots/DetachedPlaylist.png?raw=true "App screenshot3")

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


