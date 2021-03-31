#  What's New in Version 2.9.0

## MusicBrainz cover art lookup

For tracks that don't have cover art but have artist and album / title metadata, Aural Player will try to retrieve cover art for the track, from the MusicBrainz online music metadata database.

### MusicBrainz lookups preferences

#### Enable / disable cover art lookups

MusicBrainz cover art lookups can be enabled or disabled by going to the **Metadata** tab of the preferences dialog that can be accessed from the menu **Aural > Preferences**.

Select or unselect the check box titled *"Search MusicBrainz database for cover art".*

By default, MusicBrainz cover art lookups will be enabled.

#### Enable / disable on-disk caching

For a better user experience, Aural Player will cache, on disk, any cover art retrieved from MusicBrainz, for later reuse when loading cover art for the same album / track. This prevents unnecessary redundant online lookups for cover art that was retrieved before.

This caching feature can be enabled or disabled by going to the **Metadata** tab of the preferences dialog that can be accessed from the menu **Aural > Preferences** and selecting the appropriate radio button.

By default, on-disk caching of MusicBrainz cover art will be enabled.

## Bug fix - Grouping Playlists

In rare cases when a track's metadata (eg artist) changed between app launches, the grouping playlists would cause a crash on app startup.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.9.0)
