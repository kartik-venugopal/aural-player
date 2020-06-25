#  What's New in Version 2.3.0

### Playlist (back end)

Major refactoring of the playlist code in all app layers:

* Simplification and optimization using functional programming (map/filter/reduce) leading to much more concise code. Reduced lines of code by > 1000.
* Factored out lots of redundant code into common utilities.
* Implemented safe checking of optional values.
* Improved interface definitions and reduced redundant code in struct definitions.

### Bug fixes

* (Playlist) When playing a track from the Favorites list, symlink paths would not get resolved before the playlist lookup and no playback would occur.
* (Playlist) Some scroll gestures would perform actions on all playlist views (tabs) instead of only the current view.

### Other improvements

* Now, the default setting for the "window layout on startup" preference is "remember layout from last app launch", which is the most suitable value.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.3.0)
