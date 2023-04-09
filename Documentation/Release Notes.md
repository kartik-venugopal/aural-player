#  What's New in Version 3.15.0

## Fixed FFmpeg memory leak

Many thanks to @lijuncode for coming up with this fix for issue #53 !

When FFmpeg frame allocation fails, the memory allocated to receive the frame should be freed. This was not being done before.

### Info panel text is now selectable - issue #55

Text in the detailed track info panel is now selectable, so can be copied. Thanks to @XhstormR for suggesting this improvement.

### **For more info**
Visit the [official release page](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.15.0)
