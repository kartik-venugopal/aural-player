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

[User Guide (pdf)](https://github.com/maculateConception/aural-player/blob/master/Documentation/UserGuide.pdf?raw=true)

[User Guide (HTML)](https://rawgit.com/maculateConception/aural-player/master/Documentation/UserGuide.html)

[Developer readme](https://github.com/maculateConception/aural-player/blob/master/Documentation/Developer-readme.rtf?raw=true) 

[Demo videos](/Documentation/Demos)

## Recent updates

9/15/2017 **Complete reading of ID3/iTunes metadata** - Previously, only "common" metadata format information was read and displayed by the app. Now, all standard/recognizable ID3 and iTunes metadata are read, marshaled into a user-friendly readable format, and displayed. Metadata in other formats are displayed as is (without any marshaling).

9/13/2017: **Much faster track adding** - Significantly improved the efficiency of the track add operation. Tracks are added to the playlist almost instantaneously, and all secondary track data is loaded asynchronously as needed.

9/11/2017: **Added dock menu** - Added a new dock menu that provides a limited set of essential player controls that can be accessed while the player window is in the background.

9/10/2017: **Direct launching of files from Finder** - Any supported audio files/playlists can now be opened directly from Finder, with Aural. Aural now accepts launch parameters. If the app is already open, the selected files/playlists will be appended to its playlist and the first selected track will start playing.

8/31/2017 - 9/13/2017: **Major code refactoring/cleanup** - Completely rewrote the view layer and the delegate (middleman) layer. Separated huge catch-all view classes into smaller classes that handle specific chunks of functionality. Separated big monolithic delegate into smaller chunks. Refactored back end accordingly.

8/17/2017: **PDF User Guide bundled with app** - There is now a PDF version of the User Guide available. It is bundled with the app, and can be opened from within the app, through the Help menu.

8/16/2017: **Bug fix and efficiency improvements** - Fixed a bug in the Time effects unit, and made significant UI efficiency improvements in how the playlist view is updated when tracks are moved/removed.

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
