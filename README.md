<img width="225" src="https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Screenshots/readmeLogo.png"/>

![App demo](/Documentation/Demos/mainDemo.gif?raw=true "App demo")

## Table of Contents
  * [Overview](#overview)
  * [Summary of features](#summary-of-features)
  * [Download](#download)
    + [Compatibility](#compatibility)
<<<<<<< HEAD
  * [Features](#features)
  * [Planned updates](#planned-updates)
=======
    + [Important note for macOS Big Sur](#important-note-for-macos-big-sur)
    + [Important note for anyone upgrading from v2.2.0 (or older) to v2.3.0 or newer app versions](#important-note-for-anyone-upgrading-from-v220-or-older-to-v230-or-newer-app-versions)
    + [Installation](#installation)
    + [Enabling media keys support](#enabling-media-keys-support-optional)
>>>>>>> upstream/master
  * [Screenshots](#screenshots)
  * [Known issues](#known-issues)
  * [Documentation](#documentation)
  * [Contact Info](#contact-info)
  * [Third party code attributions](#third-party-code-attributions)
  * [Contributor attributions](#contributor-attributions)

## Overview

Aural Player is an audio player for macOS. Inspired by the classic Winamp player for Windows, it is designed to be easy to use and customizable, with support for a wide variety of popular audio formats and some sound tuning capabilities for audio enthusiasts.

<<<<<<< HEAD
#### What it is:
* A simple drag-drop-play player for the music collection on your local hard drive(s), that requires no configuration out of the box, although plenty of customization/configuration is possible
* (I hope) A decent macOS alternative for Winamp (you be the judge).
=======
#### Goals:
* To have a simple drag-drop-play player for the music collection on your local drives, that is able to play a wide variety of audio formats.
* To *allow* customization/configuration, but not to *require* it out of the box.
* To make sound tuning an integral part of the listening experience and to have it within quick and easy reach at all times.
* To have a decent macOS Winamp counterpart.

#### Limitations:
* Does not play protected content (e.g. Apple's M4P or Audible's AAX).
* Does not integrate with online services for streaming / scrobbling, etc.
>>>>>>> upstream/master

## Summary of features

(Comprehensive feature list [here](https://github.com/maculateConception/aural-player/wiki/Features))

* Supports all Core Audio formats (inc. FLAC) and several non-native formats: (inc. Vorbis, Opus, Monkey's Audio (APE), True Audio (TTA), DSD & [more](https://github.com/maculateConception/aural-player/wiki/Features#audio-formats))
* Supports M3U / M3U8 playlists
* **Playback:** Repeat / shuffle, bookmarking, segment looping, 2 custom seek intervals, last position memory, autoplay
* **Chapters support:** Chapters list window, playback functions including loop, current chapter indication, search by title
* **Effects:** Graphic equalizer, pitch shift, time stretch, reverb, delay, filter
  * Built-in and custom effects presets, per-track effects settings memory
  * Recording of clips with effects captured
* **Playlist:** Grouping by artist/album/genre, searching, sorting, type selection
* **Information:** ID3, iTunes, WMA, Vorbis Comment, ApeV2, and other metadata (when available). Cover art, lyrics, file system and audio data. Option to export.
* **Track lists:** *Favorites* list, *recently added* and *recently played* lists.
* **Visualizations:** 3 different visualizations that dance to the music, with customizable colors.
* **UI:** Fully customizable fonts and colors with built-in and custom schemes, window layouts (built-in and custom), window snapping, collapsible UI components.
* **Usability:** Configurable media keys support, swipe/scroll gesture recognition

## Download

### Compatibility

**User**: macOS 10.12 (Sierra) or later versions.

**Developer**: Swift 5 and XCode 11.

Download the DMG image (containing the app bundle) from the latest release [here](https://github.com/maculateConception/aural-player/releases/latest).

[See all releases](https://github.com/maculateConception/aural-player/releases)

### Important note for macOS Big Sur

If you're on macOS Big Sur, you must download v2.3.0 or later versions. No older app versions will run on macOS Big Sur.

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

<<<<<<< HEAD
1. Mount the *AuralPlayer-x.y.z.dmg* image file
2. Copy Aural.app to your local drive (e.g. Applications folder)
3. Run the copied app. You will likely see a security warning and the app will not open because the app's developer is not recognized by macOS.
4. Go to System Preferences > Security & Privacy > General > Open anyway, to allow Aural.app to open.
=======
1. Mount the **AuralPlayer-x.y.z.dmg** image file
2. From within the mounted image, copy **Aural.app** to your local drive (e.g. Applications folder)
3. Run the copy from your local drive. You will likely see a security warning and the app will not open because the app's developer is not recognized by macOS.
4. Go to **System Preferences > Security & Privacy > General > Open anyway**, to allow Aural.app to open.
>>>>>>> upstream/master

NOTE - Please ***don't*** run the app directly from within the image. It is a compressed image, and may result in the app behaving slowly and/or unpredictably. So, copy it outside and run the copy.

If you have [Homebrew](https://brew.sh/) installed, try run the following in your terminal:
```shell
brew install --cask aural
```

### Enabling media keys support (optional)

Follow the steps listed [here](https://github.com/maculateConception/aural-player/wiki/Enabling-media-keys-support)
     
## Screenshots

### "Lava" color scheme, "Futuristic" font scheme, default window layout

![Vertical full stack window layout demo](/Documentation/Screenshots/FullStack.png?raw=true)

### Visualizer

<img width="530" src="https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Demos/Visualizer.gif"/>

### Changing the font scheme

<<<<<<< HEAD
## Features

* **Supported file types:**
   * Audio formats: 
     * Supported natively - MP3, AAC, ALAC, FLAC<sup>*</sup>, AIFF/AIFC, AC3, WAV, CAF, and other Core Audio formats. See [entire list](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html).
     * Supported via transcoding<sup>**</sup> - Vorbis (OGG/OGA), Opus (OPUS/OGG/OGA), Windows Media Audio (WMA), Monkey's Audio (APE), MP2, WavPack (WV), Musepack (MPC), DSD Streaming File (DSF), and Digital Theater Systems (DTS) **(New!)**
   * Container formats: M4A (AAC/ALAC), OGG (Vorbis/Opus), Matroska Audio (MKA) for streams of any of the above audio formats
   * Playlist files: M3U/M3U8
   
   <sup>*</sup> FLAC is natively supported on macOS High Sierra and later versions, and is supported via transcoding on macOS Sierra and older versions.
   
   <sup>**</sup> Aural Player will detect and automatically transcode (i.e. convert) the file, prior to playback, leaving the original file unmodified. Metadata, including cover art, will be read and displayed, if available. This whole process is seamless and effortless to the user.

* **Playback:**
  * Bookmarking - mark a single position or a segment loop between two track positions
  * Track segment looping - define two loop points and loop between them indefinitely
  * Specify 2 different custom seek lengths (fine-grained and coarse-grained seeking)
  * Insert timed gaps of silence (up to 24 hours) before/after tracks ... either per track or for all tracks
  * Delayed track playback, with up to a 24 hour delay
  * Option to remember last playback position ... either per track or for all tracks
  * "Jump to time" function - quickly skip to a specific track position
  * Configurable autoplay (on app startup and/or when tracks are added)

* **Effects:**
   * Graphic equalizer - 10-band and 15-band
   * Pitch shift - Range: -2 octaves to +2 octaves
   * Time stretch (playback rate) - Range: 0.25x to 4x
   * Reverb - space preset and amount
   * Delay - time, amount, feedback, and low pass cutoff
   * Filter (up to 31 bands: Band stop / Band pass / Low pass / High pass)
   * Dynamic control coloring to indicate unit state
   * Option to remember sound settings ... either per track or for all tracks
   * Save effects settings as presets ... per effects unit or all effects as a whole
   * Recording of clips in AAC/ALAC/AIFF formats - captures applied effects

* **Information:**
   * ID3, iTunes, WMA, Vorbis Comment, ApeV2, and other metadata (when available). Option to export textual metadata as HTML/JSON.
   * Cover art (when available). Option to export cover art as JPEG/PNG.
   * Lyrics (when available)
   * File system information and technical audio data

* **Playlist:**
   * Grouping of tracks by artist/album/genre for convenient browsing
   * Searching and sorting by multiple criteria (e.g. artist/title/album/disc#/track#)
   * Type selection: Type the name of a track to try to find it
   * Functions to conveniently crop/invert track selection, reorder tracks, and scroll through the playlist
   
* **Track lists:**
   * *Favorites* list 
   * Chronologically ordered *recently added* and *recently played* lists for added convenience.

* **View:**
   * Several built-in window layout presets, window snapping with configurable spacing, collapsible views.
   * Save your customized window layouts as presets so you can use them again at any time
   * Hide individual UI components, such as album art or toolbars, per your preference, to get the UI looking more like you want it.
   * Adjust UI text font size per your preference or to compensate for a high display resolution

* **Usability:**
   * Media keys support with configurable key behavior
   * Gesture recognition for essential player/playlist controls (trackpad/MagicMouse). Examples:
      * Two finger vertical scroll for volume control
   	  * Two finger horizontal scroll for seeking 
   	  * Three finger horizontal swipe to change tracks
   	  * Three finger vertical swipe to scroll to top/bottom of playlist

   * Keyboard shortcuts and menu items for quick and convenient access to functionality. Examples:
      * < / > keys to quickly adjust playback rate (i.e. Time stretch effects unit)
   	  * \+ / - keys to quickly adjust pitch (i.e. Pitch shift effects unit)
   	  * Shift/Alt+1 to increase/decrease Equalizer bass

* **Customization:**
      
  * Configure two independent seek lengths to your liking, used by two independent sets of seek controls … either as a constant value or a percentage of track duration. For instance, set one to a short interval and set the other to a longer interval to quickly skip through large audiobooks while also being able to perform more fine-grained seeking to get to exactly where you want within the track.
  * Click on the track time labels around the seek bar to change the display format to either hh:mm:ss or number of seconds or percentage of track duration
  * Configure how you want the app to look/behave on startup: Autoplay, volume and effects settings on startup, window layout on startup, remembered or default playlist on startup, etc.
  * Configure the increment/decrement for volume/pan and effects unit adjustments
  * Configure window snapping behavior, mouse sensitivity for gestures, and more …
  * Editors to manage all your saved custom app state, such as effects presets, bookmarks, favorites, window layouts, etc, so you can edit your saved data and delete unwanted or old data to prevent clutter
      
## Planned updates

* Support for more container formats - e.g. ASF, MP4, etc.
* Better parsing of FLAC/Ogg/WMA metadata tags
* Support for surround sound (AC3 and DTS)
* Enhanced eager transcoding and more advanced control over transcoding behavior
* A new status bar player mode
* A new "floating" miniature player view that stays on top and can be used when working on other apps and Aural Player is intended to be kept in the background
* A new parametric equalizer allowing specification of center frequency and bandwidth per band
* New color schemes
      
## Screenshots
=======
![Changing the font scheme demo](/Documentation/Demos/FontSchemes.gif?raw=true)

### Changing the color scheme

![Changing the color scheme demo](/Documentation/Demos/ChangingColorScheme.gif?raw=true)

### Customizing the player view
>>>>>>> upstream/master

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

## Contact info

Want to contact the developer ? Send an email to [aural.student@gmail.com](mailto:aural.student@gmail.com).

Any feedback, questions, issues, suggestions, or other comments related to the project are welcome ... spam is not :)

Of course, you may also file issues right here on GitHub as needed. I'm usually pretty good at responding to them, even if I'm not always able to fix them.


## Third party code attributions

* [FFmpeg](https://www.ffmpeg.org/) (used to decode audio formats not natively supported on macOS)
* [MediaKeyTap](https://github.com/nhurden/MediaKeyTap) (used to respond to media keys)
* [RangeSlider](https://github.com/matthewreagan/RangeSlider) (used in the Filter effects unit to specify frequency ranges)

## Contributor attributions

Fellow GitHub member [dun198](https://github.com/dun198) made significant contributions towards this project - performance optimizations, UX improvements, etc.
