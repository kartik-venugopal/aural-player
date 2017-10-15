# Aural Player

![App demo](/Documentation/Demos/ShortGeneralDemo.gif?raw=true "App demo")

![App demo 2](/Documentation/Demos/ShortDemo2.gif?raw=true "App demo 2")

## Overview

Aural Player is a free and open source audio player application for the MacOS (formerly OS X) platform. It is free for anyone to use/modify/repackage/redistribute, etc. It is designed to be to-the-point and easy to use, with plenty of keyboard shortcuts for convenience and efficiency, much like the classic Winamp player on Windows, plus some additional sound tuning capabilities for audio enthusiasts who like to tweak sound.

### Summary of features

- Playback of MP3, AAC, AIFF/AIFC, WAV, and CAF audio files
- Supports M3U/M3U8 playlists
- Sound effects: Graphic equalizer, Pitch shift, Time stretch, Reverb, Delay, Filter
- Recording of clips in AAC/ALAC/AIFF formats
- Displays ID3 and iTunes metadata, including artwork (when available)
- Searching and sorting of playlist
- Multiple compact view options

### Compatibility

**User**: Running Aural Player requires OS X 10.10 (Yosemite) or later MacOS versions.

**Developer**: To develop Aural Player with Swift 3 (master branch) requires MacOS 10.12 (Sierra) and XCode 8.x. To develop Aural Player with Swift 2 ("swift2" branch) requires OS X 10.10 (Yosemite) or later and XCode 7.x.

### Background

Aural Player was written by an audio enthusiast learning to program on OS X, coming to Swift programming from many years of Java programming. This project was inspired by the developer’s desire to create a Winamp-like substitute for the MacOS platform. No feature bloat or unnecessary annoyances like iTunes.

## Downloadable app bundle

Wanna try it out ? The latest app bundle can be found in the compressed archive file [Aural.app.zip](https://github.com/maculateConception/aural-player/blob/master/Aural.app.zip?raw=true). Just download the archive, extract the app file, and run it !

## Documentation

[User Guide (pdf)](https://github.com/maculateConception/aural-player/blob/master/Documentation/UserGuide.pdf?raw=true)

[User Guide (HTML)](https://rawgit.com/maculateConception/aural-player/master/Documentation/UserGuide.html)

[Demo videos](/Documentation/Demos)

[Developer readme](https://github.com/maculateConception/aural-player/blob/master/Documentation/Developer-readme.rtf?raw=true) 

## Planned updates

**Multiple selection and drag/drop reordering in playlist** - The playlist will allow selection of multiple items at once, and reordering by dragging and dropping. This will make reordering and/or removal of multiple playlist tracks much less tedious.

**New playlist views with track groups** - In addition to the current flat view, new views will be added to the playlist, which group tracks by album, artist, genre, etc.

## Recent updates

10/12/2017: **New playlist navigation functions** - New functions have been added for more convenient playlist navigation. These include: 1 - Show playing track within playlist, 2 - Scroll to top of playlist, and 3 - Scroll to bottom of playlist.

10/12/2017: **Resizable, detachable, and movable playlist** - The playlist is now resizable, detachable, and movable, with buttons to conveniently snap/attach the playlist to the main app window, in different relative locations (bottom, right, left, etc), and smart maximizing.

9/25/2017: **New recording formats** - Added support for ALAC (Apple Lossless) and AIFF (CD Quality) recording.

9/23/2017: **Volume and Pan feedback labels** - Whenever the volume and pan are updated, feedback labels will now show up, with the new values for volume or pan, and the labels will auto-hide after a second.

9/23/2017: **New EQ presets** - Added 10 new music genre-based Equalizer presets: Rock, Pop, Jazz, etc.

9/15/2017: **Complete reading of ID3/iTunes metadata** - Previously, only "common" metadata format information was read and displayed by the app. Now, all standard/recognizable ID3 and iTunes metadata are read, marshaled into a user-friendly readable format, and displayed. Metadata in other formats are displayed as is (without any marshaling).

9/13/2017: **Much faster track adding** - Significantly improved the efficiency of the track add operation. Tracks are added to the playlist almost instantaneously, and all secondary track data is loaded asynchronously as needed.

9/11/2017: **Added dock menu** - Added a new dock menu that provides a limited set of essential player controls that can be accessed while the player window is in the background.

9/10/2017: **Direct launching of files from Finder** - Any supported audio files/playlists can now be opened directly from Finder, with Aural. Aural now accepts launch parameters. If the app is already open, the selected files/playlists will be appended to its playlist and the first selected track will start playing.

8/31/2017 - 9/13/2017: **Major code refactoring/cleanup** - Completely rewrote the view layer and the delegate (middleman) layer. Separated huge catch-all view classes into smaller classes that handle specific chunks of functionality. Separated big monolithic delegate into smaller chunks. Refactored back end accordingly.

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
