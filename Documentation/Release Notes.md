#  What's New in Version 2.1.0

### Player (back end) redesign

All back end player sub-components have been significantly redesigned and rewritten, improving reliability and testability, and reducing the possibility of crashes.

### Bug fixes

* Incorrect computation of track duration in some cases ... now it is precisely computed just before playback
* Auto-hide of controls in player view was inconsistent
* Formatting of track seek times in the player view ... sometimes, negative numbers were displayed
* Width of text field in player view (was not fully extended)
* When a delayed/transcoding track was moved within the playlist, the row for the playing track would not update when playback started
* The playlist would notify that the playing track was removed at times when it was not.
* Race condition: When a favorite/bookmark/history track was played very near the end of a currently playing track, the player would skip the user-selected track.
* Per-track sound settings were not saved when a track was stopped.

### Other improvements

* Lazy loading of chapters list window (should reduce some memory usage on app startup)

* Transcoder view (in player window) improved and made consistent with other track info views

* Complete refactoring of player views and associated controllers
    * Simplified, easier to maintain, more reliable
    
* Upgrade of source code to Swift v5.1.3 (Xcode v11.3)

* Complete source code restructuring
   * Re-organized project meta files, resources, and documentation
   * Every source group now has an associated filesystem folder
   
* Cleanup of old screenshots and demos from the repository

#### Introduction of unit tests

* Unit tests have been added for critical player components.

* How dependencies are created / injected has been modified in many classes, in order to facilitate mocking and unit testing.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.1.0)
