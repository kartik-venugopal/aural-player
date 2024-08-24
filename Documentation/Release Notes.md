#  What's New in Version 4.0.0-preview9

## Replay Gain

A new effects unit has been added - Replay Gain. This new unit will either boost or attenuate the audio signal based on either metadata contained in tracks (eg. ID3, iTunes Norm, Vorbis Comment, Cue sheet REM) or by analyzing the files for loudness/peak information - replay gain values will then be computed based on a target loudness of -18 dBFS. Both track gain and album gain information can be computed and used.

NOTES:

1 - No modifications (tags or normalization) will be performed on the audio files themselves. Audio files will remain completely unmodified.

2 - The target loudness of -18 dBFS is not measured but is assumed to be the "baseline" loudness when the Replay Gain unit is bypassed. All other audio settings (player volume, EQ pre-amp, etc) affect the baseline loudness, and the Replay Gain unit then offsets that loudness by applying gain on a per-track or per-album level.

Additional options:

- A pre-amp slider lets the user offset the gain by a desired amount to achieve their ideal target loudness.
- Clipping prevention (possible when peak loudness is either available as metadata or computed via analysis)
- Choice of data source between metadata and analysis (or both)
- Configurable max peak level (used for clipping protection). 0 dBFS is the maximum possible value for this setting, and it can be reduced down to -5 dBFS.   

### **For more info**
Visit the [official release page](https://github.com/kartik-venugopal/aural-player/releases/tag/4.0.0-preview)
