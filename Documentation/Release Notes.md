#  What's New in Version 3.3.0

## Simplified persistence with Codable

The way the application reads / writes all its state to / from disk (as JSON) has been greatly simplified and made more reliable, also resulting in the elimination of a lot of boilerplate code (approximately 1000 lines of code).

All persistent model objects now conform to **Codable**, so they can take advantage of the built-in encoding and decoding performed by **JSONEncoder / JSONDecoder**. All the ugly and error-prone dictionary type-casting code has been completely eliminated, resulting in much cleaner and leaner model object code.

The changes are completely backward compatible, so app state persisted by previous app versions can be decoded without issues by this app version. No user settings will be lost when upgrading to this app version.

### Other improvements

* **Faster playlist search** - Parallelized playlist search operations that were being performed serially, potentially cutting down search times, noticeably with large playlists.

### Unit testing

* Restored unit tests that were previously decommisioned.
* Persistence layer is now 100% covered.
* Added tests for preferences and playlist components.

Unit testing is still a work in progress, so code coverage is still low, but should improve over time.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/3.3.0)
