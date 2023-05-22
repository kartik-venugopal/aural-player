#  What's New in Version 3.17.0

## Fixed button focus issue (M2 Pro / Ventura)

On an M2 Pro machine running macOS Ventura, I discovered that the close button ('X') would be in focus on app startup ... this had 2 undesirable consequences:
1. The button looked ugly with a focus ring around it.
2. When the Space key was pressed to initiate playback, a button press would be triggered, quitting the app.

This issue has been fixed.

## Dropped support for macOS 10.12 Sierra

Xcode 14 does not support building for macOS Sierra.

### **For more info**
Visit the [official release page](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.17.0)
