#  What's New in Version 2.10.0

## Audio Units (AU) plug-ins support

Aural Player can now host Audio Units (AU) effects and analysis plug-ins, either those provided by macOS or any 3rd party plug-ins installed on the user's system. This provides unlimited possibilities for advanced sound tweaking and monitoring / analysis, in addition to the effects units and visualizations already built into Aural Player.

### What kinds of Audio Units plug-ins are supported ?

In order to be hosted by Aural Player, the AU plug-in must meet 2 requirements:

1 - The plug-in must be a **real-time** audio processing unit with a component type that is one of the following:

- kAudioUnitType_Effect
- kAudioUnitType_MusicEffect
- kAudioUnitType_Panner

Note that some sound monitoring and/or analyis plug-ins (eg. spectrum analyzers and level meters) will have one of these component types, so they are able to be hosted by Aural Player, even though they do not alter the audio signal. Note that instruments such as synthesizers or tone generators usually have a different component type (kAudioUnitType_Generator), so will likely not be supported.

2 - Also, the plug-in must provide a custom user interface (hasCustomView == true), because the custom view is how the user will interact with and manipulate the Audio Unit.

###  New Effects panel tab

The Effects panel / window now has a new tab titled "AU", where you can add / import your Audio Units. The units you've added will be displayed in a table.

#### Adding Audio Units

When you click the "+" button below the Audio Units table, a menu will be displayed listing all Audio Units available on your system, and will include the name, version number, and manufacturer name of each Audio Unit. Click one of these to add a corresponding Audio Unit.

Each audio unit that you add will be inserted into Aural Player's signal processing chain. There is no limit to the number of units you can add. 

NOTE - Each audio unit will add to CPU / energy utilization and add a small amount of audio latency.  Some audio units may misbehave or cause very high energy usage, which can be an issue on Macbook devices.

### Bypass switch

Each audio unit will have an associated bypass switch (similar to the effects units built into Aural Player) you can use to activate / deactive the unit as desired.

NOTE - Just like with the effects units built into Aural Player, bypassing (deactivating) the Master effects unit will also bypass all your audio units.

### Audio Unit editor dialog

To change the settings of any of your audio units, click the settings icon in the table row for your audio unit, or double-click the table row. This will bring up the audio unit editor dialog, where the audio unit's custom view will be displayed, allowing you to change the unit's parameters by manipulating sliders and other controls.

#### Factory presets

Some Audio Units come with factory presets. For those that do, the audio unit editor dialog will display a list of them, allowing you to apply them to the audio unit.

#### User presets

User presets for audio units are only supported on macOS 10.15 and newer systems. Also, they are not supported by all audio units. When an audio unit supports user presets, the audio unit editor dialog will display a list of them, allowing you to save new ones or apply existing ones to the audio unit.

### Where can I find free Audio Units to try out with Aural Player ?

[Here is one page that lists many available (free) Audio Units.](https://www.kvraudio.com/plugins/effects/macosx/audio-units/free/most-popular)

#### Some free Audio Units supported by Aural Player

The following are examples of Audio Units that have been tested and are known to work with Aural Player, and are available for download, free of cost:

- TDR Nova Equalizer [Download from here](https://www.kvraudio.com/product/tdr-nova-by-tokyo-dawn-labs)
- FreqAnalyst spectrum analyzer [Download from here](https://www.kvraudio.com/product/freqanalyst-by-blue-cat-audio)
- TAL-Reverb-III [Download from here](https://www.kvraudio.com/product/tal-reverb-iii-by-togu-audio-line)
- Blue Cat Flanger [Download from here](https://www.kvraudio.com/product/flanger-by-blue-cat-audio)

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.10.0)
