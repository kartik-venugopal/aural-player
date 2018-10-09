# Aural Player

![App demo](/Documentation/Demos/masterDemo.gif?raw=true "App demo")

## Overview

Aural Player is a free and open source audio player application for the macOS platform. Inspired by the classic Winamp player for Windows, it is designed to be to-the-point, easy to use, and highly customizable, with some sound tuning capabilities for audio enthusiasts.

## Download

Download the disk image file [Aural.dmg](https://github.com/maculateConception/aural-player/blob/master/Aural.dmg?raw=true). Just mount it and run the app !

NOTE - This project is currently under heavy development as of 10/07/2018. So, please expect frequent updates/releases, and perhaps the occasional bug or two. I might switch to doing Git releases once the code is more stable, after most major updates have been rolled out and tested.

### Compatibility

**User**: Running Aural Player requires OS X 10.10 (Yosemite) or later macOS versions.

**Developer**: To develop Aural Player with Swift 4.2 (master branch) requires macOS 10.13.4 or later (High Sierra) and XCode 10. The old "swift2" branch has been deleted.

## Features

* **Supported file types:**
   * Audio files: MP3, AAC, AIFF/AIFC, WAV, and CAF
   * Playlist files: M3U/M3U8

* **Playback:**
   * Option to specify two different custom seek lengths so you can perform both fine-grained and coarse-grained seeking simultaneously **(New!)**
  * Option to remember last playback position, either on a per-track basis or for all tracks, so you can resume listening to a track without needing to remember where you left off **(New!)**
  * Bookmarking, so you can mark a specific position within a track, save it with an informative description, and come back to it later with one click, which is great for long tracks like audiobooks **(New!)**
   * Track segment looping, to allow you to define and loop your favorite parts of a track. 
   * Thanks to bookmarking, save your loops and play them back at any time with one click **(New!)**
   * Configurable autoplay (on app startup and/or when tracks are added)

* **Effects:**
   * Graphic equalizer, Pitch shift, Time stretch, Reverb, Delay, Filter, and a Master unit to switch on/off all effects from one place
   * Option to remember sound settings, either on a per-track basis or for all tracks, so you can tailor the soundscape for each of your tracks without having to manually re-apply any settings when they begin playing. Adjust the settings once and Aural will remember them the next time that track plays. **(New!)**
   * Save your effects settings as presets, either per individual effects unit or all effects as a whole, so you can use them later without having to remember them. **(New!)**
   * Recording of clips in AAC/ALAC/AIFF formats, so you can capture your applied sound effects and create a customized version of your track.

* **Information:**
   * Display of ID3 and iTunes metadata, including artwork (when available)
   * Display of file system information and audio information

* **Playlist:**
   * Grouping of tracks by artist/album/genre for convenient browsing
   * Searching and sorting
   * Type selection: Just start typing the name of a track to try to find it within the playlist
   
* **History:**
   * Favorites list and chronologically ordered recent items lists for added convenience. Find tracks you recently added/played or favorited, and add or play them with one click.

* **View:**
   * Multiple compact and flexible view options - several built-in window layout presets, window snapping with configurable spacing, collapsible views. 
   * Save your customized window layouts as presets so you can use them again at any time. **(New!)**

* **Usability:**
   * Gesture recognition for essential player/playlist controls (trackpad/MagicMouse). Examples:
      * Two finger vertical scroll for volume control
   	  * Two finger horizontal scroll for seeking 
   	  * Three finger horizontal swipe to change tracks
   	  * Three finger vertical swipe to scroll to top/bottom of playlist

   * Extensive set of keyboard shortcuts and menu items for quick and convenient access to functionality. Examples:
      * Simply press the < / > keys to quickly adjust playback rate (i.e. Time stretch effects unit)
   	  * Simply press + / - keys to quickly adjust pitch (i.e. Pitch shift effects unit)
   	  * Press Shift/Alt+1 to increase/decrease Equalizer bass

* **Customization:**
   * Numerous preferences to allow user to highly customize functionality. Examples:
   
      * Configure two independent seek lengths to your liking, used by two independent sets of seek controls … either as a constant value or a percentage of track duration. For instance, set one to a short interval and set the other to a longer interval to quickly skip through large audiobooks while also being able to perform more fine-grained seeking to get to exactly where you want within the track.
   	  * Configure how you want the app to look/behave on startup: Autoplay, volume and effects settings on startup, window layout on startup, remembered or default playlist on startup, etc.
      * Configure the increment/decrement for volume/pan adjustments
   	  * Configure window snapping behavior, mouse sensitivity for gestures, and more …
      * Editos to manage all your saved custom app state, such as bookmarks, effects presets, window layouts, etc, so you can rename or edit your saved items and delete unwanted or old data to prevent clutter

### Planned updates

- Option to insert gaps of silence between tracks
- A new editor window to manage effects presets
- A new "floating" miniature player view that stays on top and can be used when working on other apps and Aural Player is intended to be kept in the background
- New color schemes

### Known issues/bugs

The following bugs are known and fixes are planned. If you find any additional bugs, please feel free to report them in  the "Issues" section right here on GitHub.

- Sometimes, when shuffling a playlist, the app crashes. Not sure when this bug was introduced, but it never showed up on macOSSierra, but shows up on macOS High Sierra.
- On very rare conditions, the app crashes on startup due to an array indexing being performed out of range. This is due to a very subtle sneaky race condition in the playlist loading code.
- When modal dialogs such as file browsing dialogs are open, hitting the Cmd/Shift key along with arrows invokes corresponding menu items, instead of acting on the dialog.

### Recent updates

- **10/05/2018: New release:**
    
  * Bug fixes:
    * **Headphones/speakers plugged in crash**: When headphones/speakers are plugged in/out, the app stops playing audio. This problem has been fixed.  
    
  * Improvements:
    * **Removed custom buffer scheduling (playback)**: Complex custom code that was used to schedule audio buffers for playback has been decommissioned, in favor of much simpler code that uses higher level AVFoundation functions.

- **10/05/2018: Swift 4.2 port:** All source code has been ported to Swift v4.2 ! Also, the old "swift2" branch has been deleted.

- **10/04/2018: New release:**
  * New features:
    * **New Master effects unit**: A new effects unit called "Master" has been added to the effects panel. This unit has controls to enable/disable all effects units from one place and provides the ability to capture all sound effects in a single "master" preset.
    * **New playback preference (show new track in playlist)**: Whenever a track begins playing, the playlist, if visible, will automatically select it and scroll to show it.
    * **New playlist functions (invert selection, crop selection)**: The playlist menu now has 2 new functions: 1 - Invert selection, which inverts the current playlist selection, and 2 - crop selection, which keeps only selected tracks/groups, deleting all others.
    
  * Bug fixes:
    * **Headphones plugged in crash**: When headphones are plugged in/out, the app stops playing audio. Now, this works during normal track playback, but still fails during track segment loop playback. A fix for the loop playback crash is planned and coming soon.

- **9/28/2018: New release:** Bug fix - On High Sierra systems, app crashed at the completion of an iteration of a playback loop. This issue has been fixed.

- **9/26/2018: New release:** Favorites items now have their own separate Favorites menu on the main menu bar, entirely separate from the History menu. Also, favorites lists are no longer restricted in size.

- **9/25/2018: New release:**
  * New features:
    * **Configurable window spacing**: The user can now configure the spacing between windows when windows are snapped together. The user can specify a value between 0 and 25 pixels, as per his visual preference.
    * **Layouts editor**: The user can now manage user-defined window layouts within a new editor window. In addition to being able to rename and delete layouts, the editor window will display an accurately scaled graphical preview of the layout.

- **9/24/2018: New release:**
  * New features:
    * **Bookmarks editor and Favorites editor**: The user can now manage bookmarks (rename and/or delete them) and favorites (delete unwanted ones) with a new editor window.
    * **Playlist file on startup**: The user can now specify a preference that, on app startup, the playlist should load tracks from a specific (M3U/M3U8) playlist file. This option can be found in the Playlist tab of the Preferences dialog.
    * **Seeking/looping/replaying tracks when paused**: Previously, seeking, looping, and replaying tracks could only be done while the player was playing (as opposed to paused). This limitation no longer exists.
    
  * Bug fixes:
    * **History/Favorites bug**: When history/favorites lists are resized, menus and other UI elements need to be updated. They weren't always being updated, resulting in weird UI states.

- **9/22/2018: New release with lots of updates:**
  * New features:
    * **Bookmarking**: The user can now mark a specific position in a track, and it will be saved with a name/description the user can provide. The user can then return to that track position later with one click. This is great when listening to long files like audiobooks or podcasts.
    * **New window layouts and user-defined layouts**: The way windows are laid out has been simplified and made easier for the user. The user can choose from multiple built-in window layouts, or lay out the windows per his preference and save the layout as a preset for later use. **Window snapping**, to other app windows, and to screen corners and edges for added convenience.
    * **FX unit presets**: Each effects unit now allows the saving of settings as a preset, so the user can save all his sound settings as presets for later use with just one click.
    * **Dynamic tool tips**: The previous/next track buttons of the player controls now show the name of the previous/next track, as tool tips, so the user can know, before clicking the button, which track will play as a result.
    
  * Improvements:
    * Performance improvement: No more GIF animations. Only static images are shown to indicate a playing track. This has reduced CPU usage by about 60%..
    
  * The following bugs have been fixed:
    * Audio engine crash upon app exit, causing corruption of app state file, resulting in loss of all saved settings and user presets/data.
    * When playing a track from Favorites/Recently played list, the first 5 seconds of the track would sometimes play twice in a row, because of a race condition in the code that performed preparation for track playback.
    * The playlist scroll buttons stopped working at some point.

### Background

Aural Player was written by an audio enthusiast learning to program on OS X, coming to Swift programming from many years of Java programming. This project was inspired by the developer’s desire to create a Winamp-like substitute for the macOS platform. No feature bloat or unnecessary annoyances like iTunes.

### Third party code and contributor attributions

Aural Player makes use of (a modified version of) a reusable UI control called [RangeSlider](https://github.com/matthewreagan/RangeSlider).

Fellow GitHub member [Dunkeeel](https://github.com/Dunkeeel) made significant contributions towards this project - performance optimizations, UX improvements, etc.

## Screenshots

### Default view

![App screenshot](/Documentation/Screenshots/Default.png?raw=true "App screenshot")

### Track segment loop playback (red segment on seek bar)

![App screenshot](/Documentation/Screenshots/SegmentLoop.png?raw=true "Track segment loop playback")

### Playlist-only view w/ detailed track info popover view

![App screenshot w/ more info view](/Documentation/Screenshots/DetailedInfo.png?raw=true "More Info")

### Bookmarking

![App screenshot w/ more info view](/Documentation/Screenshots/Bookmarking.png?raw=true "Bookmarking")

#### Managing bookmarks

![App screenshot w/ more info view](/Documentation/Screenshots/BookmarksEditor.png?raw=true "Bookmarks Editor")

### Saving an effects unit preset

![App screenshot w/ more info view](/Documentation/Screenshots/FXPreset.png?raw=true "Saving an effects preset")

### "Big bottom playlist" window layout

![App screenshot2](/Documentation/Screenshots/BigBottomPlaylist.png?raw=true "Big bottom playlist window layout")

### Changing the window layout with one click

![App screenshot2](/Documentation/Demos/WindowLayout.gif?raw=true "Choosing a window layout")

### Managing window layouts

![App screenshot2](/Documentation/Screenshots/LayoutsEditor.png?raw=true "Managing window layouts")

### Compact view

![App screenshot4](/Documentation/Screenshots/Compact.png?raw=true "App screenshot4")

### Equalizer effects unit

![EQ](/Documentation/Screenshots/EQ.png?raw=true "Equalizer")

### Time stretch effects unit

![Time](/Documentation/Screenshots/Time.png?raw=true "Time Stretch")

### Filter effects unit

![Filter](/Documentation/Screenshots/Filter.png?raw=true "Filter")

### Delay effects unit

![Delay](/Documentation/Screenshots/Delay.png?raw=true "Delay")

### Playlist search

![Playlist search](/Documentation/Screenshots/Search.png?raw=true "Delay")

### Playlist sort

![Playlist sort](/Documentation/Screenshots/Sort.png?raw=true "Delay")

### Preferences (Playback tab selected)

![Preferences](/Documentation/Screenshots/Preferences-Playback.png?raw=true "Delay")


