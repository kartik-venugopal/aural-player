# Aural Player

![App demo](/Documentation/Demos/ShortGeneralDemo6.gif?raw=true "App demo")

![App demo 2](/Documentation/Demos/ShortGeneralDemo5.gif?raw=true "App demo 2")

## Overview

Aural Player is a free and open source audio player application for the MacOS (formerly OS X) platform. It is free for anyone to use/modify/repackage/redistribute, etc. It is designed to be to-the-point and easy to use, with plenty of keyboard shortcuts for convenience and efficiency, much like the classic Winamp player on Windows, plus some additional sound tuning capabilities for audio enthusiasts who like to tweak sound.

### Summary of features

- Playback of MP3, AAC, AIFF/AIFC, WAV, and CAF audio files
- Supports M3U/M3U8 playlists
- Sound effects: Graphic equalizer, Pitch shift, Time stretch, Reverb, Delay, Filter
- Recording of clips in AAC/ALAC/AIFF formats
- Displays ID3 and iTunes metadata, including artwork (when available)
- Grouping of tracks by artist/album/genre for convenient playlist browsing
- Searching and sorting of playlist
- Multiple compact and flexible view options - playlist docking and collapsible views
- Extensive set of keyboard shortcuts for convenient control

### Compatibility

**User**: Running Aural Player requires OS X 10.10 (Yosemite) or later MacOS versions.

**Developer**: To develop Aural Player with Swift 3 (master branch) requires MacOS 10.12 (Sierra) and XCode 8.x. To develop Aural Player with Swift 2 ("swift2" branch) requires OS X 10.10 (Yosemite) or later and XCode 7.x.

### Background

Aural Player was written by an audio enthusiast learning to program on OS X, coming to Swift programming from many years of Java programming. This project was inspired by the developer’s desire to create a Winamp-like substitute for the MacOS platform. No feature bloat or unnecessary annoyances like iTunes.

## Downloadable app bundle

Wanna try it out ? The latest app bundle can be found in the disk image file [Aural Player.dmg](https://github.com/maculateConception/aural-player/blob/master/Aural Player.dmg?raw=true). Just download the file, mount it, and run the app !

## Documentation

[User Guide (pdf)](https://github.com/maculateConception/aural-player/blob/master/Documentation/UserGuide.pdf?raw=true)

[User Guide (HTML)](https://rawgit.com/maculateConception/aural-player/master/Documentation/UserGuide.html)

[Demo videos](/Documentation/Demos)

[Developer readme](https://github.com/maculateConception/aural-player/blob/master/Documentation/Developer-readme.rtf?raw=true) 

## Recent updates

11/3/2017: **New playlist views with track groups** - In addition to the current flat view, new views have been added to the playlist, which group tracks by album, artist, genre, etc. This allows for convenient playlist browsing.

11/3/2018: **UI refresh** - A lot of UI elements have been redone, for a slicker appearance. Window corners, background colors, slider controls, playlist summary, etc.

10/15/2017: **Multiple selection, type selection, and drag/drop reordering in playlist** - The playlist now allows selection of multiple items at once, and type selection to find tracks quickly by typing their name. Also, it now allows reordering by dragging and dropping. This makes reordering, and/or removal of multiple playlist tracks much less tedious, and provides a quick way to search for tracks by name. (Full-fledged search is still available)

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

![App screenshot](/Documentation/Screenshots/Default.png?raw=true "App screenshot")

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

### Delay unit

![Recorder](/Documentation/Screenshots/Delay.png?raw=true "Delay")
