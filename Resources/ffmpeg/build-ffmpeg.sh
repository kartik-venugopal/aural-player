#!/bin/sh

# Pre-requisites:
#
# nasm - assembler for x86 (Run "brew install nasm" ... requires Homebrew)
# clang - C compiler (Run "xcode-select --install")

export binDir=".."  # Binaries will be placed one level above the source folder (i.e. in the same location as this script)
export sourceArchiveName="ffmpeg-sourceCode.bz2"
export sourceDirectoryName="ffmpeg-4.1"

# Extract source code from archive
echo "\nExtracting FFmpeg sources from archive ..."
tar xjf $sourceArchiveName
echo "Done extracting FFmpeg sources from archive.\n"

# Configure FFmpeg
cd $sourceDirectoryName
echo "Configuring FFmpeg ..."

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
--enable-audiotoolbox \
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
--disable-filters \
--enable-filter=aresample \
--disable-demuxers \
--enable-demuxer=ape,asf,dsf,flac,matroska,mjpeg,mjpeg_2000,mpjpeg,mp3,mpc,mpc8,ogg,wv \
--disable-decoders \
--enable-decoder=ape,flac,jpeg2000,jpegls,mjpeg,mjpegb,mp2,mp2_at,mp2float,mpc7,mpc8,dsd_lsbf,dsd_lsbf_planar,dsd_msbf,dsd_msbf_planar,opus,vorbis,wavpack,wmav1,wmav2 \
--disable-parsers \
--enable-parser=bmp,flac,mjpeg,mpegaudio,opus,png,vorbis \
--disable-muxers \
--enable-muxer=aiff,ipod,image2,image2pipe \
--disable-encoders \
--enable-encoder=aac,aac_at,alac,pcm_s16be,jpeg2000,jpegls

echo "Done configuring FFmpeg.\n"

# Build FFmpeg
echo "Building FFmpeg ..."
make && make install
echo "Done building FFmpeg."

# Delete source directory
rm -rf ../$sourceDirectoryName
