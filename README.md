# Aural Player

![App demo](/Documentation/Demos/demo.gif?raw=true "App demo")

## Overview

Aural Player is an audio player application for the macOS platform. Inspired by the classic Winamp player for Windows, it is designed to be to-the-point, easy to use, and customizable, with some sound tuning capabilities for audio enthusiasts.

#### What it is:
* A simple drag-drop-play player for the music collection on your local hard drive(s), that requires no configuration out of the box, although plenty of customization/configuration is possible
* (I hope) A decent macOS alternative for Winamp (you be the judge).

#### What it is not (at the moment):
* A streaming audio player that connects to internet radio stations/services
* A scrobbler

## Download

Download the latest app bundle [here](https://github.com/maculateConception/aural-player/releases/download/v1.0.0/AuralPlayer-1.0.0.dmg).

[See all releases](https://github.com/maculateConception/aural-player/releases)

### Installation

1. Mount the *AuralPlayer-x.y.z.dmg* image file
2. Copy Aural.app to your local drive (e.g. Applications folder)
3. Run the copied app !

NOTE - Please don't run the app directly from within the image. It is a compressed image, and may result in the app behaving slowly and/or unpredictably. So, copy it outside and run the copy.

#### Latest release (12/31/2018) - v1.0.0

* Added support for several popular audio formats - FLAC, OGG (Vorbis and Opus), WMA, APE, Musepack, DSF, MP2, and Wavpack ! Files of these formats will be automatically transcoded prior to playback.
* Optimized playlist track add performance and reliability
* Minor UI refinements
* First formal GitHub release

### Compatibility

**User**: Running Aural Player requires macOS 10.12 (Sierra) or later versions.

NOTE - I am no longer able to support macOS Yosemite or El Capitan, and no further support for those systems is planned. If you would really like support for Yosemite or El Capitan, please file an issue and I may consider it.

**Developer**: To develop Aural Player with Swift 4.2 (master branch) requires macOS 10.13.4 or later (High Sierra) and XCode 10. The old "swift2" branch has been deleted.

## Features

* **Supported file types:**
   * Audio formats: 
     * Supported natively - MP3, AAC, ALAC, AIFF/AIFC, AC3, WAV, CAF, and other Core Audio formats. See [entire list](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html).
     * Supported via transcoding<sup>*</sup> - FLAC<sup>**</sup>, WMA, Vorbis (OGG/OGA), Opus (OPUS/OGG/OGA), Monkey's Audio (APE), MP2, WavPack (WV), Musepack (MPC), and DSD Streaming File (DSF) **(New!)**
   * Container formats: M4A (for AAC and ALAC audio streams), OGG (for Vorbis and Opus audio streams)
   * Playlist files: M3U/M3U8
   
   <sup>*</sup> Aural Player will detect and automatically transcode (i.e. convert) the file, prior to playback, leaving the original file unmodified. Metadata, including cover art, will be read and displayed, if available. This whole process is seamless and effortless to the user.
   
   <sup>**</sup> FLAC is natively supported on macOS High Sierra and later versions, and is supported via transcoding on macOS Sierra and older versions.

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
   * ID3, iTunes, WMA and other metadata (i.e. tags), including artwork (when available)
   * File system information and technical audio data

* **Playlist:**
   * Grouping of tracks by artist/album/genre for convenient browsing
   * Searching and sorting by multiple criteria (e.g. artist/title/album/disc#/track#)
   * Type selection: Type the name of a track to try to find it
   * Functions to conveniently crop/invert track selection, reorder tracks, and scroll through the playlist
   
* **History:**
   * *Favorites* list 
   * Chronologically ordered *recently added* and *recently played* lists for added convenience. 
   * Play favorites and add/play recent items with one click

* **View:**
   * Several built-in window layout presets, window snapping with configurable spacing, collapsible views.
   * Save your customized window layouts as presets so you can use them again at any time
   * Hide individual UI components, such as album art or toolbars, per your preference, to get the UI looking more like you want it.

* **Usability:**
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

* Support for more container formats - e.g. Matroska, ASF, MP4, etc.
* Support for surround sound (AC3 and Dolby DTS)
* Enhanced eager transcoding and more advanced control over transcoding behavior
* A new status bar player mode
* A new "floating" miniature player view that stays on top and can be used when working on other apps and Aural Player is intended to be kept in the background
* A new parametric equalizer allowing specification of center frequency and bandwidth per band
* New color schemes
      
## Screenshots

### Default view

![App screenshot](/Documentation/Screenshots/Default.png?raw=true "App screenshot")

### Track segment loop playback (red segment on seek bar)

![App screenshot](/Documentation/Screenshots/SegmentLoop.png?raw=true "Track segment loop playback")

### Using the Effects panel to disable/enable effects

![App screenshot2](/Documentation/Demos/UsingFXUnit.gif?raw=true "Using the FX panel")

### Delayed track playback

![App screenshot2](/Documentation/Demos/delayedPlayback.gif?raw=true "Delayed playback")

### Insertings gaps of silence around tracks

![App screenshot2](/Documentation/Demos/gaps.gif?raw=true "Playback gaps")

### Detailed track info popover

![App screenshot w/ more info view](/Documentation/Screenshots/DetailedInfo.png?raw=true "More Info")

### Bookmarking

![App screenshot w/ more info view](/Documentation/Screenshots/Bookmarking.png?raw=true "Bookmarking")

### Saving an effects unit preset

![App screenshot w/ more info view](/Documentation/Screenshots/FXPreset.png?raw=true "Saving an effects preset")

### Previewing and managing effects presets

![App screenshot w/ effects presets editor](/Documentation/Screenshots/FXPresetsEditor.png?raw=true "Previewing and managing effects presets")

### Changing the window layout with one click

![App screenshot2](/Documentation/Demos/WindowLayout.gif?raw=true "Choosing a window layout")

### Compact app view, default player view with controls shown

![App screenshot4](/Documentation/Screenshots/Compact.png?raw=true "App screenshot4")

### Compact app view, default player view with controls hidden

![App screenshot4](/Documentation/Screenshots/Compact-default-noControls.png?raw=true "App screenshot4")

### Compact app view, expanded art player view

![App screenshot4](/Documentation/Screenshots/Compact-ExpandedArt.png?raw=true "App screenshot4")

### Equalizer effects unit

![EQ](/Documentation/Screenshots/EQ.png?raw=true "Equalizer")

### Time stretch effects unit

![Time](/Documentation/Screenshots/Time.png?raw=true "Time Stretch")

### Filter effects unit

![Filter](/Documentation/Screenshots/Filter1.png?raw=true "Filter")
![Filter](/Documentation/Screenshots/Filter2.png?raw=true "Filter")

### Delay effects unit

![Delay](/Documentation/Screenshots/Delay.png?raw=true "Delay")

### Playlist search

![Playlist search](/Documentation/Screenshots/Search.png?raw=true "Delay")

### Playlist sort

![Playlist sort](/Documentation/Screenshots/Sort.png?raw=true "Delay")

### Preferences (Playback tab selected)

![Preferences](/Documentation/Screenshots/Preferences-Playback.png?raw=true "Delay")

## Third party code and contributor attributions

Aural Player uses [FFmpeg](https://www.ffmpeg.org/) which, in the binary form used by Aural Player, is licensed under GPL v3. In compliance with the license, I have made the FFmpeg source code available as an archive in the source code under /Resources/ffmpeg, and also as an asset with each release of Aural Player.

Aural Player makes use of (a modified version of) a reusable UI control called [RangeSlider](https://github.com/matthewreagan/RangeSlider).

Fellow GitHub member [Dunkeeel](https://github.com/Dunkeeel) made significant contributions towards this project - performance optimizations, UX improvements, etc.
