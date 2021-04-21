#  What's New in Version 2.12.0

## Menu bar player mode

Aural Player can now run in the macOS menu bar. This is useful for reducing desktop clutter or for running Aural Player in a "lightweight" less resource-intensive or "background" mode. CPU and memory usage will be reduced when running in menu bar mode. 

A typical use case for this feature is when the playlist has been created and sound settings have been set, and the user wants to play the playlist without needing to interact frequently with the application.

The app may be easily and seamlessly switched between the regular windowed mode and the new menu bar mode as follows:

* **When in windowed mode**:  Click the "Switch to menu bar mode" button at the top left corner of the main player window, to switch to menu bar mode.
* **When in menu bar mode**:  Click the "Switch to windowed mode" button at the top left corner of the menu bar player, to switch to windowed mode.

#### Player view settings

You can control what track information is displayed (eg. artist / album / cover art, etc) by clicking the hamburger icon button at the top right corner of the menu bar player view. This will open / close the view settings menu.

### Limited functions / settings available in menu bar mode

Note that when running the app in menu bar mode, you will have access to only the most essential player functions like changing tracks, seeking, repeat / shuffle / looping, volume control, and a few view settings (described in the above section). This is by design ... the menu bar mode is meant to be as simple and lightweight as possible. For more customization or to access more functionality, the app can be run in the regular windowed mode.

## Performance improvements

### Improved lazy window loading

All application windows / dialogs are now lazily loaded only when they are actually required. This speeds up app startup time and reduces unnecessary CPU / memory usage.

### Fixed memory leaks

Fixed a lot of memory leaks present in the UI, so that views, windows, and model objects are properly released when switching between windowed and menu bar modes.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.12.0)
