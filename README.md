# Aural Player

![App demo](/Documentation/Demos/GeneralDemo.gif?raw=true "App demo")

## Overview

Aural Player is a free and open source audio player application for the MacOS (formerly OS X) platform. It is free for anyone to use/modify/repackage/redistribute, etc. It is designed to be to-the-point and easy to use, with plenty of keyboard shortcuts for convenience and efficiency, much like the classic Winamp player on Windows, plus some additional sound tuning capabilities for audio enthusiasts who like to tweak sound.

### Summary of features

- Playback of MP3, M4A, AAC, AIFF, WAV, and CAF audio files
- Supports M3U/M3U8 playlists
- Sound effects: Graphic equalizer, Pitch shift, Time stretch, Reverb, Delay, Filter
- Recording of clips
- Displays ID3 metadata including artwork
- Searching and sorting of playlist

### Compatibility

**User**: Running Aural Player requires OS X 10.10 (Yosemite) or later MacOS versions.

**Developer**: To develop Aural Player with Swift 3 (master branch) requires MacOS 10.12 (Sierra) and XCode 8.x. To develop Aural Player with Swift 2 ("swift2" branch) requires OS X 10.10 (Yosemite) or later and XCode 7.x.

### Background

Aural Player was written by an audio enthusiast learning to program on OS X, coming to Swift programming from many years of Java programming. This project was inspired by the developer’s desire to create a Winamp-like substitute for the MacOS platform. No feature bloat or unnecessary annoyances like iTunes.

## Downloadable app bundle

The latest app bundle can be found in the compressed archive file [Aural.app.zip](https://github.com/maculateConception/aural-player/blob/master/Aural.app.zip?raw=true).

## Documentation

[User Guide](https://rawgit.com/maculateConception/aural-player/master/Documentation/UserGuide.html)

[Developer readme](https://github.com/maculateConception/aural-player/blob/master/Documentation/Developer-readme.rtf?raw=true) 

[Demo videos](/Documentation/Demos)

## Recent updates

8/13/2017; **Preferences panel** - Added a preferences dialog to allow users to configure different bits of player/playlist/view functionality.

8/11/2017: **M3U playlist support** - Added support for M3U/M3U8 playlists. Also, app now allows and properly resolves file aliases and symbolic links.

8/10/2017: **New HTML User Guide** - Completely rewrote the User Guide. It is now in HTML format and explains all features in detail, with lots of screenshots. Did away with the old RTFD format User Guide.

8/8/2017: **Demo videos** - Added lots of .mp4 demo videos that illustrate different features.

7/28/2017: **UI overhaul** - Major overhaul of the UI. New color scheme (dark background, light text), new slider control look and feel. Each slider control has an accompanying label showing its value, for instant feedback when making adjustments.

7/20/2017: **Swift v3 migration** - Code in master branch ported to Swift v3. Swift 2 code is now in the "swift2" branch. Swift 2 development, from this point on, will be limited to none. Latest changes will go into master branch (with Swift 3 code).

## Third party code attribution

Aural Player makes use of (a modified version of) a reusable UI control called [RangeSlider](https://github.com/matthewreagan/RangeSlider).

## Screenshots

### Default view

![App screenshot](/Documentation/Screenshots/Aural.png?raw=true "App screenshot")

### Default view w/ detailed track info popover view

![App screenshot w/ more info view](/Documentation/Screenshots/MoreInfo.png?raw=true "More Info")

### Playlist-only view

![App screenshot2](/Documentation/Screenshots/Aural-playlistOnly.png?raw=true "App screenshot2")

### Effects-only view

![App screenshot3](/Documentation/Screenshots/Aural-effectsOnly.png?raw=true "App screenshot3")

### Compact view

![App screenshot4](/Documentation/Screenshots/Aural-compact.png?raw=true "App screenshot4")

### Pitch shift effects unit

![Pitch](/Documentation/Screenshots/Pitch.png?raw=true "Pitch Shift")

### Time stretch effects unit

![Time](/Documentation/Screenshots/Time.png?raw=true "Time Stretch")

### Filter effects unit

![Filter](/Documentation/Screenshots/Filter.png?raw=true "Filter")

### Recorder unit

![Recorder](/Documentation/Screenshots/Recorder.png?raw=true "Recorder")
