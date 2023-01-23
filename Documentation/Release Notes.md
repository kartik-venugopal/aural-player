#  What's New in Version 3.13.0

## Drag/drop and "Open With" enhancements

Many thanks to @zpete for requesting these enhancements !

### Drag/drop onto the main (player) window

The main (player) window now accepts drag/drop, so you can drag/drop files or folders directly onto it, and they will be added into the playlist. Depending on the new setting (described in the below section), the files/folders will either be appended to, or replace, the existing playlist tracks.

NOTE - The lower 90% of the main window accepts drag/drop ... only the top 10% or so does not.  

### New preference for drag/drop (from Finder) playlist behavior

This new preference can be adjusted under **Aural > Preferences > Playlist** and affects the playlist's behavior when dragging/dropping files or folders from Finder into Aural - both the main window and the playlist window. This way, users can decide the behavior they want instead of being stuck with one.

The above mentioned setting offers 3 modes:

* Append: This is the default (and currently the only) behavior ... files/folders are appended to the playlist.
* Replace: Dragged/dropped files/folders replace the existing playlist tracks.
* Hybrid: When ⌥ is pressed, replace mode will be activated, with append mode being the default.

### New preference for "Open With" (from Finder) playlist behavior

Similar to the setting for drag/drop playlist behavior, users can now adjust the behavior when opening files using "Open With" from Finder. Unlike the drag/drop setting, this setting does not offer the hybrid mode as key presses are not possible when performing this action.

### **For more info**
Visit the [official release page](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.13.0)
