#  What's New in Version 3.25.0

## Last.fm Scrobbling

Thanks to Erik Jälevik for requesting this feature!

Aural can now scrobble tracks you play to your Last.fm account!

### Love/Unlove tracks

In addition to scrobbling, Aural can also "love" or "unlove" tracks that you add to / remove from the Aural "Favorites" list.

### One-time authentication / setup

In order to use these features, go to Aural > Preferences > Metadata, and first follow the instructions on the preferences panel to authenticate with Last.fm and provide permission to Aural to use Last.fm's web services (in your web browser). This is a one-time setup step. Then, simply check the relevant checkboxes to enable scrobbling and the love/unlove feature.

### The rules for a valid scrobble

In order to consider playback of a track a "valid scrobble", certain conditions must be met in terms of track duration and playback duration. 

See https://www.last.fm/api/scrobbling#when-is-a-scrobble-a-scrobble for details.

### Caching and retrying of failed scrobble attempts

If / when scrobble attempts fail due to loss of network connectivity or any other reasons, Aural will cache the failed attempts and try to scrobble 4 more times per track (for a total of 5 attempts), upon subsequent app launches. Any failed scrobbles more than 2 weeks old will automatically be invalidated.

### Re-authenticating to refresh the Session Key

When Aural authenticates with Last.fm, it obtains a **Session Key** that is persisted and reused indefinitely. In the unlikely scenario that the Session Key no longer works (you notice that scrobbling no longer occurs), it is recommended to re-authenticate and obtain a fresh Session Key, using the "Re-Authenticate" button in the relevant preferences panel.

### **For more info**
Visit the [official release page](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.25.0)
