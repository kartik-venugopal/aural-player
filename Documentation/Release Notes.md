#  What's New in Version 2.1.0

### Enhancements

* Playback scheduling - The playback scheduler has been significantly redesigned and rewritten, greatly improving reliability and eliminating the possibility of crashes in the player. 

### Bug fixes

* Incorrect computation of track duration ... now it is precisely computed just before playback
* Auto-hide of controls in player view
* Formatting of track times in player view ... sometimes, negative numbers were displayed
* The playlist would notify that the playing track was removed at times when it was not.
* When a delayed/transcoding track was moved within the playlist, the row for the playing track would not update when playback started
* Race condition: When a favorite/bookmark/history track was played very near the end of a currently playing track, the player would skip the user-selected track.
* Width of text field in player view (was not fully extended)

### Performance improvements

* Lazy loading of chapters list window (should reduce memory usage on startup)

### Other improvements

* Complete refactoring of player views and associated controllers
    * Greatly simplified, easy to maintain, more reliable
    * Unit tests added for critical player components
    
* Upgrade to Swift v5.1.3 (Xcode v11.3)

* Complete source code restructuring
   * Re-organized project meta files, resources, and documentation
   * Every source group now has an associated filesystem folder
   
* Cleanup of old screenshots and demos from the repository

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.1.0)
