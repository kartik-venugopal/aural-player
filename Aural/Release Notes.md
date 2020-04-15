#  What's New in Version 1.7.0


## **Chapters support for audiobooks/podcasts**

Aural Player can now read and display chapter markings from tracks¹, and offers convenient chapter playback functions. This is especially useful for audiobooks or podcasts (eg. M4B audiobooks from Librivox).

### **UI features**

* Tabular display of chapters in a new "Chapters list" window (chapter title, start time, and end time). This window will automatically pop up when a track that has chapter markings begins playing (automatic popup can be disabled in Playlist preferences)
* Type selection and search for chapter by title ("Chapters list")
* Marker showing currently playing chapter
* Current chapter title displayed in player window

### **Playback functions:**

The following functions are available within the Chapters list window and also through new menu items under the **Playback** menu.

* Play / replay desired chapter
* Previous / next chapter
* Loop current chapter

### **New allowed file extensions**

Previously, files with these extensions could not be added to the playlist.
* M4B
* M4R

1. Testing has been done on M4B (AAC), MP3, WMA, Opus, and Ogg Vorbis files, although other file formats with properly encoded chapter markings should also be readable.

## **Ability to show/hide playing track metadata fields**

The player window, which shows currently playing track metadata, now allows the user to individually show/hide each of the 3 metadata fields (when they are available to be displayed):

* Artist
* Album
* Current chapter title

## **Bug fixes**

* **Playlist text size** - The Playlist text size setting was not being remembered properly and was using the player text size setting instead. 

* **Player crash in rare cases** - When a segment loop was defined with its end time coinciding with the end of the track, and then the loop was removed, track completion would not be detected and the player would freeze because of a playback segment being scheduled with a zero frame count.

* **Metadata text cutoff** The **Metadata** tab in the detailed track info popover was only capable of displaying a small number of lines of text, so large text values like comments would be cut off.

## **Enhancements**

* Slight aesthetic refinements to player UI:  seek bar, volume and pan sliders, playback control icons, detailed track info popover, etc.

## **"Show new track" preference moved**

The **"Show new track in playlist"** user preference has been moved from the **Playback** tab to the **Playlist** tab of the Preferences dialog. Note that this change is not backwards compatible, so users of previous Aural Player versions will have to reset this setting as preferred after downloading v1.7.0.

## **Shrunk the source code download ZIP archives**

The source code archives no longer contain the massive Documentation folder and ffmpeg binaries which took more than 100MB of space. The archives are now only about 11 MB in size.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/1.7.0)

### **Free audiobooks**
To obtain free public domain audiobooks to test these new Aural Player features, visit [LibriVox](https://librivox.org/)
