#  What's New in Version 2.2.0

### Messaging (back end) redesign

The internal messaging framework has been redesigned as a thin wrapper around NotificationCenter, resulting in much cleaner and more concise notification handling code throughout the app.

### Bug fixes

* (Chapter playback) Chapter playback functions don't work at all if chapters list window has never been displayed.
* (Transcoder crash) When the playing track is removed from the playlist, the transcoder sometimes causes a crash.
* (Playlist) When all tracks are removed from the playlist, the summary (number of tracks) is not updated in some rare cases.
* (Player) The current chapter title does not update properly when it is hidden and then shown again.
* (Player) The seek slider does not redraw when a segment loop is removed (if paused)

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.2.0)
