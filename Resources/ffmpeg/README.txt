Instructions to build a standalone distributable FFmpeg binary from source. The binary will be licensed under GPL v3 and free to distribute, as long as the source code used to build it is also made available with the binary.

1 - Open a terminal window
2 - cd to the directory containing this README.txt file (and the FFmpeg build script and source code archive). This step is important. The build script will assume that you have done this and will not work otherwise.
3 - Run "./build-ffmpeg.sh" and wait till it is finished executing
4 - The newly built FFmpeg binaries "ffmpeg" and "ffprobe" will be in this directory
5 - Run "./ffmpeg -formats" to see which file formats this build of ffmpeg can read/write
