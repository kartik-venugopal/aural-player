#  What's New in Version 2.5.0


## **Font schemes support**

Aural Player now allows extensive customization of its fonts and comes with a few built-in font schemes you can choose from. A font scheme consists of 2 fonts - a text font and a headings font, along with point sizes that can be specified for the various textual elements acoss the UI.

### **Older text size adjustment feature removed**

Note that the new font schemes feature set makes the previously offered text size adjustment feature (with 3 preset sizes) now obsolete, since font schemes offer far more functionality than mere text size adjustment. So, the text size adjustment feature has been removed.

### **Demo**

See a font schemes demo [here](https://raw.githubusercontent.com/maculateConception/aural-player/master/Documentation/Demos/FontSchemes.mp4)

### **Font scheme editor panel**

The new font scheme editor panel can be accessed either by going to **View > Font Scheme > Customize** under the main menu bar or from the settings popup menu at the top right corner of the main (player) window, by clicking **Font Scheme > Customize**.

* **Text font and headings font** - Choose 2 font faces which will be used for all the body text and headings respectively. Any font that is installed on your system can be used.

* **16 different UI textual elements** whose font sizes can be customized, e.g. player track title, playlist row text, effects unit captions, etc.

* **Playlist vertical text alignment**- You can also specify Y offsets in order to perfectly center playlist row text vertically. Since each font has different character dimensions, this is often necessary to achieve perfect vertical centering in playlist rows.

* **Undo/redo functionality** - You can roll back/forward individual changes (or all at once) to different versions of your customized scheme (history is reset when the panel is closed).

* **Apply/save preset schemes** - From the panel, you can load a preset font scheme as a starting point, modify a few properties, then save the new version as your own custom scheme, so you can create several variations of font schemes. You don't need to start from scratch everytime.

NOTE - Only the current system font scheme (i.e. the current scheme of the app UI) will be altered by this panel. Any preset you have applied will remain unchanged (presets only serve as a starting point).

### **Built-in font schemes**

There are 6 built-in font schemes, one of which is the default scheme, "Standard", that is applied when the app is started up for the first time before altering the font scheme.

They can be accessed from the submenu under **View > Font Scheme** or from the settings popup menu at the top right corner of the main (player) window, under the **Font Scheme** submenu. They can also be applied from within the editor panel.

### **Font schemes manager**

The new font schemes manager allows users to preview, rename, apply, and/or delete user-defined font schemes. This is useful if:

* You want to give your schemes more meaningful or cooler names.
* You've forgotten what one of your custom schemes looks like, and want to visually preview it.
* You have duplicates or simply want to reduce clutter and delete old schemes no longer preferred or in use.

Access the font schemes manager by going to **View > Manage font schemes**.

NOTE - You cannot alter built-in font schemes ... only your own.

### Bug fixes

* Fixed the popup menu auto-close bug that was introduced in v2.3.0.
* Fixed a typo in some help text in the preferences dialog.

### Other UI refinements

* Text fields across the UI have better logic for vertical centering of text, and have been resized to accommodate a wide variety of font faces / sizes.
* The alignment of text and images in the playlist table view, and summary fields, has been improved for better aesthetics.
* Playlist rows are now more spaced out to accommodate a wider variety of font faces / sizes.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.5.0)
