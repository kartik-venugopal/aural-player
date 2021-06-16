<img width="225" src="https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Screenshots/readmeLogo.png"/>

![App demo](/Documentation/Demos/mainDemo.gif?raw=true "App demo")

### Update (June 16, 2021)

**M1 machines are now supported !**

[Version 3.0.0](https://github.com/maculateConception/aural-player/releases/tag/3.0.0) released, with support for M1 machines. I am asking for feedback from M1 Mac users to let me know if it works, since I do not have access to M1 hardware. Thanks !

## Table of Contents
  * [Overview](#overview)
  * [Summary of features](#summary-of-features)
  * [Download](#download)
    + [Compatibility](#compatibility)
    + [Important note for anyone upgrading from v2.2.0 (or older) to v2.3.0 or newer app versions](#important-note-for-anyone-upgrading-from-v220-or-older-to-v230-or-newer-app-versions)
    + [Installation](#installation)
    + [Enabling media keys support](#enabling-media-keys-support-optional)
  * [Screenshots](#screenshots)
  * [Known issues](#known-issues)
  * [Documentation](#documentation)
  * [Contact and conversation](#contact-and-conversation)
  * [Third party code attributions](#third-party-code-attributions)
  * [Contributor attributions](#contributor-attributions)

## Overview

Aural Player is an audio player for macOS. Inspired by the classic Winamp player for Windows, it is designed to be easy to use and customizable, with support for a wide variety of popular audio formats and powerful sound tuning capabilities for audio enthusiasts.

#### Goals:
* To have a simple drag-drop-play player for the music collection on your local drives, that is able to play a wide variety of audio formats.
* To *allow* customization/configuration, but not to *require* it out of the box.
* To make sound tuning an integral part of the listening experience and to have it within quick and easy reach at all times.
* To have a decent macOS Winamp counterpart.

#### Limitations:
* Does not play protected content (e.g. Apple's M4P or Audible's AAX).
* No streaming / scrobbling, etc.

## Summary of features

(Comprehensive feature list [here](https://github.com/maculateConception/aural-player/wiki/Features))

* Supports all [Core Audio formats](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html) and several non-native formats: (including FLAC, Vorbis, Opus, Monkey's Audio (APE), True Audio (TTA), DSD & [more](https://github.com/maculateConception/aural-player/wiki/Features#audio-formats))
* Supports M3U / M3U8 playlists
* **Playback:** Repeat / shuffle, bookmarking, segment looping, 2 custom seek intervals, last position memory, autoplay
* **Chapters support:** Chapters list window, playback functions including loop, current chapter indication, search by title
* **Effects:** 
  * **Built-in effects:** Graphic equalizer, pitch shift, time stretch, reverb, delay, filter
  * Hosts Audio Units (AU) plug-ins, providing unlimited possibilities for advanced sound tweaking and monitoring / analysis
  * Built-in and custom effects presets, per-track effects settings memory
  * Recording of clips with effects captured
* **Playlist:** Grouping by artist/album/genre, searching, sorting, type selection
* **Information:** ID3, iTunes, WMA, Vorbis Comment, ApeV2, and other metadata (when available). Cover art (with MusicBrainz lookups), lyrics, file system and audio data. Option to export.
* **Track lists:** *Favorites* list, *recently added* and *recently played* lists.
* **Visualizations:** 3 different visualizations that dance to the music, with customizable colors.
* **UI:** 
  * Winamp-like modular interface. 
  * Fully customizable fonts and colors with built-in and custom schemes.
  * Menu bar mode to run the app in the macOS menu bar.
  * Window layouts (built-in and custom), window snapping, collapsible UI components.
* **Usability:** Configurable media keys support, swipe/scroll gesture recognition

## Download

### Compatibility

This table lists the ***minimum*** required Aural Player version for your hardware and macOS version. It is always recommended to use the [latest](https://github.com/maculateConception/aural-player/releases/latest) app version, regardless of your hardware / macOS version.

|              | Intel (x86_64)  | M1 (arm64)|
| :---:        | :-:             | :-:       |
| macOS 10.12 - macOS 10.15 | [1.0.0](https://github.com/maculateConception/aural-player/releases/tag/v1.0.0)           | [3.0.0](https://github.com/maculateConception/aural-player/releases/tag/3.0.0)     |
| macOS 11.x (Big Sur)  | [2.3.0](https://github.com/maculateConception/aural-player/releases/tag/2.3.0)           | [3.0.0](https://github.com/maculateConception/aural-player/releases/tag/3.0.0)    |

**NOTE:** Version 3.0.0 and all subsequent releases are universal binaries, i.e. capable of running on both Intel and M1 Macs.

[Latest release](https://github.com/maculateConception/aural-player/releases/latest)

[See all releases](https://github.com/maculateConception/aural-player/releases)

**Developer requirements**: Swift 5 and XCode 12.2+.

[Source code zip archive](https://github.com/maculateConception/aural-player/archive/refs/heads/master.zip)

### Important note for anyone upgrading from v2.2.0 (or older) to v2.3.0 or newer app versions

In order to circumvent the hassle of macOS security restrictions, the location where the app stores its persisted state has changed from *~/Documents* to *~/Music*. This means that if you are upgrading from an older version of Aural Player (v2.2.0 or older), you need to move your app state directory from *~/Documents* to *~/Music* (exact steps listed below). Otherwise, note that you will lose all your previously saved app settings (playlist, sound settings, favorites, history, color schemes, window layouts, etc).

Perform the following simple steps when upgrading from v2.2.0 or any older version to v2.3.0 or any newer version.

* Quit Aural Player v2.2.0 (or any older app version) if it is running.
* Move the folder named ***aural*** in your user's *Documents* folder, to your user's *Music* folder.
* Download/install Aural Player v2.3.0 (or any newer app version) and run it.
* Verify that your previous app settings have been carried over to the new version - playlist tracks, window layouts, color schemes, history, favorites, bookmarks, etc. If not, please file an issue, and I will help you restore your previous app settings (this should not happen, but just in case).

The contents of the "aural" folder should look like this:

![aural app state folder screenshot](https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Screenshots/auralDir2.png)

### Installation

1. Mount the **AuralPlayer-x.y.z.dmg** image file
2. From within the mounted image, copy **Aural.app** to your local drive (e.g. Applications folder)
3. Run the copy from your local drive. You will likely see a security warning and the app will not open because the app's developer is not recognized by macOS.
4. Go to **System Preferences > Security & Privacy > General > Open anyway**, to allow Aural.app to open.

NOTE - Please ***don't*** run the app directly from within the image. It is a compressed image, and may result in the app behaving slowly and/or unpredictably. So, copy it outside and run the copy.

### Enabling media keys support (optional)

Follow the steps listed [here](https://github.com/maculateConception/aural-player/wiki/Enabling-media-keys-support)
     
## Screenshots

### "Lava" color scheme, "Futuristic" font scheme, default window layout

![Vertical full stack window layout screenshot](/Documentation/Screenshots/FullStack.png?raw=true)

### Hosting Audio Units (AU) plug-in "TDR Nova" Equalizer by Tokyo Dawn Labs

![Audio Units demo GIF](/Documentation/Demos/AU-Demo.gif?raw=true)

### Running in Menu Bar mode

![Menu Bar Player screenshot](/Documentation/Screenshots/MenuBarPlayer.png?raw=true)

### Visualizer

<img width="530" src="https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Demos/Visualizer.gif"/>

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

Go to the menu **View > Font scheme > Customize**, and either increase the font sizes of the various UI textual elements, and/or choose different font faces, per your preference.

#### On v2.4.0 or older versions: 

Go to the menu **View > Text Size**, and choose the ***Larger*** or ***Largest*** text size preset, per your preference.

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

## Contact and conversation

Aural Player is now on Twitter: https://twitter.com/AuralPlayer ! Follow me there for informal updates or to provide feedback or start a conversation about features you'd like to see or bugs you've encountered (in addition to GitHub issues, of course).

You can also contact me via email: [aural.student@gmail.com](mailto:aural.student@gmail.com).

Any feedback, questions, issues, suggestions, or other comments related to the project are welcome ... spam is not :)

Of course, you may also file issues right here on GitHub as needed. I'm usually pretty good at responding to them, even if I'm not always able to fix them.

## Third party code attributions

* [FFmpeg](https://www.ffmpeg.org/) (used to decode audio formats not natively supported on macOS)
* [MediaKeyTap](https://github.com/nhurden/MediaKeyTap) (used to respond to media keys)
* [RangeSlider](https://github.com/matthewreagan/RangeSlider) (used in the Filter effects unit to specify frequency ranges)

## Contributor attributions

App user [yougotwill](https://github.com/yougotwill) made numerous suggestions for improvements and features, provided a lot of valuable feedback, and designed the Poolside.fm theme.

Fellow GitHub member [dun198](https://github.com/dun198) made significant contributions towards this project - performance optimizations, UX improvements, etc.
