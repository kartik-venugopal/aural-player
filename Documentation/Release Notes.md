#  What's New in Version 2.6.0

## Visualizer

A new visualizer window displays colorful visualizations that dance to the beat of the music currently playing in Aural Player. 

3 different visualization types are available, and the colors used to render the visualization can be customized:
* Spectrogram - 10 bars that represent different frequency bands will resize and recolor depending on the current amplitude of sounds at those frequencies.
* Supernova - A glowing ring of "stellar material" that rotates and explodes or implodes as the bass frequencies get louder or softer.
* Disco Ball - A disco ball that rotates and expands or shrinks as the bass frequencies get louder or softer, with lights that flash when the bass loudness crosses a certain threshold.

You can open the Visualizer window by going to the menu **View > Visualizer window** or its associated keyboard shortcut ⌘4.

The window is resizable by dragging from its lower right corner. The visualization type and options (colors) can be changed by hovering the mouse anywhere over the visualizer window, which will bring up the auto-hiding visualizer options menu.

### Known issue - visualization gets stuck

If the visualization rendering freezes or gets stuck (esp. when changing the visualization type), simply reselect it from the menu or close and reopen the visualizer window. This is a known issue that sometimes occurs, with no known fix yet.

### Increased CPU / GPU usage

Note that rendering visualizations will cause CPU/GPU usage to rise (10 - 25 %) while the visualizer window is open. If you're running a laptop, please beware of the energy impact on your battery life.

### Note about older systems

This feature may or may not work properly on older operating systems (particularly 10.12 Sierra and 10.13 High Sierra) and/or older Mac hardware. I have access to a very limited amount of hardware, so cannot state with confidence how well it will work across all available Mac hardware.

### Note about system audio settings

The visualizer relies on the output device's buffer size being set to a certain optimal number, and will attempt to set it to that number. If your output device is not able to support that buffer size, the visualizer may not work at all.

Also, if you attempt to change the output device's sample rate and/or format while the app is running, the visualizer may crash or not work at all.

### Please report issues

I'd appreciate users filing issues for any problems they experience with this feature, since that helps me greatly.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.6.0)
