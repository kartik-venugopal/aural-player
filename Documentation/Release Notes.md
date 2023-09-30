#  What's New in Version 3.23.0

## Bug Fixes

### #65 - FFmpeg seeking causes crash (arm64)

Previously, seeking with FFmpeg (within non-native tracks) would cause a crash on arm64 systems. This has been fixed.

### #64 - Spectrogram visualization shows no activity in first band 

The first band of the Spectrogram visualizer view would, in some cases, not show any activity / movement. A workaround for this bug has been implemented.

### #66 - Seek interval stepper controls (preferences)

In the preferences window, under the Playback tab, the seek interval stepper controls showed the wrong kind of formatting on newer macOS systems. The stepper controls have been simplified to solve this problem.   

### **For more info**
Visit the [official release page](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.23.0)
