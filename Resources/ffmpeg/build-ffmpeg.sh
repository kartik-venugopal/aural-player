#!/bin/sh

# Pre-requisites (need to be installed on this system to build FFmpeg) :
#
# nasm - assembler for x86 (Run "brew install nasm" ... requires Homebrew)
# clang - C compiler (Run "xcode-select --install")

# Binaries will be placed one level above the source folder (i.e. in the same location as this script)
echo "Starting Build-Script for FFMpeg Build ...\n"
echo "Setting local variables ...\n"
export binDir=".."

#echo "SourceArchivName = ffmpeg-sourceCode.bz2 \n"
## The name of the FFmpeg source code archive (which will be expanded)
#export sourceArchiveName="ffmpeg-sourceCode.bz2"

echo "SourceArchivName = ffmpeg-4.2.2.tar.bz2 \n"
# The name of the FFmpeg source code archive (which will be expanded)
export sourceArchiveName="ffmpeg-4.2.2.tar.bz2"

#echo "SourceDirectoryName = ffmpeg-4.1 \n"
## The name of the FFmpeg source directory (once the archive has been uncompressed)
#export sourceDirectoryName="ffmpeg-4.1"

echo "SourceDirectoryName = ffmpeg-4.2.2 \n"
# The name of the FFmpeg source directory (once the archive has been uncompressed)
export sourceDirectoryName="ffmpeg-4.2.2"

echo "Cleanup SourceDirectory from previous runs...\n"
# Delete source directory to clenaup previous incomplete runs...
rm -rf ../$sourceDirectoryName

# Extract source code from archive
echo "Extracting FFmpeg sources from archive ...\n"
tar xjf $sourceArchiveName
echo "Done extracting FFmpeg sources from archive.\n"

# CD to the source directory and configure FFmpeg
cd $sourceDirectoryName

echo "Configuring FFmpeg ... \n"

./configure \
--cc=/usr/bin/clang \
--pkg-config-flags="--static" \
--extra-ldexeflags="-Bstatic -mmacosx-version-min=10.12" \
--extra-ldflags="-Bstatic -mmacosx-version-min=10.12" \
--extra-cflags="-Bstatic -mmacosx-version-min=10.12" \
--bindir="$binDir" \
--enable-gpl \
--enable-version3 \
--enable-static \
--disable-shared \
--enable-runtime-cpudetect \
--enable-pthreads \
--disable-doc \
--disable-txtpages \
--disable-htmlpages \
--disable-manpages \
--disable-podpages \
--disable-debug \
--disable-swscale \
--disable-avdevice \
--disable-ffplay \
--enable-ffmpeg \
--disable-network \
--disable-postproc \
--disable-avfoundation \
--disable-appkit \
--disable-audiotoolbox \
--disable-coreimage \
--disable-protocols \
--disable-zlib \
--disable-bzlib \
--disable-lzma \
--enable-protocol=file \
--disable-indevs \
--disable-outdevs \
--disable-videotoolbox \
--disable-securetransport \
--disable-bsfs \
--enable-bsf=aac_adtstoasc \
--disable-filters \
--enable-filter=aresample \
--disable-demuxers \
--enable-demuxer=aac,ape,asf,dsf,flac,mp3,mpc,mpc8,wv,dts,dtshd \
--enable-demuxer=ogg,matroska \
--enable-demuxer=mjpeg,mjpeg_2000,mpjpeg \
--disable-decoders \
--enable-decoder=aac,ape,flac,mp1,mp1_at,mp1float,mp2,mp2_at,mp2float,mpc7,mpc8,dsd_lsbf,dsd_lsbf_planar,dsd_msbf,dsd_msbf_planar,opus,vorbis,wavpack,wmav1,wmav2,wmalossless,wmapro,wmavoice,dca \
--enable-decoder=bmp,png,jpeg2000,jpegls,mjpeg,mjpegb \
--disable-parsers \
--enable-parser=aac,flac,mpegaudio,opus,vorbis,dca,ac3 \
--enable-parser=bmp,mjpeg,png \
--disable-muxers \
--enable-muxer=aiff,ipod,ac3,caf,flac,wav,mp3 \
--enable-muxer=matroska_audio \
--enable-muxer=image2,image2pipe \
--disable-encoders \
--enable-encoder=aac,alac,ac3,pcm_s16be \
--enable-encoder=jpeg2000,jpegls

echo "Done configuring FFmpeg.\n"

# Build FFmpeg
echo "Building FFmpeg ... \n"
make && make install
echo "Done make and install FFmpeg.\n"

echo "Remove Source Directory ...\n"
# Delete source directory
rm -rf ../$sourceDirectoryName

echo "Done building FFmpeg and Cleanup.\n"
