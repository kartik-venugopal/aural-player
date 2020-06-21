#  What's New in Version 2.2.0

### Messaging framework (back end) redesign

The internal messaging framework has been redesigned and reimplemented as a thin wrapper around NotificationCenter, resulting in much cleaner and more concise notification handling code throughout the app. Lines of code have been reduced by around 2400.

### Bug fixes

* (Chapter playback) Chapter playback functions wouldn't work at all if chapters list window had never been displayed.
* (Player) Reported seek time was slightly inaccurate, resulting in weird UI displays during chapter playback.
* (Transcoder crash) When the playing track was removed from the playlist, the transcoder sometimes caused a crash.
* (Playlist) When all tracks were removed from the playlist, the summary (number of tracks) was not updated in some rare cases.
* (Player) The current chapter title did not update properly when it was hidden and then shown again.
* (Player) The seek slider did not redraw when a segment loop was removed (if paused)
* (Dock menu) Certain menu items in the dock menu were not updating properly.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.2.0)
