#  What's New in Version 2.7.0

## Real-time playback and faster loading of non-native tracks

The way that Aural Player reads tracks of non-native audio formats (e.g. Vorbis, APE, True Audio, WMA, etc) has completely changed (improved). This has resulted in an improved user experience. 

### Real-time playback

Aural Player is now able to decode and immediately play non-native tracks without any delay. So, the user experience is now identical to that for playback of natively supported tracks, and doesn't require a time / storage overhead for transcoding like before.

### Faster and more reliable loading of metadata

Now, metadata is read directly from the tracks on disk. This is much more efficient and reliable, and doesn't require storing temporary files on disk.

### How ?

Previously, Aural Player spawned an instance of ffmpeg as a child process, to transcode non-native tracks and read metadata from them, and parsed textual data from ffmpeg before those tracks could be loaded into the playlist and played back. This was slow, computationally expensive, somewhat unreliable (due to inter-process communication), and required extra storage (for temporary files). It was also much more complex from a development / testing / maintenance standpoint.

Now, Aural Player makes direct calls to FFmpeg's libraries in-process, no longer needing to spawn an ffmpeg child process.

### Other changes

* Removed support for raw DTS files (.dts)
* Bug fix: Tool tips for buttons in player view weren't being shown. 

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.7.0)
