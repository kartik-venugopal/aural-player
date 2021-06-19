#  What's New in Version 3.1.0

## Remote Control

*Remote Control* is the ability of Aural Player to be controlled from outside the application, for example, from the macOS Control Center (available in Big Sur) or by Apple accessories (eg. headphones) or 3rd party apps that are able to send ***MPRemoteCommand*** audio commands to macOS. 

Controllable functions: 

 * Play / pause
 * Stop
 * Previous / next track
 * Skip forward / backward
 * Seek to an arbitrary playback position 

When Remote Control is enabled, current audio information will be displayed within the "Now Playing" section of the macOS Control Center and/or the associated player widget that attaches to the menu bar. This includes the currently playing track's title, artist, album, cover art, playback position, etc.

This feature provides the abillity to control Aural Player through a familiar native interface such as Control Center, without having to switch to the app.

**NOTE** - This feature's capabilities are roughly comparable to that of Aural Player running in menu bar mode, although menu bar mode does provide some extra functions such as volume control, repeat, shuffle, segment looping, etc, and is more reliable.

### Media keys no longer require permissions

An advantage of the Remote Control feature is that, when enabled, media keys don't require OS-level Accessibility permissions in order to function. They should work by default out-of-the-box.

### Remote Control not available in menu bar mode

Note that when running Aural Player in menu bar mode, it will *not* be able to receive Remote Control commands.

### Known issue (macOS Control Center) - cover art

The macOS Control Center is unreliable and buggy at times, and can cause the currently playing track's cover art to disappear, appearing later when the UI is closed and reopened. This behavior is not exclusive to Aural Player; it can be observed when using the Control Center with other audio apps such as Spotify.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/3.1.0)
