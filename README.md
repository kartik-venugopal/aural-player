<img width="225" src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master/Documentation/Screenshots/readmeLogo.png"/>

![App demo](/Documentation/Demos/mainDemo.gif?raw=true "App demo")

**Watch out for v4.0 - an improved app version, expected to come out later this year ! Read about it [here](https://github.com/kartik-venugopal/aural-player/tree/v4.0).**

## Table of Contents
  * [Overview](#overview)
    + [How it works (under the hood)](#how-it-works-under-the-hood)
    + [Limitations](#limitations)
  * [Key features](#key-features)
    + [Roadmap](#roadmap)
    + [Version 4.0](#version-40)
  * [Download](#download)
    + [Compatibility](#compatibility)
    + [Installation](#installation)
    + [Media keys support](#media-keys-support)
  * [Building the app](#building-the-app)
  * [Documentation](#documentation)
  * [Screenshots](#screenshots)
  * [Known issues (and solutions)](#known-issues-and-solutions)
  * [Contact and conversation](#contact-and-conversation)
  * [How to contribute](#how-to-contribute)
  * [Third party code attributions](#third-party-code-attributions)
  * [Contributor attributions](#contributor-attributions)
  * [License](#license)

## Overview

Aural Player is an audio player for macOS. Inspired by the classic Winamp player for Windows, it is designed to be easy to use and customizable, with support for a wide variety of popular audio formats and powerful sound tuning capabilities.

| Flexible UI  | Personalization |
| :-- | --: |
|  <img src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master/Documentation/Demos/Aural-Modularity.gif" width="500" />| <img src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master/Documentation/Demos/Aural-Customization.gif" width="300" /> |
| With Winamp-like modularity and multiple app presentation modes, you can lay out the app to suit your workspace, reduce it to a tiny widget, or tuck it away in the macOS menu bar. | Personalize Aural Player with exactly the colors and fonts that define your creative tastes. |

| Extensive audio formats support  | Sound tuning and monitoring |
| :-- | --: |
|  <img src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master/Documentation/Demos/Aural-AudioFormats.gif" width="150" />| <img src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master/Documentation/Demos/Aural-Effects.gif" width="700" /> |
| By harnessing the power of FFmpeg, Aural Player supports a wide variety of popular audio formats, in addition to all macOS Core Audio formats. | With several built-in effects and support for Audio Unit (AU) plug-ins, sound tuning and monitoring possibilities are endless. |

### How it works (under the hood)

Aural Player uses **AVFoundation's AVAudioEngine** framework (and some low-level **Core Audio**) for playback, effects, and visualization, and uses **FFmpeg** libraries to decode formats not native to macOS.

It is written entirely in Swift (approximately 100,000 lines of code).

<img src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master/Documentation/Diagrams/UnderTheHood.png" alt="How it works screenshot" width="850" />

Read more about it [here](https://github.com/kartik-venugopal/aural-player/wiki/Developer-reference).

### Limitations

* Currently, Aural does not play online streams. However, this feature has been requested and I am strongly considering implementing it for version 4.x.
* Aural does not play protected content (for example, Apple's M4P or Audible's AAX). There are no plans to implement this.

## Key features

(Comprehensive feature list [here](https://github.com/kartik-venugopal/aural-player/wiki/Features))

* Supports all [Core Audio formats](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html) and several non-native formats: (including FLAC, Vorbis, Monkey's Audio (APE), Opus, & [many more](https://github.com/kartik-venugopal/aural-player/wiki/Features#audio-formats))
* Supports M3U / M3U8 playlists
* **Playback:** Bookmarking, segment looping, custom seek intervals, last position memory, chapters support, autoplay.
* **Effects:** Built-in effects (incl. equalizer), Audio Unit (AU) plug-in support, built-in / custom presets, per-track settings memory.
* **Playlist:** Grouping by artist/album/genre, searching, sorting, type selection.
* **Information:** ID3, iTunes, WMA, Vorbis Comment, ApeV2, etc. Cover art (with MusicBrainz lookups), lyrics, file system and audio data. Option to export.
* **Track lists:** *Favorites* list, *recently added* and *recently played* lists.
* **Visualizer:** 3 different visualizations that dance to the music, with customizable colors.
* **UI:** Modular interface, fully customizable fonts and colors (with gradients), built-in / custom window layouts, configurable window snapping / docking / spacing / corner radius, menu bar mode, control bar (widget) mode.
* **Usability:** Configurable media keys support, swipe/scroll gesture recognition, remote control from Control Center, headphones, and media control devices / apps.

### Roadmap

#### Version 4.0

As of May 21, 2022, version 4.0 is in active development, and may bring several improvements.

Interested in seeing what's going on with the development of v4.0 ? Check out [the v4.0 branch](https://github.com/kartik-venugopal/aural-player/tree/v4.0)!

------------------------------------------------------

In addition to v4.0, the following features ***may be*** implemented in the future:

- Replay gain.
- Crossfading between tracks.
- Gapless playback.

#### Other goals

- More extensive unit testing.
- More comprehensive documentation.
- Better source code commenting.

## Download

[Latest release](https://github.com/kartik-venugopal/aural-player/releases/latest)

[See all releases](https://github.com/kartik-venugopal/aural-player/releases)

### Compatibility

This table lists the ***minimum*** required Aural Player version for your hardware and macOS version. It is always recommended to use the [latest](https://github.com/kartik-venugopal/aural-player/releases/latest) app version, regardless of your hardware / macOS version.

|              | Intel (x86_64)  | Apple silicon (arm64)|
| :---:        | :-:             | :-:       |
| macOS 10.12 - 10.15 | [1.0.0](https://github.com/kartik-venugopal/aural-player/releases/tag/v1.0.0)           | (N/A)     |
| macOS 11.x (Big Sur)  | [2.3.0](https://github.com/kartik-venugopal/aural-player/releases/tag/2.3.0)           | [3.0.0](https://github.com/kartik-venugopal/aural-player/releases/tag/3.0.0)    |
| macOS 12.x (Monterey)  | [2.3.0](https://github.com/kartik-venugopal/aural-player/releases/tag/2.3.0)           | [3.0.0](https://github.com/kartik-venugopal/aural-player/releases/tag/3.0.0)    |

**NOTES:** 

* Version 3.0.0 and all subsequent releases are universal binaries, i.e. capable of running on both Intel and Apple Silicon Macs.

* Due to limited time, I can only officially support macOS Big Sur and Monterey going forward. The app should still work on older systems (going back to Sierra), but I can no longer make guarantees or troubleshoot issues on older systems.

### Installation

1. Mount the **AuralPlayer-x.y.z.dmg** image file.
2. From within the mounted image, copy **Aural.app** to your local drive (e.g. **Applications** folder).
3. Run the copy from your local drive. You will likely see a security warning and the app will not open because the app's developer is not recognized by macOS.
4. Go to **System Preferences > Security & Privacy > General > Open anyway**, to allow Aural.app to open.

NOTE - Please ***don't*** run the app directly from within the image. Copy it outside and run the copy.

### Media keys support

Your Mac media keys should work with Aural right out of the box (assuming you granted Aural Accessibility permissions on first app launch), but if for some reason the media keys don't work, follow the steps listed [here](https://github.com/kartik-venugopal/aural-player/wiki/Enabling-media-keys-support).

## Building the app

All you need is Xcode 12.2+ and the [source code](https://github.com/kartik-venugopal/aural-player/releases/latest) (a working knowledge of Swift would help !). It is recommended to use the source code from the latest release (as opposed to the master branch) as code between releases can be buggy / unstable.

Read the [quick start guide](https://github.com/kartik-venugopal/aural-player/wiki/Building-and-running-Aural-Player-(quick-start-guide)) for more details.

## Documentation

All the documentation can be found on the [wiki](https://github.com/kartik-venugopal/aural-player/wiki).

#### Some pages to get you started

[How To's](https://github.com/kartik-venugopal/aural-player/wiki/How-To's)

[Handy keyboard shortcuts](https://github.com/kartik-venugopal/aural-player/wiki/Handy-keyboard-shortcuts)

[Building and running Aural Player (quick start guide)](https://github.com/kartik-venugopal/aural-player/wiki/Building-and-running-Aural-Player-(quick-start-guide))

[Developer reference](https://github.com/kartik-venugopal/aural-player/wiki/Developer-reference)
     
## Screenshots

### Custom color scheme w/ main controls hidden

![Vertical full stack window layout screenshot](/Documentation/Screenshots/FullStack.png?raw=true)

### Expanded Art player view

![Expanded Art player view demo](/Documentation/Demos/expandedArtView.gif?raw=true)

### Hosting Audio Units (AU) plug-in "TDR Nova" Equalizer by Tokyo Dawn Labs

![Audio Units demo GIF](/Documentation/Demos/AU-Demo.gif?raw=true)

### Running in Menu Bar mode

![Menu Bar Player screenshot](/Documentation/Screenshots/MenuBarPlayer.png?raw=true)

### Running in Control Bar mode

![Control Bar Player screenshot](/Documentation/Screenshots/ControlBar1.png?raw=true)

### Control Center integration (macOS Big Sur)

<img width="700" src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master//Documentation/Screenshots/ControlCenter1.png" alt="Control Center integration 1 screenshot"/>

<img width="700" src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master//Documentation/Screenshots/ControlCenter2.png" alt="Control Center integration 2 screenshot"/>

### Font schemes

![Font schemes demo](/Documentation/Demos/FontSchemes.gif?raw=true)

### Color schemes

![Color schemes demo](/Documentation/Demos/ColorSchemes.gif?raw=true)

### Customizing the player view

![Player view](/Documentation/Demos/playerView.gif?raw=true)

### Customizing the window corner radius (up to 25px)

![Window corner radius demo](/Documentation/Demos/customCornerRadius.gif?raw=true)

### Enabling and disabling effects

![Enabling and disabling effects demo](/Documentation/Demos/UsingFXUnit.gif?raw=true)

### Segment loop playback

![Segment loop playback demo](/Documentation/Demos/ABLoop.gif?raw=true)

### Detailed track info

![Detailed track info](/Documentation/Demos/DetailedInfo.gif?raw=true)

### Changing the window layout

![Changing the window layout demo](/Documentation/Demos/WindowLayout.gif?raw=true)

### Visualizer

<img width="530" src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master/Documentation/Demos/Visualizer.gif"/>

## Known issues (and solutions)

* [The text is too small on my Mac screen.](https://github.com/kartik-venugopal/aural-player/wiki/App-text-is-too-small-on-my-Mac-screen)

* [Poor audio quality when using Bluetooth headsets.](https://github.com/kartik-venugopal/aural-player/wiki/Poor-audio-quality-when-using-Bluetooth-headsets)

* [My media keys don't work with Aural Player](https://github.com/kartik-venugopal/aural-player/wiki/My-media-keys-don't-work-with-Aural-Player)

## Contact and conversation

**Email:** [kartikv2017@gmail.com](mailto:kartikv2017@gmail.com)

**GitHub Issues** https://github.com/kartik-venugopal/aural-player/issues.

The app is what it is today largely thanks to the numerous bug reports and valuable feedback of users over the years. I urge you to file issues for any bugs you encounter or for features / behavior you would like to see implemented. I am generally pretty good at responding to issues, and at the very least, I will read, contemplate, and respond.

## How to contribute

Interested in contributing to this awesome project ?!

I would love to localize Aural Player so that it is more comfortable to use for users who prefer other languages. I could definitely use help translating Aural Player's text into languages such as German, French, Spanish, Italian, Chinese, Japanese, etc (and any others that you can help with).

Please [email me](mailto:kartikv2017@gmail.com) if you're interested in helping with this !

NOTE - I am ***not*** looking for help with app development at the moment, but if this changes, I will post an update.

## Third party code attributions

* [FFmpeg](https://www.ffmpeg.org/) (used to decode audio formats not natively supported on macOS)
* [MediaKeyTap](https://github.com/nhurden/MediaKeyTap) (used to respond to media keys)
* [RangeSlider](https://github.com/matthewreagan/RangeSlider) (used in the Filter effects unit to specify frequency ranges)

## Contributor attributions

App user [yougotwill](https://github.com/yougotwill) made numerous suggestions for improvements and features, provided a lot of valuable feedback, and designed the Poolside.fm theme.

Fellow GitHub member [dun198](https://github.com/dun198) made significant contributions towards this project - performance optimizations, UX improvements, etc.

I am also hugely grateful to all the app users who have filed bug reports and feature requests, and provided valuable feedback.

## License

Aural Player (in both forms - source code and binary) is available for use under the [MIT license](https://github.com/kartik-venugopal/aural-player/blob/master/LICENSE).
