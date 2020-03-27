# Aural Player

![App demo](/Documentation/Demos/demo.gif?raw=true "App demo")

## Table of Contents
  * [Overview](#overview)
  * [Download](#download)
    + [Installation](#installation)
    + [Enabling media keys support](#enabling-media-keys-support-available-with-version-130-onwards)
    + [Compatibility](#compatibility)
  * [Feature highlights](#feature-highlights)
  * [Planned updates](#planned-updates)
  * [Screenshots](#screenshots)
  * [Third party code attributions](#third-party-code-attributions)
  * [Contributor attributions](#contributor-attributions)

## Overview

Aural Player is an audio player for macOS. Inspired by the classic Winamp player for Windows, it is designed to be to-the-point, easy to use, and customizable, with some sound tuning capabilities for audio enthusiasts.

#### What it is:
* A simple drag-drop-play player for the music collection on your local hard drive(s), that requires no configuration out of the box, although plenty of customization/configuration is possible
* (I hope) A decent macOS alternative for Winamp (you be the judge).

#### What it is not (at the moment):
* A streaming audio player that connects to internet radio stations/services
* A scrobbler

## Download

Download the latest release [here](https://github.com/maculateConception/aural-player/releases/latest).

[See all releases](https://github.com/maculateConception/aural-player/releases)

### Installation

1. Mount the *AuralPlayer-x.y.z.dmg* image file
2. Copy Aural.app to your local drive (e.g. Applications folder)
3. Run the copied app. You will likely see a security warning and the app will not open because the app's developer is not recognized by macOS.
4. Go to System Preferences > Security & Privacy > General > Open anyway, to allow Aural.app to open.

NOTE - Please ***don't*** run the app directly from within the image. It is a compressed image, and may result in the app behaving slowly and/or unpredictably. So, copy it outside and run the copy.

### Enabling media keys support (available with version 1.3.0 onwards)


![Enabling media keys support](/Documentation/Screenshots/EnablingMediaKeys.png?raw=true "Enabling media keys support")

1. Quit Aural Player if it is running.
2. Go to System Preferences > Security & Privacy > Privacy, and select Accessibility from the list of features.
3. Click on the lock icon in the bottom left corner, if it is shown as locked. Enter your macOS password to authenticate.
4. Click the + button and select Aural.app in the file browser that opens, to add Aural Player to the list of apps allowed to control your computer. See image above.

### Compatibility

**User**: macOS 10.12 (Sierra) or later versions

**Developer**: (Swift 4.2) macOS 10.13.4 (High Sierra) or later, and XCode 10

## Feature highlights

(Comprehensive feature list [[here|Features]])

* Supports all Core Audio formats (inc. FLAC) and several non-native formats: (inc. Vorbis, Opus, WMA, DTS, & more)
* Supports M3U / M3U8 playlists
* **Playback:** Bookmarking, segment looping, 2 custom seek intervals, delayed playback, last position memory, timed gaps, autoplay
* **Effects:** Graphic equalizer, pitch shift, time stretch, reverb, delay, filter
* Custom effects presets, per-track settings memory
* Recording of clips with effects captured
* **Information:** ID3, iTunes, WMA, Vorbis Comment, ApeV2, and other metadata (when available). Cover art, lyrics, file system and audio data. Option to export.
* **Playlist:** Grouping, searching, sorting, type selection
* **Track lists:** *Favorites* list, *recently added* and *recently played* lists.
* **UI:** Window layout presets (built-in and custom), window snapping, collapsible UI components, adjustable text size.
* **Usability:** Configurable media keys support, gesture recognition
      
## Screenshots

### Default view

![App screenshot](/Documentation/Screenshots/Default.png?raw=true "App screenshot")

### Track segment loop playback (red segment on seek bar)

![App screenshot](/Documentation/Screenshots/SegmentLoop.png?raw=true "Track segment loop playback")

### Using the Effects panel to disable/enable effects

![App screenshot2](/Documentation/Demos/UsingFXUnit.gif?raw=true "Using the FX panel")

### Adjusting text size for better readability (esp. with large display resolutions)

![App screenshot2](/Documentation/Demos/textScaling.gif?raw=true "Text scaling")

### Transcoding of non-natively supported tracks (e.g. WMA/OGG)

![Transcoding](/Documentation/Demos/Transcoding.gif?raw=true "Transcoding")

### Delayed track playback

![App screenshot2](/Documentation/Demos/delayedPlayback.gif?raw=true "Delayed playback")

### Insertings gaps of silence around tracks

![App screenshot2](/Documentation/Demos/gaps.gif?raw=true "Playback gaps")

### Detailed track info popover

![App screenshot w/ more info view](/Documentation/Screenshots/DetailedInfo.png?raw=true "More Info")

#### Lyrics display

![App screenshot w/ lyrics view](/Documentation/Screenshots/Lyrics.png?raw=true "Lyrics")

### Bookmarking

![App screenshot w/ more info view](/Documentation/Screenshots/Bookmarking.png?raw=true "Bookmarking")

### Saving an effects unit preset

![App screenshot w/ more info view](/Documentation/Screenshots/FXPreset.png?raw=true "Saving an effects preset")

### Changing the window layout with one click

![App screenshot2](/Documentation/Demos/WindowLayout.gif?raw=true "Choosing a window layout")

### Customizing the player view

![Player view](/Documentation/Demos/playerView.gif?raw=true "Player view")

### Equalizer effects unit

![EQ](/Documentation/Screenshots/EQ.png?raw=true "Equalizer")

### Filter effects unit

![Filter](/Documentation/Screenshots/Filter1.png?raw=true "Filter")
![Filter](/Documentation/Screenshots/Filter2.png?raw=true "Filter")

### Delay effects unit

![Delay](/Documentation/Screenshots/Delay.png?raw=true "Delay")

### Playlist search

![Playlist search](/Documentation/Screenshots/Search.png?raw=true "Playlist Search")

## Third party code attributions

* [FFmpeg](https://www.ffmpeg.org/) (used to transcode from unsupported to supported audio formats)
* [MediaKeyTap](https://github.com/nhurden/MediaKeyTap) (used to respond to media keys)
* [RangeSlider](https://github.com/matthewreagan/RangeSlider) (used in the Filter effects unit to specify frequency ranges)

## Contributor attributions

Fellow GitHub member [dun198](https://github.com/dun198) made significant contributions towards this project - performance optimizations, UX improvements, etc.
