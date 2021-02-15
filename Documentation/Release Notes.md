#  What's New in Version 2.4.0

This release adds support for a few popular audio formats:

* True Audio ( .tta)
* Tom's lossless Audio Kompressor (.tak)
* Real Audio (.ra, .rm)
   + RealAudio 1.0 (14.4K)
   + RealAudio 2.0 (28.8K)
   + RealAudio Lossless
   + RealAudio SIPR / ACELP.NET
   + RealAudio G2 (Cook / Cooker / Gecko)
   
#### NOTE 

1 - Since none of these formats are native to macOS / CoreAudio, they are supported via transcoding (by Aural Player's use of ffmpeg). Lossless formats will be transcoded to AIFF, while lossy formats will be transcoded to AAC.
2 - TAK support is limited by ffmpeg's TAK support; not all TAK codec variants are supported.
   
### FFmpeg version upgraded from 4.1 to 4.3.1

### Bug fixes

* (Transcoder) When transcoding fails, the transcoder progress view remains in sight ... this has been fixed.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/2.4.0)
