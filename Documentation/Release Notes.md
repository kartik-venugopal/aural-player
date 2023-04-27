#  What's New in Version 3.16.0

## Fixed issue #51 - log bloating (I/O errors)

Many thanks to @LesterJitsi for reporting this issue !

When a non-native track (i.e. one that requires decoding by FFmpeg) located on an external drive is playing, and then the external drive is unplugged from the system while the track is still playing, previously, the FFmpeg decoding loop would continue endlessly trying to read the track, despite repeated I/O errors.

This had 2 undesirable consequences: 

1. The I/O errors would all get logged in Aural.log, leading to a very large log file 100s of MB in size. 
2. The player would continue displaying the track, as if it were still playing, even though there was no audio being produced.  

Now, the FFmoeg decoding loop is smarter - if it sees 5 consecutive unsuccessful packet read attempts (indicated by packet read exceptions), it will interpret that as a fatal / unrecoverable error, and the loop will be terminated. The portion of the track that has been successfully read will continue playing, and playback will then move on to the next track in the playlist.

## Fixed issue #36 - loss of app state during crashes (state.json)

When the app needs to be forcibly closed with "Force Quit", or during other unexpected crashes, the most recent app state (eg. playlist state, UI state, player controls state, etc) is lost. 

In order to significantly mitigate this issue, the app will now periodically save its state to storage in the background, every minute, so that in the event of an unexpected crash, very little app state (from the last minute or so of use) will be lost.

### **For more info**
Visit the [official release page](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.16.0)
