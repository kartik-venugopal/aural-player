#  What's New in Version 2.9.0

## MusicBrainz cover art lookup

For tracks that don't have cover art but have artist and album / title metadata, Aural Player will try to retrieve cover art for the track, from the MusicBrainz online music metadata database.

### MusicBrainz lookups preferences

The following preferences can be set by going to the **Metadata** tab of the preferences dialog that can be accessed from the menu **Aural > Preferences**.

#### Enable / disable cover art lookups

If you do not want to incur any internet data usage, or do not have internet connectivity, or otherwise don't want MusicBrainz lookups, you can disable them completely.

By default, MusicBrainz cover art lookups will be enabled.

#### Set an HTTP timeout

You can set a timeout interval (specified in seconds) for HTTP requests made to MusicBrainz. If you have a slow internet connection, this may be necessary, although the default timeout interval of 5 seconds should be sufficient for most scenarios.

#### Enable / disable on-disk caching

For a better user experience, Aural Player will cache, on disk, any cover art retrieved from MusicBrainz, for later reuse when loading cover art for the same album / track. This prevents unnecessary redundant online lookups for cover art that was already retrieved before. It also reduces internet usage and the number of requests sent to MusicBrainz. 

By default, on-disk caching of MusicBrainz cover art will be enabled.

### Note about accuracy of cover art lookups

Note that the accuracy of cover art lookups or relevance of the chosen image to the corresponding track depends on:

* The relevance of the images uploaded to MusicBrainz (and they are not always the right images).
* Selecting a cover art image from a range of available cover art images ... which is not an exact science, and uses several criteria, eg - artist name, album name, title, release date, etc to maximize relevance.

Despite this, Aural Player may sometimes display false positives, i.e. art that is not accurate for the corresponding track. This is inevitable. 

## Bug fix - Grouping Playlists

In rare cases when a track's metadata (eg artist) changed between app launches, the grouping playlists would cause a crash on app startup.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.9.0)
