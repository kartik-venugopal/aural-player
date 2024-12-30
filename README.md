<img width="225" src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master/Documentation/Screenshots/readmeLogo.png"/>

![App demo](/Documentation/aural4-modes.png?raw=true "App demo")

## Table of Contents
  * [Overview](#overview)
    + [Project philosophy & mission](#project-philosophy-mission)
  * [Key features](#key-features)
  * [What's new in v4](#whats-new-in-v4)
  * [Roadmap](#roadmap)
  * [How it works (under the hood)](#how-it-works-under-the-hood)
    + [Limitations](#limitations)
  * [Download](#download)
    + [Compatibility](#compatibility)
  * [Documentation](#documentation)
  * [Donation](#donation)
  * [Contact and conversation](#contact-and-conversation)
  * [Third party code attributions](#third-party-code-attributions)
  * [Contributor attributions](#contributor-attributions)
  * [License](#license)

## Overview

Aural is an audio file player for macOS. Inspired by the classic Winamp player for Windows, it is designed to be easy-to-use and customizable ... a simple drag-drop-play player that can do a lot!

### Project philosophy & mission

Driven by love, and bounded by time and knowledge constraints 😄, this project is about developing a fun and useful app for macOS users who have a bunch of audio files sitting around. Over the years, the app has absorbed countless amazing ideas from the community that uses and loves it. While improvement will always be a goal, the app does **NOT** aim to be "perfect" or "the best" or "better than" ... it just is.

______

## Key features

### Flexible UI
With Winamp-like modularity and multiple app presentation modes, you can lay out the app to suit your workspace, reduce it to a tiny widget, or tuck it away in the macOS menu bar.

### Personalization 
Personalize Aural Player with exactly the colors and fonts that define your creative tastes. Save and re-use your hand-tailored themes.

### Extensive audio formats support
By harnessing the power of FFmpeg, Aural Player supports a [wide variety of popular audio formats](https://github.com/kartik-venugopal/aural-player/wiki/Features#audio-formats), in addition to all [macOS Core Audio formats](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html).

### Sound tuning and monitoring
With several built-in effects and support for Audio Unit (AU) plug-ins, sound tuning and monitoring possibilities are endless. Also check out the built-in visualizer 😉

### Usability
Command Aural in many ways - Handy keyboard shortcuts for common tasks (eg. EQ bands / time stretching), configurable media keys, swipe and scroll trackpad gestures + mouse function buttons for basic functions, Control Center integration ("remote control").

Read the comprehensive feature list [here](https://github.com/kartik-venugopal/aural-player/wiki/Features).

______

## What's new in v4
Version 4 of the app is bringing with it a lot of great improvements: (NOTE - some of these features are still being developed)
- 2 new presentation modes (Unified and Compact) ... 2 new ways to lay out and use the app!
- Nicer aesthetics, with smaller core module windows.
- A full-fledged library allowing you to browse and listen to your entire collection right from within Aural!
- A new waveform view.
- Replay Gain.
- CUE sheet support.
- Gapless playback.

______

## Roadmap

### Version 3 archived

Version 3 has been archived, and no further work will be done on it. The source code for it can be found in the new repository: [aural-player-archive](https://github.com/kartik-venugopal/aural-player-archive)

All pending and newly filed issues (bugs or feature requests), if implemented, will be implemented in v4.

### V4 Preview releases

Preview builds are unstable pre-release builds containing incremental updates as v4 continues to be developed. They may contain significant bugs. Several preview builds have been put out and more are expected to come out before the milestone releases.

### V4 Milestone releases

As of Nov 11, 2024, there are 2 upcoming major milestones for Version 4:

<ins>Partial release</ins>: The partial release of v4 will contain all core + new functionality, except for the new Library and all related functionality. It will be stable and free from major bugs.

<ins>Full release</ins>: The full release of v4 will be the first official (and complete) release of v4.

There are no current date estimates for the milestone releases.

______

## How it works (under the hood)

Aural Player uses **AVFoundation's AVAudioEngine** framework (and some low-level **Core Audio**) for playback, effects, and visualization, and uses **FFmpeg** libraries to decode formats not native to macOS.

The UI is built on top of AppKit with views defined in XIBs (no SwiftUI).

The code is written entirely in Swift (approximately 100,000 lines of code).

<img src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master/Documentation/Diagrams/UnderTheHood.png" alt="How it works screenshot" width="850" />

Read more about it [here](https://github.com/kartik-venugopal/aural-player/wiki/Developer-reference).

### Limitations

* Currently, Aural does not play online streams.
* Aural does not play protected content (for example, Apple's M4P or Audible's AAX). There are no plans to implement this.

______

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

______

## Documentation

All the documentation can be found on the [wiki](https://github.com/kartik-venugopal/aural-player/wiki).

NOTE - Documentation generally lags behind app development, so pages may contain slightly outdated info from older app versions.

#### Some pages to get you started

[How To's](https://github.com/kartik-venugopal/aural-player/wiki/How-To's)

[Handy keyboard shortcuts](https://github.com/kartik-venugopal/aural-player/wiki/Handy-keyboard-shortcuts)

[Building and running Aural Player (quick start guide)](https://github.com/kartik-venugopal/aural-player/wiki/Building-and-running-Aural-Player-(quick-start-guide))

[Developer reference](https://github.com/kartik-venugopal/aural-player/wiki/Developer-reference)

______

## Donation

If you would like to show your appreciation for my work on this app by donating, you can do so via PayPal. Any donations are 100% voluntary, and any amount is much appreciated!

[![PayPal donation button](https://raw.githubusercontent.com/kartik-venugopal/aural-player/main/Resources/PayPal-DonateButton.png)](https://www.paypal.com/donate/?hosted_button_id=QMC632322THC2)

(If the button doesn't work, you can use my PayPal ID which is: kartikv.de@gmail.com)

______

## Contact and conversation

**(NEW!) Discussions:** https://github.com/kartik-venugopal/aural-player/discussions

**Email:** [kartikv2017@gmail.com](mailto:kartikv2017@gmail.com)

**GitHub Issues** https://github.com/kartik-venugopal/aural-player/issues.

The app is what it is today largely thanks to the numerous bug reports and valuable feedback of users over the years. I urge you to file issues for any bugs you encounter or for features / behavior you would like to see implemented. I am generally pretty good at responding to issues, and at the very least, I will read, contemplate, and respond.

______

## Third party code attributions

* [FFmpeg](https://www.ffmpeg.org/) (used to decode audio formats not natively supported on macOS)
* [MediaKeyTap](https://github.com/nhurden/MediaKeyTap) (used to respond to media keys)
* [RangeSlider](https://github.com/matthewreagan/RangeSlider) (used in the Filter effects unit to specify frequency ranges)
* [libcue](https://github.com/lipnitsk/libcue) (used to read CUE sheets)
* [libebur128](https://github.com/jiixyj/libebur128) (used by the Replay Gain effects unit to analyze tracks for loudness)

## Contributor attributions

App user [LesterJitsi](https://github.com/LesterJitsi) has provided great feedback and suggsted numerous improvements over the past couple of years.

App user [VisualisationExpo](https://github.com/VisualisationExpo) designed the new app icon (as of v3.22.0).

App user [yougotwill](https://github.com/yougotwill) made numerous suggestions for improvements and features, provided a lot of valuable feedback, and designed the Poolside.fm theme.

Fellow GitHub member [dun198](https://github.com/dun198) made significant contributions towards this project - performance optimizations, UX improvements, etc.

I am also hugely grateful to all the app users who have filed bug reports and feature requests, and provided valuable feedback.

______

## License

Aural Player (in both forms - source code and binary) is available for use under the [MIT license](https://github.com/kartik-venugopal/aural-player/blob/master/LICENSE).
