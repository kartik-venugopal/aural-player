#  What's New in Version 2.10.0

## Audio Units (effects) support

Aural Player can now host Audio Units (AU) effects plug-ins, either those provided by macOS or any 3rd party plug-ins installed on the user's system. This provides unlimited opportunities for sound tweaking, in addition to the effects units already built into Aural Player.

NOTE - The Audio Unit plug-in must be an ***effects*** plug-in, i.e. its component type must be kAudioUnitType_Effect (type name must be AVAudioUnitTypeEffect). Instruments / synthesizers, mixers, etc. are not supported. Also, the Audio Unit must provide a custom user interface (hasCustomView == true), for Aural Player to be able to host it.

###  New Effects panel tab

The Effects panel / window now has a new tab titled "AU", where you can add / import your Audio Units. The units you've added will be displayed in a table.

Each audio unit that you add will be inserted into Aural Player's signal processing chain. There is no limit to the number of units you can add. However, note that each unit will add a small amount of latency.

### Bypass switch

Each audio unit will have an associated bypass switch (similar to the effects units built into Aural Player) you can use to activate / deactive the unit as desired.

NOTE - Just like with the effects units built into Aural Player, bypassing (deactivating) the Master effects unit will also bypass all your audio units.

### Audio Unit editor dialog

To change the settings of any of your audio units, click the settings icon in the table row for your audio unit, or double-click the table row. This will bring up the audio unit editor dialog, where the audio unit's custom view will be displayed, allowing you to change the unit's parameters by manipulating  sliders and other controls.

#### Factory presets

Some Audio Units come with factory presets. For those that do, the audio unit editor dialog will display a list of them, allowing you to apply them to the audio unit.

#### User presets

User presets for audio units are only supported on macOS 10.15 and newer systems. Also, they are not supported by all audio units. When an audio unit supports user presets, the audio unit editor dialog will display a list of them, allowing you to apply them to the audio unit.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.10.0)
