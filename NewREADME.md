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

Aural Player is an audio player for macOS. It aims to bring that nostalgic Winamp experience to macOS, emphasizing simplicity, ease of use. and fun! The new 4.0 version brings with it enhanced usability, better aesthetics, and new ways to browse, search, and organize your music collection.

Aural can do a lot, but at its core, it's about drag-drop-and-play. In this online streaming age, if you still have a bunch of audio files collecting dust on your hard drive  ... then this app is for you! Check out the rich new library and file system browser. 

With far-reaching audio formats support, you can throw almost anything at Aural and it will probably be able to play it :)

If you're an audiophile who needs each track to sound a certain way, you'll appreciate the built-in effects and AU plugin support. Aural can also remember your sound settings per track!

Make the app uniquely yours by trying its several fun theming options! 

And with a modular UI and multiple app presentation modes, you can mold Aural to fit onto your desktop just the way you want.

## Project philosophy

Aural doesn't aim to be perfect or to be the best player out there. This is an app that aims to be fun, to incorporate ideas from its community of users, and to incrementally improve over time.

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
