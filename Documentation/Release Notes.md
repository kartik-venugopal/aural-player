#  What's New in Version 2.8.0

## Grouping playlists now remember sort order from last app launch

The hierarchical (or "grouping") playlist views, i.e. Artists, Albums, and Genres, will now remember their sort order from the previous app launch and reorder their groups / tracks accordingly upon app startup.

## Other changes

### Eliminated vulnerabilities in scheduling logic for non-native tracks

There were some vulnerabilities (potentially null references) in the code responsible for scheduling tracks decoded via ffmpeg, which were exposed by infrequently triggered race conditions ... these were introduced in v2.7.0. They have been eliminated.

### Reduced gap between tracks during playback

When a track is playing, Aural Player will predict which track might play next and prepare that track for playback ahead of time (open the file for reading). This will, in the most common cases, reduce track preparation time when that track is selected for playback, thus slightly reducing the gap of audible silence between tracks.

### Bug fix - Crash caused by playlist track removal

In some cases, removing tracks from the playlist caused a sudden crash. This issue has been fixed.

### Bug fix - Crash caused when viewing detailed track info

In some cases, viewing detailed track info caused a sudden crash. This issue has been fixed.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.8.0)
