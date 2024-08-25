<img width="225" src="https://raw.githubusercontent.com/kartik-venugopal/aural-player/master/Documentation/Screenshots/readmeLogo.png"/>

<img width="1024" src="https://github.com/kartik-venugopal/aural-player/raw/v4.0/aural4.png"/>

## Table of Contents
  * [Overview](#overview)
    + [How it works (under the hood)](#how-it-works-under-the-hood)
    + [Limitations](#limitations)
  * [Key features](#key-features)
  * [Download](#download)
    + [Compatibility](#compatibility)
  * [License](#license)

## Overview

Aural is an audio file player for macOS. If you loved Winamp on Windows, chances are you'll love Aural 😉 Made for those who still have a bunch of audio files sitting around, the main aims here are ease of use, being able to tinker with sound (if that's your thing), and customizability.

If you're a long-time user, you'll notice the many improvements in v4 - better aesthetics, enhanced usability, and new ways to browse, search, and organize your music collection. Note - while "preview" releases are available now, v4 is still in development and expected to come out in late 2024.

### Project philosophy

Aural doesn't aim to be perfect or to be the best player out there. This is an app that aims to be fun, to incorporate ideas from its community of users, and to incrementally improve over time. It wouldn't have made it this far without all the amazing user feedback and bug reports 🙏

## Standout features

### Extensive audio formats support

Thanks to the power of ffmpeg, you can throw almost any format at Aural and it will probably be able to play it! FLAC, Vorbis, Opus, APE, Musepack, and WMA are some of the many formats supported, in addition to all native (CoreAudio) formats.

If you're an audiophile who needs each track to sound a certain way, you'll appreciate the built-in effects and AU plugin support. Aural can also remember your sound settings per track!

Make the app uniquely yours by trying its several fun theming options! 

And with a modular UI and multiple app presentation modes, you can mold Aural to fit onto your desktop just the way you want.


## Key features

(Comprehensive feature list [here](https://github.com/kartik-venugopal/aural-player/wiki/Features))

* Supports all [Core Audio formats](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html) and several non-native formats: FLAC, Vorbis, Monkey's Audio (APE), Opus, & [many more](https://github.com/kartik-venugopal/aural-player/wiki/Features#audio-formats)
* Supports M3U / M3U8 playlists
* **Playback:** Bookmarking, segment looping, custom seek intervals, per-track last position memory, chapters support, autoplay, resume last played track.
* **Effects:** Built-in effects (incl. equalizer), Audio Unit (AU) plug-in support, built-in / custom presets, per-track settings memory.
* **Library:** Grouping by artist/album/genre/decade, searching, sorting, type selection. File system browser with metadata-based search.
* **Track information:** ID3, iTunes, WMA, Vorbis Comment, ApeV2, etc. Cover art (with MusicBrainz lookups), lyrics, file system and audio data. Option to export. Last.fm scrobbling and love/unlove **(NEW!)**.
* **Track lists:** *Favorites*, *recently added*, *recently played*, and *most played* lists.
* **Visualizer:** 3 different visualizations that dance to the music, with customizable colors.
* **UI:** Modular interface, fully customizable fonts and colors (with gradients), built-in / custom window layouts, configurable window snapping / docking / spacing / corner radius, menu bar mode, control bar (widget) mode.
* **Usability:** Configurable media keys support, swipe/scroll gesture recognition, remote control from Control Center, headphones, and media control devices / apps.

## Download

[Latest release](https://github.com/kartik-venugopal/aural-player/releases/latest)

[See all releases](https://github.com/kartik-venugopal/aural-player/releases)

### Compatibility

This table lists the range of compatible Aural Player versions for your hardware and macOS version. Unless you are using macOS 10.12 Sierra, it is always recommended to use the [latest](https://github.com/kartik-venugopal/aural-player/releases/latest) app version, regardless of your hardware / macOS version.

|              | Intel (x86_64)  | Apple silicon (arm64)|
| :---:        | :-:             | :-:       |
| macOS 10.12 Sierra (no longer supported) | [3.16.0](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.16.0)           | (N/A)     |
| macOS 10.13+ | [3.16.0](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.16.0) - [3.25.2](https://github.com/kartik-venugopal/aural-player/releases/latest)         | (N/A)     |
| macOS 11+  | [3.16.0](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.16.0)           | [3.16.0](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.16.0) - [latest](https://github.com/kartik-venugopal/aural-player/releases/latest)|

**NOTES:** 

* Version 3.0.0 and all subsequent releases are universal binaries, i.e. capable of running on both Intel and Apple Silicon Macs.

* Due to limited time, I can only officially support macOS Big Sur and Monterey going forward. The app should still work on older systems (going back to Sierra), but I can no longer make guarantees or troubleshoot issues on older systems.

## License

Aural Player (in both forms - source code and binary) is available for use under the [MIT license](https://github.com/kartik-venugopal/aural-player/blob/master/LICENSE).
