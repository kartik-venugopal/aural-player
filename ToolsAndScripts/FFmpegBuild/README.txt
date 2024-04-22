Instructions to build universal FFmpeg shared libaries (.dylib) from source.
These binaries can run on both Intel x86_64 and arm64 (i.e. M1) architectures.

NOTE - Pay attention to licensing requirements / considerations if / when distributing these libraries.

Pre-requisites (need to be installed on this system):

1 - Xcode 12.2 or a later version. macOS SDK version must be 11.0 or greater (for arm64).
2 - Homebrew (Instructions here: https://brew.sh/)
3 - nasm - assembler for x86 (Run "brew install nasm" ... after installing Homebrew)
4 - clang - C compiler (Run "xcode-select --install")
5 - pkg-config (Run "brew install pkg-config")

Steps:

1 - Open a terminal window.

2 - cd to the directory containing this README.txt file (and the FFmpeg build script and source code archive). This step is important. The build script will assume that you have done this and will not work otherwise.

3 - Run "./build-ffmpeg.sh" and wait till it is finished executing.

4 - The newly built FFmpeg shared libraries will be in the subdirectory "sharedLibs". There should be 4 of them:

    1 - libavcodec.(version).dylib
    2 - libavformat.(version).dylib
    3 - libavutil.(version).dylib
    4 - libswresample.(version).dylib)
    
5 - (Optional) Using the lipo command, verify that the dylibs are indeed universal, supporting both x86_64 and arm64 architectures.

    Example command:    "lipo -info sharedLibs/libavcodec.58.dylib"
    Example output:     "Architectures in the fat file: sharedLibs/libavcodec.58.dylib are: x86_64 arm64"
    
6 - Copy the shared libraries into the "Frameworks" group in the Xcode project (replace existing files).
