#  What's New in Version 3.12.0

## Current effects preset indication

The built-in effects units will now indicate the currently selected preset when applicable (i.e. no changes have been made after selecting a preset). The current preset for any effects unit can be discovered by opening its presets menu that is displayed via the "Load preset" button - the corresponding menu item will have a check mark next to it.

Also, when audio settings have been remembered and re-applied for a track (when it starts playing), the current preset will also be indicated if applicable.

### Other changes

* Improvement - When a track that has remembered audio settings finishes playing, the previous audio settings will be restored.
* Improvement - Smarter (faster) loading of cover art for non-native tracks decoded by FFmpeg.
* Improvement - Some minor optimizations to FFmpeg decoding to prevent redundant computations.

* Bug fix - The Master presets menu button didn't do anything.
* Bug fix - Presets menu recreation failed in rare cases.
* Bug fix - The option to not remember audio settings for a track could not be disabled. 

### **For more info**
Visit the [official release page](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.12.0)
