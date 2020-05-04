# Aural Player

![App demo](/Documentation/Demos/mainDemo.gif?raw=true "App demo")

## Table of Contents
  * [Overview](#overview)
  * [Documentation](#documentation)
  * [Download](#download)
    + [Installation](#installation)
    + [Enabling media keys support](#enabling-media-keys-support-optional)
    + [Compatibility](#compatibility)
  * [Feature highlights](#feature-highlights)
  * [Screenshots](#screenshots)
  * [Third party code attributions](#third-party-code-attributions)
  * [Contributor attributions](#contributor-attributions)

## Overview

Aural Player is an audio player for macOS. Inspired by the classic Winamp player for Windows, it is designed to be to-the-point, easy to use, and customizable, with some sound tuning capabilities for audio enthusiasts.

#### Goals:
* To have a simple drag-drop-play player for the music collection on your local hard drive(s), that requires no configuration out of the box, although plenty of customization/configuration is possible.
* To make sound tuning an integral part of the listening experience and to have it within quick and easy reach at all times.
* To have a decent macOS alternative for Winamp.

## Documentation

All the documentation can be found on the [wiki](https://github.com/maculateConception/aural-player/wiki).

[How To's](https://github.com/maculateConception/aural-player/wiki/How-To's)

## Download

Download the DMG image (containing the app bundle) from the latest release [here](https://github.com/maculateConception/aural-player/releases/latest).

[See all releases](https://github.com/maculateConception/aural-player/releases)

**NOTE** - The ffmpeg source code (and build script / instructions) for each release can be found in the Source code archive (zip / tar) for the release, under **aural-player-x.y.z/Resources/ffmpeg** (when extracted).

### Installation

1. Mount the **AuralPlayer-x.y.z.dmg** image file
2. From within the mounted image, copy **Aural.app** to your local drive (e.g. Applications folder)
3. Run the copy from your local drive. You will likely see a security warning and the app will not open because the app's developer is not recognized by macOS.
4. Go to **System Preferences > Security & Privacy > General > Open anyway**, to allow Aural.app to open.

NOTE - Please ***don't*** run the app directly from within the image. It is a compressed image, and may result in the app behaving slowly and/or unpredictably. So, copy it outside and run the copy.

### Enabling media keys support (optional)

![Enabling media keys support](/Documentation/Screenshots/EnablingMediaKeys.png?raw=true "Enabling media keys support")

1. Quit Aural Player if it is running.
2. Go to **System Preferences > Security & Privacy > Privacy**, and select **Accessibility** from the list of features.
3. Click on the lock icon in the bottom left corner, if it is shown as locked. Enter your macOS password to authenticate.
4. Click the + button and select **Aural.app** in the file browser that opens, to add Aural Player to the list of apps allowed to control your computer (See image above).

**NOTE**
* Media keys support is available from version 1.3.0 onwards.
* You will have to repeat this simple process whenever you upgrade to a new version of the app, because the macOS Accessibility permissions are tied to a single instance of the app.

### Compatibility

**User**: macOS 10.12 (Sierra) or later versions

**Developer**: (Swift 4.2) macOS 10.13.4 (High Sierra) or later, and XCode 10

## Feature highlights

(Comprehensive feature list [here](https://github.com/maculateConception/aural-player/wiki/Features))

* Supports all Core Audio formats (inc. FLAC) and several non-native formats: (inc. Vorbis, Opus, WMA, DTS, & more)
* Supports M3U / M3U8 playlists
* **Playback:** Bookmarking, segment looping, 2 custom seek intervals, delayed playback, last position memory, timed gaps, autoplay
* **Chapters support:** Chapters list window, playback functions including loop, current chapter indication, search by title
* **Effects:** Graphic equalizer, pitch shift, time stretch, reverb, delay, filter
* Built-in and custom effects presets, per-track effects settings memory
* Recording of clips with effects captured
* **Playlist:** Grouping, searching, sorting, type selection
* **Information:** ID3, iTunes, WMA, Vorbis Comment, ApeV2, and other metadata (when available). Cover art, lyrics, file system and audio data. Option to export.
* **Track lists:** *Favorites* list, *recently added* and *recently played* lists.
* **UI:** Window layout presets (built-in and custom), window snapping, collapsible UI components, adjustable text size.
* **Usability:** Configurable media keys support, gesture recognition
      
## Screenshots

(All screenshots [here](https://github.com/maculateConception/aural-player/wiki/Screenshots))

### "Vertical full stack" window layout

![Vertical full stack window layout demo](/Documentation/Screenshots/Default.png?raw=true)

### Customizing the player view

![Player view](/Documentation/Demos/playerView.gif?raw=true)

### Segment loop playback

![Segment loop playback demo](/Documentation/Demos/ABLoop.gif?raw=true)

### Enabling and disabling effects

![Enabling and disabling effects demo](/Documentation/Demos/UsingFXUnit.gif?raw=true)

### Detailed track info

![Detailed track info](/Documentation/Demos/DetailedInfo.gif?raw=true)

### Changing the color scheme

![Changing the color scheme demo](/Documentation/Demos/ChangingColorScheme.gif?raw=true)

### Changing the window layout

![Changing the window layout demo](/Documentation/Demos/WindowLayout.gif?raw=true)

### Searching the playlist

![Searching the playlist demo](/Documentation/Demos/PlaylistSearch.gif?raw=true)

### Chapters support

![Chapters support demo](/Documentation/Demos/ChaptersDemo.gif?raw=true)

## Third party code attributions

* [FFmpeg](https://www.ffmpeg.org/) (used to transcode from unsupported to supported audio formats)
* [MediaKeyTap](https://github.com/nhurden/MediaKeyTap) (used to respond to media keys)
* [RangeSlider](https://github.com/matthewreagan/RangeSlider) (used in the Filter effects unit to specify frequency ranges)

## Contributor attributions

Fellow GitHub member [dun198](https://github.com/dun198) made significant contributions towards this project - performance optimizations, UX improvements, etc.
