#  What's New in Version 3.2.0

## Control bar

The control bar is a new app mode with a minimalistic user interface consisting of a single compact window containing only player controls, playing track info, and some options to change appearance (theming). 

The control bar window is floating, i.e. always on top of other windows, and can be moved around, resized horizontally, and/or docked to different locations on-screen.

This feature is useful when intending to run the app in the background and working on other applications while still having quick and easy access to player controls to change tracks or perform other player functions.

The control bar is an alternative to the menu bar mode or controlling the app through media keys or from Control Center.

### Media keys / Remote control now available in menu bar mode

Fixed a bug that prevented media keys and remote control commands from working while the app was running in menu bar mode.

### Remote control enabled by default on all systems

Previously, Remote control was enabled by default only on macOS Big Sur. Now, it will be enabled by default on all operating systems.

### Support (wiki) link in Help menu

The **Help** menu is now enabled and has a link that takes users to Aural Player's wiki home page that contains all the documentation for the app.

### Added lots of documentation

Added lots of new documentation to the wiki, including a page listing [common keyboard shortcuts](https://github.com/maculateConception/aural-player/wiki/Handy-keyboard-shortcuts), a new ["Troubleshooting"](https://github.com/maculateConception/aural-player/wiki/Troubleshooting) section, and a new ["Developer reference"](https://github.com/maculateConception/aural-player/wiki/Developer-reference) section for people interested in developing Aural Player or understanding how it works.
 
### Source code improvements

#### Significant refactoring, restructuring, and cleanup.

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
