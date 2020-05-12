#  What's New in Version 2.1.0


### Bug fixes

* Incorrect computation of duration ... now it is precisely computed just before playback
* Auto-hide of controls in player view
* Formatting of track times in player view ... sometimes, negative numbers were displayed
* Width of text field in player view (was not fully extended)

### Performance improvements

* Lazy loading of chapters list window (should reduce memory usage on startup)

### Other improvements

* Upgrade to Swift v5.1.3 (Xcode v11.3)
* Complete source code restructuring
   * Re-organized project meta files, resources, and documentation
   * Every source group now has an associated filesystem folder
   
* Cleanup of old screenshots and demos from the repository

* Complete refactoring of player views and associated controllers
   * Greatly simplified, easy to maintain, more reliable

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.1.0)
