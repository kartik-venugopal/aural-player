# Aural Player

![App demo](/Documentation/Demos/mainDemo.gif?raw=true "App demo")

## Table of Contents
  * [Overview](#overview)
  * [Documentation](#documentation)
  * [Download](#download)
    + [Installation](#installation)
    + [Enabling media keys support](#enabling-media-keys-support-available-with-version-130-onwards)
    + [Compatibility](#compatibility)
  * [Feature highlights](#feature-highlights)
  * [Screenshots](#screenshots)
  * [Third party code attributions](#third-party-code-attributions)
  * [Contributor attributions](#contributor-attributions)

## Overview

Aural Player is an audio player for macOS. Inspired by the classic Winamp player for Windows, it is designed to be to-the-point, easy to use, and customizable, with some sound tuning capabilities for audio enthusiasts.

#### Goals:
* To have a simple drag-drop-play player for the music collection on your local hard drive(s), that requires no configuration out of the box, although plenty of customization/configuration is possible.
* To have a decent macOS alternative for Winamp.

#### What it is not (at the moment):
* A streaming audio player that connects to internet radio stations/services
* A scrobbler

## Documentation

All the documentation can be found on the [wiki](https://github.com/maculateConception/aural-player/wiki).

[How To's](https://github.com/maculateConception/aural-player/wiki/How-To's)

## Download

Download the latest release [here](https://github.com/maculateConception/aural-player/releases/latest).

[See all releases](https://github.com/maculateConception/aural-player/releases)

### Installation

1. Mount the *AuralPlayer-x.y.z.dmg* image file
2. Copy *Aural.app* to your local drive (e.g. Applications folder)
3. Run the copy from your local drive. You will likely see a security warning and the app will not open because the app's developer is not recognized by macOS.
4. Go to System Preferences > Security & Privacy > General > Open anyway, to allow Aural.app to open.

NOTE - Please ***don't*** run the app directly from within the image. It is a compressed image, and may result in the app behaving slowly and/or unpredictably. So, copy it outside and run the copy.

### Enabling media keys support (available with version 1.3.0 onwards)


![Enabling media keys support](/Documentation/Screenshots/EnablingMediaKeys.png?raw=true "Enabling media keys support")

1. Quit Aural Player if it is running.
2. Go to System Preferences > Security & Privacy > Privacy, and select Accessibility from the list of features.
3. Click on the lock icon in the bottom left corner, if it is shown as locked. Enter your macOS password to authenticate.
4. Click the + button and select Aural.app in the file browser that opens, to add Aural Player to the list of apps allowed to control your computer. See image above.

**NOTE** - You will have to repeat this process whenever you upgrade to a new version of the app, because the macOS Accessibility permissions are tied to a single instance of the app.

### Compatibility

**User**: macOS 10.12 (Sierra) or later versions

**Developer**: (Swift 4.2) macOS 10.13.4 (High Sierra) or later, and XCode 10

## Feature highlights

(Comprehensive feature list [here](https://github.com/maculateConception/aural-player/wiki/Features))

* Supports all Core Audio formats (inc. FLAC) and several non-native formats: (inc. Vorbis, Opus, WMA, DTS, & more)
* Supports M3U / M3U8 playlists
* **Playback:** Bookmarking, segment looping, 2 custom seek intervals, delayed playback, last position memory, timed gaps, autoplay
* **Chapters support:** Chapters list window, current chapter title and marker, playback functions including loop
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

### Default view

![App screenshot](/Documentation/Screenshots/Default.png?raw=true "App screenshot")

### Segment loop playback

![App screenshot](/Documentation/Demos/ABLoop.gif?raw=true "Segment loop playback")

### Using the Effects panel to disable/enable effects

![App screenshot2](/Documentation/Demos/UsingFXUnit.gif?raw=true "Using the FX panel")

### Chapters list and playback

![Chapters demo](/Documentation/Demos/ChaptersDemo.gif?raw=true "Chapters list and playback demo")

### Detailed track info

![App screenshot w/ more info view](/Documentation/Screenshots/DetailedInfo.png?raw=true "More Info")

### Changing the window layout

![App screenshot2](/Documentation/Demos/WindowLayout.gif?raw=true "Changing the window layout")

### Customizing the player view

![Player view](/Documentation/Demos/playerView.gif?raw=true "Player view")

## Third party code attributions

* [FFmpeg](https://www.ffmpeg.org/) (used to transcode from unsupported to supported audio formats)
* [MediaKeyTap](https://github.com/nhurden/MediaKeyTap) (used to respond to media keys)
* [RangeSlider](https://github.com/matthewreagan/RangeSlider) (used in the Filter effects unit to specify frequency ranges)

## Contributor attributions

Fellow GitHub member [dun198](https://github.com/dun198) made significant contributions towards this project - performance optimizations, UX improvements, etc.
