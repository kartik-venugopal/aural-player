<img width="225" src="https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Screenshots/readmeLogo.png"/>

![App demo](/Documentation/Demos/mainDemo.gif?raw=true "App demo")

### Update (June 16, 2021)

**Machines with Apple silicon (M1) are now supported !**

[Try it out](https://github.com/maculateConception/aural-player/releases/latest).

## Table of Contents
  * [Overview](#overview)
    + [How it works (under the hood)](#how-it-works-under-the-hood)
  * [Summary of features](#summary-of-features)
  * [Download](#download)
    + [Compatibility](#compatibility)
    + [Installation](#installation)
    + [Enabling media keys support](#enabling-media-keys-support-optional)
    + [Important note for anyone upgrading from v2.2.0 (or older) to v2.3.0 or newer app versions](#important-note-for-anyone-upgrading-from-v220-or-older-to-v230-or-newer-app-versions)
  * [Building and running the app](#building-and-running-the-app)
  * [Documentation](#documentation)
  * [Screenshots](#screenshots)
  * [Known issues (and solutions)](#known-issues-and-solutions)
  * [Contact and conversation](#contact-and-conversation)
  * [Third party code attributions](#third-party-code-attributions)
  * [Contributor attributions](#contributor-attributions)
  * [License](#license)

## Overview

Aural Player is an audio player for macOS. Inspired by the classic Winamp player for Windows, it is designed to be easy to use and customizable, with support for a wide variety of popular audio formats and powerful sound tuning capabilities for audio enthusiasts.

| Flexibility  | Personalization |
| :-- | --: |
|  <img src="https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Demos/Aural-Modularity.gif" width="500" />| <img src="https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Demos/Aural-Customization.gif" width="300" /> |
| With Winamp-like modularity and multiple app presentation modes, you can lay out the app to suit your workspace or tuck it away in the macOS menu bar. | Personalize Aural Player with exactly the colors and fonts that define your creative tastes. |

| Extensive Audio Formats Support  | Sound tweaking and monitoring |
| :-- | --: |
|  <img src="https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Demos/Aural-AudioFormats.gif" width="150" />| <img src="https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Demos/Aural-Effects.gif" width="700" /> |
| By harnessing the power of FFmpeg, Aural Player supports a wide variety of popular audio formats, in addition to all macOS Core Audio formats. | With several built-in effects and support for Audio Units (AU) plug-ins, sound tweaking and monitoring possibilities are endless. |

### How it works (under the hood)

Aural Player consists of approximately 100,000 lines of Swift code. It uses **AVFoundation's AVAudioEngine** framework for playback, effects, and visualization, and uses **FFmpeg** libraries to decode formats not native to macOS.

<img src="https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Diagrams/UnderTheHood.png" alt="How it works screenshot" width="850" />

## Summary of features

(Comprehensive feature list [here](https://github.com/maculateConception/aural-player/wiki/Features))

* Supports all [Core Audio formats](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html) and several non-native formats: (including FLAC, Vorbis, Opus, Monkey's Audio (APE), True Audio (TTA), DSD & [more](https://github.com/maculateConception/aural-player/wiki/Features#audio-formats))
* Supports M3U / M3U8 playlists
* **Playback:** Repeat / shuffle, bookmarking, segment looping, 2 custom seek intervals, last position memory, chapters support, autoplay.
* **Effects:**
  * Built-in effects: Graphic equalizer, pitch shift, time stretch, reverb, delay, filter.
  * Hosts Audio Units (AU) plug-ins, for advanced sound tweaking and monitoring / analysis.
  * Built-in and custom effects presets, per-track effects settings memory.
* **Playlist:** Grouping by artist/album/genre, searching, sorting, type selection.
* **Information:** ID3, iTunes, WMA, Vorbis Comment, ApeV2, and other metadata (when available). Cover art (with MusicBrainz lookups), lyrics, file system and audio data. Option to export.
* **Track lists:** *Favorites* list, *recently added* and *recently played* lists.
* **Visualizations:** 3 different visualizations that dance to the music, with customizable colors.
* **UI:** 
  * Winamp-like modular interface with 3 different app modes.
  * Fully customizable fonts and colors with built-in and custom schemes.
  * Window layouts (built-in and custom), window snapping, collapsible UI components.
  * Menu bar mode to run the app in the macOS menu bar.
  * Control bar mode to run the app as a floating widget with essential controls.
* **Usability:** 
  * Configurable media keys support.
  * Swipe/scroll gesture recognition.
  * Remote control (control the app from Control Center, headphones, or other media control devices / apps).

## Download

### Compatibility

This table lists the ***minimum*** required Aural Player version for your hardware and macOS version. It is always recommended to use the [latest](https://github.com/maculateConception/aural-player/releases/latest) app version, regardless of your hardware / macOS version.

|              | Intel (x86_64)  | Apple silicon (arm64)|
| :---:        | :-:             | :-:       |
| macOS 10.12 - 10.15 | [1.0.0](https://github.com/maculateConception/aural-player/releases/tag/v1.0.0)           | (N/A)     |
| macOS 11.x (Big Sur)  | [2.3.0](https://github.com/maculateConception/aural-player/releases/tag/2.3.0)           | [3.0.0](https://github.com/maculateConception/aural-player/releases/tag/3.0.0)    |

**NOTE:** Version 3.0.0 and all subsequent releases are universal binaries, i.e. capable of running on both Intel and M1 Macs.

[Latest release](https://github.com/maculateConception/aural-player/releases/latest)

[See all releases](https://github.com/maculateConception/aural-player/releases)

### Installation

1. Mount the **AuralPlayer-x.y.z.dmg** image file
2. From within the mounted image, copy **Aural.app** to your local drive (e.g. Applications folder)
3. Run the copy from your local drive. You will likely see a security warning and the app will not open because the app's developer is not recognized by macOS.
4. Go to **System Preferences > Security & Privacy > General > Open anyway**, to allow Aural.app to open.

NOTE - Please ***don't*** run the app directly from within the image. It is a compressed image, and may result in the app behaving slowly and/or unpredictably. So, copy it outside and run the copy.

### Enabling media keys support (optional)

Follow the steps listed [here](https://github.com/maculateConception/aural-player/wiki/Enabling-media-keys-support)

### Important note for anyone upgrading from v2.2.0 (or older) to v2.3.0 or newer app versions

Please read [this important note](https://github.com/maculateConception/aural-player/wiki/Important-note-for-anyone-upgrading-from-v2.2.0-(or-older)-to-v2.3.0-or-newer-app-versions), otherwise you will lose your previous app settings.

## Building and running the app

All you need is Xcode 12.2+ and the [source code](https://github.com/maculateConception/aural-player/releases/latest) (a working knowledge of Swift would help !). It is recommended to use the source code from the latest release (as opposed to the master branch) as code between releases can be buggy / unstable.

Read the [quick start guide](https://github.com/maculateConception/aural-player/wiki/Building-and-running-Aural-Player-(quick-start-guide)) for more details.

## Documentation

All the documentation can be found on the [wiki](https://github.com/maculateConception/aural-player/wiki).

#### Some pages to get you started

[How To's](https://github.com/maculateConception/aural-player/wiki/How-To's)

[Handy keyboard shortcuts](https://github.com/maculateConception/aural-player/wiki/Handy-keyboard-shortcuts)

[Building and running Aural Player (quick start guide)](https://github.com/maculateConception/aural-player/wiki/Building-and-running-Aural-Player-(quick-start-guide))

[Developer reference](https://github.com/maculateConception/aural-player/wiki/Developer-reference)
     
## Screenshots

### "Lava" color scheme, "Futuristic" font scheme, default window layout

![Vertical full stack window layout screenshot](/Documentation/Screenshots/FullStack.png?raw=true)

### Hosting Audio Units (AU) plug-in "TDR Nova" Equalizer by Tokyo Dawn Labs

![Audio Units demo GIF](/Documentation/Demos/AU-Demo.gif?raw=true)

### Running in Menu Bar mode

![Menu Bar Player screenshot](/Documentation/Screenshots/MenuBarPlayer.png?raw=true)

### Running in Control Bar mode

![Control Bar Player screenshot](/Documentation/Screenshots/ControlBar1.png?raw=true)

### Control Center integration (macOS Big Sur)

![Control Center integration 1 screenshot](/Documentation/Screenshots/ControlCenter1.png?raw=true)

![Control Center integration 2 screenshot](/Documentation/Screenshots/ControlCenter2.png?raw=true)

### Changing the font scheme

![Changing the font scheme demo](/Documentation/Demos/FontSchemes.gif?raw=true)

### Changing the color scheme

![Changing the color scheme demo](/Documentation/Demos/ChangingColorScheme.gif?raw=true)

### Customizing the player view

![Player view](/Documentation/Demos/playerView.gif?raw=true)

### Enabling and disabling effects

![Enabling and disabling effects demo](/Documentation/Demos/UsingFXUnit.gif?raw=true)

### Segment loop playback

![Segment loop playback demo](/Documentation/Demos/ABLoop.gif?raw=true)

### Detailed track info

![Detailed track info](/Documentation/Demos/DetailedInfo.gif?raw=true)

### Changing the window layout

![Changing the window layout demo](/Documentation/Demos/WindowLayout.gif?raw=true)

### Visualizer

<img width="530" src="https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Demos/Visualizer.gif"/>

## Known issues (and solutions)

* [The text is too small on my Mac screen.](https://github.com/maculateConception/aural-player/wiki/App-text-is-too-small-on-my-Mac-screen)

* [Poor audio quality when using Bluetooth headsets.](https://github.com/maculateConception/aural-player/wiki/Poor-audio-quality-when-using-Bluetooth-headsets)

* [My media keys don't work with Aural Player](https://github.com/maculateConception/aural-player/wiki/My-media-keys-don't-work-with-Aural-Player)

## Contact and conversation

I encourage you to provide feedback or start a conversation about features you'd like to see implemented, bugs you've encountered, or suggestions for improvement.

**Twitter:** https://twitter.com/AuralPlayer. I will try to post informal updates there.

**Email:** [aural.student@gmail.com](mailto:aural.student@gmail.com)

**GitHub Issues** https://github.com/maculateConception/aural-player/issues. I'm usually pretty good at responding to issues, even if I'm not always able to fix them.

## Third party code attributions

* [FFmpeg](https://www.ffmpeg.org/) (used to decode audio formats not natively supported on macOS)
* [MediaKeyTap](https://github.com/nhurden/MediaKeyTap) (used to respond to media keys)
* [RangeSlider](https://github.com/matthewreagan/RangeSlider) (used in the Filter effects unit to specify frequency ranges)

## Contributor attributions

App user [yougotwill](https://github.com/yougotwill) made numerous suggestions for improvements and features, provided a lot of valuable feedback, and designed the Poolside.fm theme.

Fellow GitHub member [dun198](https://github.com/dun198) made significant contributions towards this project - performance optimizations, UX improvements, etc.

## License

Aural Player (in both forms - source code and binary) is available for use under the [MIT license](https://github.com/maculateConception/aural-player/blob/master/LICENSE).
