#  What's New in Version 3.15.0

## Fixed FFmpeg memory leak (issue #53)

Many thanks to @lijuncode for coming up with this fix for issue #53 !

When FFmpeg is unable to receive a frame from the codec, the memory allocated to receive the frame should be freed. This was not being done before.

## Info panel text is now selectable (issue #55)

Text in the detailed track info panel (on all tabs) is now selectable, and so can be copied. Thanks to @XhstormR for suggesting this improvement.

NOTE - Since the text in the info panel is in a table view, the text to be copied must first be clicked. That will put that row of the table in focus, allowing the user to copy the text.

### **For more info**
Visit the [official release page](https://github.com/kartik-venugopal/aural-player/releases/tag/v3.15.0)
