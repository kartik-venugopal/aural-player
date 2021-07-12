#  What's New in Version 3.3.0

## Simplified persistence with Codable

The way the application reads / writes all its state to / from disk (as JSON) has been greatly simplified and made more reliable, also resulting in the elimination of a lot of boilerplate code (approximately 1000 lines of code).

All persistent model objects now conform to **Codable**, so they can take advantage of the built-in encoding and decoding performed by **JSONEncoder / JSONDecoder**. All the ugly and error-prone dictionary type-casting code has been completely eliminated, resulting in much cleaner and leaner model object code.

The changes are completely backward compatible, so app state persisted by previous app versions can be decoded without issues by this app version. No user settings will be lost when upgrading to this app version.

### Bug fixes

* **Tooltips** - The 4 function buttons on the right edge of the player were not displaying their tooltips. This is no longer an issue.

* **Genre names** - Sometimes, genre names in the **Genres** playlist view were displayed as a genre code followed by the genre name, eg. "(9)Metal". Now, they will be parsed properly and displayed without the genre code.

* **Crash** - When in control bar mode, if the user performed a gesture with the app in focus, the app would crash. This bug has been fixed.

### Unit testing

* Restored some unit tests that were previously decommisioned.
* Persistence layer is now 100% covered with new tests.
* Added tests for audio graph initialization, preferences, and playlist.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/3.3.0)
