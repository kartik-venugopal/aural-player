#  What's New in Version 2.3.0

This release is the only stable release version of Aural Player that runs on macOS Big Sur. Therein lies its purpose. No new functionality has been added. In other words, v2.2.0 and v2.3.0 are largely the same. One minor feature has been removed in this release (details below), and some bugs have been fixed.

Of course, Aural Player continues to remain backwards compatible all the way back to macOS 10.12 Sierra.

## App state location changed

**IMPORTANT for existing Aural Player users**

In order to circumvent the hassle of macOS security restrictions, the location where the app stores its persisted state has changed from *~/Documents* to *~/Music*. This means that if you are upgrading from an older version of Aural Player (v2.2.0 or older), you need to move your app state directory from *~/Documents* to *~/Music* (exact steps listed below). Otherwise, note that you will lose all your previously saved app settings (playlist, sound settings, favorites, history, color schemes, window layouts, etc).

Perform the following simple steps when upgrading from v2.2.0 (or any older version) to v2.3.0.

* Quit Aural Player v2.2.0 (or any older app version) if it is running.
* Move the folder named ***aural*** in your user's *Documents* folder, to your user's *Music* folder.
* Download/install Aural Player v2.3.0 (i.e. this build) and run it.

## Improvements

### Playlist (back end)

Major refactoring of the playlist code in all app layers:

* Simplification and optimization using functional programming (map/filter/reduce) leading to much more concise code. Reduced lines of code by > 2000.
* Factored out lots of redundant code into common utilities.
* Implemented safe checking of optional values.
* Improved interface definitions and reduced redundant code in struct definitions.

### Bug fixes

* (M3U playlists) M3U playlists with ISO-8859 encoding were not being read. Also, references to online streams were being treated as files.
* (Playlist) When playing a track from the Favorites list, symlink paths would not get resolved before the playlist lookup and no playback would occur.
* (Playlist) Some scroll gestures would perform actions on all playlist views (tabs) instead of only the current view.
* Per [Github Issue #22](https://github.com/maculateConception/aural-player/issues/22), the playlist sort dialog now remembers its previously selected options while the app remains open. Closing and reopening the app will reset the sort options.

### Other improvements

* Now, the default setting for the "window layout on startup" preference is "remember layout from last app launch", which is the most suitable value.
* Now, the default setting for the "playlist view on startup" preference is "remember view from last app launch", which is the most suitable value.

## Delayed playback feature removed

Due to excessive code complexity and a disproportionate complexity / benefit ratio, the feature that allowed users to insert time delays before / after / between playback of tracks has been removed. If you really need this feature, and you're on macOS Catalina or older, it is advisable to use v2.2.0.

## Known issue

(Only on macOS Big Sur)

Sometimes, when in-app popup menus are opened for the first time (since an app launch), they immediately close on their own. Opening them a second time fixes the issue. This requires further investigation and may be fixed at a later date.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.3.0)
