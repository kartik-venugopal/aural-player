<img width="225" src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master/Documentation/Screenshots/readmeLogo.png"/>

![App demo](/Documentation/aural4-modes.png?raw=true "App demo")

## Table of Contents
  * [Overview](#overview)
  * [Key features](#key-features)
    + [Roadmap](#roadmap)
  * [How it works (under the hood)](#how-it-works-under-the-hood)
    + [Limitations](#limitations)
  * [Download](#download)
    + [Compatibility](#compatibility)
    + [Media keys support](#media-keys-support)
  * [Building the app](#building-the-app)
  * [Documentation](#documentation)
  * [Known issues (and solutions)](#known-issues-and-solutions)
  * [Contact and conversation](#contact-and-conversation)
  * [Third party code attributions](#third-party-code-attributions)
  * [Contributor attributions](#contributor-attributions)
  * [License](#license)

## Overview

Aural is an audio file player for macOS. Inspired by the classic Winamp player for Windows, it is designed to be easy-to-use and customizable ... a simple drag-drop-play player that can do a lot!

## Key features

### Flexible UI
With Winamp-like modularity and multiple app presentation modes, you can lay out the app to suit your workspace, reduce it to a tiny widget, or tuck it away in the macOS menu bar.

### Personalization 
Personalize Aural Player with exactly the colors and fonts that define your creative tastes.

### Extensive audio formats support
By harnessing the power of FFmpeg, Aural Player supports a [wide variety of popular audio formats](https://github.com/kartik-venugopal/aural-player/wiki/Features#audio-formats), in addition to all [macOS Core Audio formats](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html).

### Sound tuning and monitoring
With several built-in effects and support for Audio Unit (AU) plug-ins, sound tuning and monitoring possibilities are endless.

### Usability
Command Aural from multiple places and in many ways - Configurable media keys, swipe/scroll gestures, Control Center, headphones, and media control devices / apps ("remote control").

Read the comprehensive feature list [here](https://github.com/kartik-venugopal/aural-player/wiki/Features)

### Roadmap

#### Version 3 archived

Version 3 has been archived, and no further work will be done on it. The source code for it can be found in the new repository: [aural-player-archive](https://github.com/kartik-venugopal/aural-player-archive)

All pending and newly filed issues (bugs or feature requests), if implemented, will be implemented in v4.

#### Version 4 being developed (coming soon!)

12 "preview" releases have already been put out. These pre-release builds are considered experimental, with the disclaimer that they may contain significant bugs.

As of Nov 11, 2024, there are 2 upcoming major milestones for Version 4:

<ins>Partial release</ins>: The partial release of v4 will contain all core + new functionality, except for the new Library and all related functionality. It will be stable and free from major bugs.

<ins>Full release</ins>: The full release of v4 will be the first official (and complete) release of v4.

There are no current date estimates for the milestone releases.

## How it works (under the hood)

Aural Player uses **AVFoundation's AVAudioEngine** framework (and some low-level **Core Audio**) for playback, effects, and visualization, and uses **FFmpeg** libraries to decode formats not native to macOS.

The UI is built on top of AppKit with views defined in XIBs (no SwiftUI).

The code is written entirely in Swift (approximately 100,000 lines of code).

<img src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master/Documentation/Diagrams/UnderTheHood.png" alt="How it works screenshot" width="850" />

Read more about it [here](https://github.com/kartik-venugopal/aural-player/wiki/Developer-reference).

### Limitations

* Currently, Aural does not play online streams.
* Aural does not play protected content (for example, Apple's M4P or Audible's AAX). There are no plans to implement this.

## Download

[Latest release](https://github.com/kartik-venugopal/aural-player/releases/latest)

[See all releases](https://github.com/kartik-venugopal/aural-player/releases)

### Compatibility

This table lists the range of compatible Aural Player versions for your hardware and macOS version.

|              | Intel (x86_64)  | Apple silicon (arm64)|
| :---:        | :-:             | :-:       |
| macOS 10.12 Sierra (no longer supported) | [3.16.0](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.16.0)           | (N/A)     |
| macOS 10.13 - 10.15 | [3.16.0](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.16.0) - [3.25.2](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.25.2)         | (N/A)     |
| macOS 11+  | [3.16.0](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.16.0) - [latest](https://github.com/kartik-venugopal/aural-player/releases/latest)           | [3.16.0](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.16.0) - [latest](https://github.com/kartik-venugopal/aural-player/releases/latest)|

**NOTES:**

* All releases are universal binaries, i.e. capable of running on both Intel and Apple Silicon Macs.

* Due to limited time, I can only officially support macOS Big Sur and later macOS versions going forward. The app should still work on older systems (going back to Sierra), but I can no longer make guarantees or troubleshoot issues on older systems.

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
     
## Known issues (and solutions)

* [The text is too small on my Mac screen.](https://github.com/kartik-venugopal/aural-player/wiki/App-text-is-too-small-on-my-Mac-screen)

* [Poor audio quality when using Bluetooth headsets.](https://github.com/kartik-venugopal/aural-player/wiki/Poor-audio-quality-when-using-Bluetooth-headsets)

* [My media keys don't work with Aural Player](https://github.com/kartik-venugopal/aural-player/wiki/My-media-keys-don't-work-with-Aural-Player)

## Contact and conversation

**(NEW!) Discussions:** https://github.com/kartik-venugopal/aural-player/discussions

**Email:** [kartikv2017@gmail.com](mailto:kartikv2017@gmail.com)

**GitHub Issues** https://github.com/kartik-venugopal/aural-player/issues.

The app is what it is today largely thanks to the numerous bug reports and valuable feedback of users over the years. I urge you to file issues for any bugs you encounter or for features / behavior you would like to see implemented. I am generally pretty good at responding to issues, and at the very least, I will read, contemplate, and respond.

## Third party code attributions

* [FFmpeg](https://www.ffmpeg.org/) (used to decode audio formats not natively supported on macOS)
* [libopenmpt](https://lib.openmpt.org/libopenmpt/) (used by ffmpeg to decode tracker module formats)
* [MediaKeyTap](https://github.com/nhurden/MediaKeyTap) (used to respond to media keys)
* [RangeSlider](https://github.com/matthewreagan/RangeSlider) (used in the Filter effects unit to specify frequency ranges)

## Contributor attributions

App user [LesterJitsi](https://github.com/LesterJitsi) has provided great feedback and suggsted numerous improvements over the past couple of years.

App user [VisualisationExpo](https://github.com/VisualisationExpo) designed the new app icon (as of v3.22.0).

App user [yougotwill](https://github.com/yougotwill) made numerous suggestions for improvements and features, provided a lot of valuable feedback, and designed the Poolside.fm theme.

Fellow GitHub member [dun198](https://github.com/dun198) made significant contributions towards this project - performance optimizations, UX improvements, etc.

I am also hugely grateful to all the app users who have filed bug reports and feature requests, and provided valuable feedback.

## License

Aural Player (in both forms - source code and binary) is available for use under the [MIT license](https://github.com/kartik-venugopal/aural-player/blob/master/LICENSE).
