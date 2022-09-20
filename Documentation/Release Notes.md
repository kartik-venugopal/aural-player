#  What's New in Version 3.7.0

## Improved FFmpeg integration 

This release does not bring any user-facing changes, i.e. it is functionally identical to v3.6.0. The sole purpose of this release
is an improved approach to integration with FFmpeg libraries.

The way that FFmpeg libraries are integrated into, and used by, the Aural Player project has been improved:
* The use of XCFrameworks instead of raw .dylib (shared libraries).
* Better encapsulation of FFmpeg headers (in XCFrameworks) ... removed from project source.
* No changes to resulting app bundle size.

### **For more info**
Visit the [official release page](https://github.com/maculateConception/aural-player/releases/tag/3.7.0)
