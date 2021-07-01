#  What's New in Version 3.2.0

## Control bar

The control bar is a new app mode with a minimalistic user interface consisting of a single compact window containing only player controls, playing track info, and some options to change the displayed info and appearance (theme). It is similar to Winamp's "Windowshade mode".

The control bar window is floating, i.e. always on top of other windows, and can be moved around, resized horizontally, and/or docked to different locations on-screen.

This feature is useful when intending to run the app in the background and working on other applications while still having quick and easy access to player controls to change tracks or perform other player functions. The control bar is an alternative to the menu bar mode, media keys, and the macOS Control Center, providing yet another way to control playback of your music.

### New "Support" menu

The new **Support** menu provides:

* A link to Aural Player's wiki home page that contains all the documentation for the app.
* An option to check for updates to the app. If a newer app version is available, a link to get the latest release version is displayed.

### Bug fixes / improvements 

* **Media keys / Remote control** -  Fixed a bug that prevented media keys and remote control commands from working while the app was running in menu bar mode.
* Previously, Remote control was disabled by default on systems older than macOS Big Sur. Now, it will be enabled by default on all operating systems.
* **Sorting when adding folders to playlist** - Fixed a bug that caused files to not be added in alphanumeric order when their parent folder was added to the playlist.

### Added more documentation

Added several new pages to the wiki, including:

* A page listing [common keyboard shortcuts](https://github.com/maculateConception/aural-player/wiki/Handy-keyboard-shortcuts).
* A new ["Troubleshooting"](https://github.com/maculateConception/aural-player/wiki/Troubleshooting) section.
* A new ["Developer reference"](https://github.com/maculateConception/aural-player/wiki/Developer-reference) section for people interested in developing Aural Player or understanding how it works.
 
### Source code improvements

#### Significant refactoring, restructuring, and cleanup

* Persistence layer significantly improved with extensions replacing lots of boilerplate code.
* Improved lazy loading of objects on app startup.
* Much more efficient computation of window layout presets.
* Improved code reuse with new extensions replacing clunky Util classes.
* All presets now extend a common base class, resulting in uniformity and reduced code duplication. 
* Refactored lots of redundant **ViewController** code into generic base classes that are subclassed.
* Separated out lots of classes / structs that were lumped into a single lengthy file.
* More Swift-style comments added.

### MIT software license

Aural Player (in both forms - source code and binary) is now available for use under the [MIT license](https://github.com/maculateConception/aural-player/blob/master/LICENSE).

A copy of the license is now included with each release package, including this one.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/3.2.0)
