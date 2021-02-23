# Aural Player

### Update (Feb 18, 2021)

The very ambitious version 3.0 was in active development last year, but due to unforeseen personal circumstances, that part of the project has been put on hold since Oct 2020. The planned 3.0 release will be delayed.

Instead, I have worked to get Aural Player up and running on macOS Big Sur, and have been making small refinements and enhancements to version 2.x.

![App demo](/Documentation/Demos/mainDemo.gif?raw=true "App demo")

## Table of Contents
  * [Overview](#overview)
  * [Summary of features](#summary-of-features)
  * [Download](#download)
    + [Compatibility](#compatibility)
    + [Important note for macOS Big Sur](#important-note-for-macos-big-sur)
    + [Important note for anyone upgrading from v2.2.0 (or older) to v2.3.0 or newer app versions](#important-note-for-anyone-upgrading-from-v220-or-older-to-v230-or-newer-app-versions)
    + [Installation](#installation)
    + [Enabling media keys support](#enabling-media-keys-support-optional)
  * [Screenshots](#screenshots)
  * [Known issues](#known-issues)
  * [Documentation](#documentation)
  * [Contact Info](#contact-info)
  * [Third party code attributions](#third-party-code-attributions)
  * [Contributor attributions](#contributor-attributions)

## Overview

Aural Player is an audio player for macOS. Inspired by the classic Winamp player for Windows, it is designed to be to-the-point, easy to use, and customizable, with support for a wide variety of popular audio formats and some sound tuning capabilities for audio enthusiasts.

#### Goals:
* To have a simple drag-drop-play player for the music collection on your local drives, that requires no configuration out of the box, although plenty of customization/configuration is possible.
* To make sound tuning an integral part of the listening experience and to have it within quick and easy reach at all times.
* To have a decent macOS counterpart of Winamp.

#### Limitations:
* Does not play protected content (e.g. Apple's M4P or Audible's AAX).
* Does not integrate with online services for streaming / scrobbling, etc.

## Summary of features

(Comprehensive feature list [here](https://github.com/maculateConception/aural-player/wiki/Features))

* Supports all Core Audio formats (inc. FLAC) and several non-native formats: (inc. Vorbis, Opus, Monkey's Audio (APE), True Audio (TTA), DSD & [more](https://github.com/maculateConception/aural-player/wiki/Features#audio-formats))
* Supports M3U / M3U8 playlists
* **Playback:** Repeat / shuffle, bookmarking, segment looping, 2 custom seek intervals, last position memory, autoplay
* **Chapters support:** Chapters list window, playback functions including loop, current chapter indication, search by title
* **Effects:** Graphic equalizer, pitch shift, time stretch, reverb, delay, filter
  * Built-in and custom effects presets, per-track effects settings memory
  * Recording of clips with effects captured
* **Playlist:** Grouping, searching, sorting, type selection
* **Information:** ID3, iTunes, WMA, Vorbis Comment, ApeV2, and other metadata (when available). Cover art, lyrics, file system and audio data. Option to export.
* **Track lists:** *Favorites* list, *recently added* and *recently played* lists.
* **UI:** Font schemes (built-in and custom), color schemes (built-in and custom), window layout presets (built-in and custom), window snapping, collapsible UI components, adjustable text size.
* **Usability:** Configurable media keys support, swipe/scroll gesture recognition

## Download

### Compatibility

**User**: macOS 10.12 (Sierra) or later versions.

**Developer**: Swift 5 and XCode 11.

Download the DMG image (containing the app bundle) from the latest release [here](https://github.com/maculateConception/aural-player/releases/latest).

[See all releases](https://github.com/maculateConception/aural-player/releases)

**NOTE** - The ffmpeg source code (and build script / instructions) for each release can be found in the Source code archive (zip / tar) for the release, under **aural-player-x.y.z/Resources/ffmpeg** (when extracted).

### Important note for macOS Big Sur

If you're on macOS Big Sur, you must download v2.3.0 or later versions. No older app versions will run on macOS Big Sur.

### Important note for anyone upgrading from v2.2.0 (or older) to v2.3.0 or newer app versions

In order to circumvent the hassle of macOS security restrictions, the location where the app stores its persisted state has changed from *~/Documents* to *~/Music*. This means that if you are upgrading from an older version of Aural Player (v2.2.0 or older), you need to move your app state directory from *~/Documents* to *~/Music* (exact steps listed below). Otherwise, note that you will lose all your previously saved app settings (playlist, sound settings, favorites, history, color schemes, window layouts, etc).

Perform the following simple steps when upgrading from v2.2.0 or any older version to v2.3.0 or any newer version.

* Quit Aural Player v2.2.0 (or any older app version) if it is running.
* Move the folder named ***aural*** in your user's *Documents* folder, to your user's *Music* folder.
* Download/install Aural Player v2.3.0 (or any newer app version) and run it.

The contents of the "aural" folder should look like this:

![aural app state folder screenshot](https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Screenshots/auralDir2.png)

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
     
## Screenshots

### "Lava" color scheme, "Futuristic" font scheme, default window layout

![Vertical full stack window layout demo](/Documentation/Screenshots/FullStack.png?raw=true)

### Changing the font scheme

![Changing the font scheme demo](/Documentation/Demos/FontSchemes.gif?raw=true)

### Changing the color scheme

![Changing the color scheme demo](/Documentation/Demos/ChangingColorScheme.gif?raw=true)

### Customizing the player view

![Player view](/Documentation/Demos/playerView.gif?raw=true)

### Segment loop playback

![Segment loop playback demo](/Documentation/Demos/ABLoop.gif?raw=true)

### Enabling and disabling effects

![Enabling and disabling effects demo](/Documentation/Demos/UsingFXUnit.gif?raw=true)

### Detailed track info

![Detailed track info](/Documentation/Demos/DetailedInfo.gif?raw=true)

### Changing the window layout

![Changing the window layout demo](/Documentation/Demos/WindowLayout.gif?raw=true)

### Searching the playlist

![Searching the playlist demo](/Documentation/Demos/PlaylistSearch.gif?raw=true)

### Chapters support

![Chapters support demo](/Documentation/Demos/ChaptersDemo.gif?raw=true)

## Known issues

### 1 - The text is too small on my high resolution Mac screen !!!

The fix for this is easy. 

#### On v2.5.0 or newer versions: 

Go to the menu **View > Font scheme > Customize**, and increase the font sizes of the various UI textual elements, per your preference.

#### On v2.4.0 or older versions: 

Go to the menu **View > Font scheme > Customize**, and choose the ***Larger*** or ***Largest*** text size preset, per your preference.

### 2 - Bad audio quality when connecting Bluetooth headphones

If you notice poor audio quality when you first connect Bluetooth headphones, try the following:

**Fix# 1 - Set your system's input device to the built-in device**

When you connect Bluetooth headphones to your Mac, if your headphones have a microphone, the OS will typically switch to using your Bluetooth microphone as its input device. Simply go to **System Preferences > Sound > Input**, and change the input device back to your Mac's built-in input device.

This should fix the problem. If not, try Fix# 2.

**Fix# 2 - Change your system's Bluetooth audio codec settings**

Follow the steps clearly detailed [here](https://www.macrumors.com/how-to/enable-aptx-aac-bluetooth-audio-codecs-macos/).

## Documentation

All the documentation can be found on the [wiki](https://github.com/maculateConception/aural-player/wiki).

[How To's](https://github.com/maculateConception/aural-player/wiki/How-To's)

NOTE - The documentation is incomplete and is a work in progress.

## Contact info

Want to contact the developer ? Send an email to [aural.student@gmail.com](mailto:aural.student@gmail.com).

Any feedback, questions, issues, suggestions, or other comments related to the project are welcome ... spam is not :)

Of course, you may also file issues right here on GitHub as needed. I'm usually pretty good at responding to them, even if I'm not always able to fix them.


## Third party code attributions

* [FFmpeg](https://www.ffmpeg.org/) (used to transcode from unsupported to supported audio formats)
* [MediaKeyTap](https://github.com/nhurden/MediaKeyTap) (used to respond to media keys)
* [RangeSlider](https://github.com/matthewreagan/RangeSlider) (used in the Filter effects unit to specify frequency ranges)

## Contributor attributions

Fellow GitHub member [dun198](https://github.com/dun198) made significant contributions towards this project - performance optimizations, UX improvements, etc.
