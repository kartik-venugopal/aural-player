#!/bin/sh

# The name of the FFmpeg source directory (once the archive has been uncompressed)
export sourceDirectoryName="ffmpeg-4.4"

# Deployment target for Aural Player.
export minMacOSVersion="10.12"

# Points to the latest MacOS SDK installed.
export sdk="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"

function buildFFmpeg {

    arch=$1
    echo "\nBuilding FFmpeg for architecture '${arch}' ...\n"
    
    # Extract source code from archive
    tar xjf ffmpeg-sourceCode.bz2
    
    configureAndMake $arch
    copyLibs $arch
    fixInstallNames $arch
    
    # Delete source directory
    rm -rf $sourceDirectoryName
}

function configureAndMake {

    arch=$1
    
    # CD to the source directory and configure FFmpeg
    cd $sourceDirectoryName
    
    if [[ "$arch" == "arm64" ]]
    then
        archInFlags="-arch arm64 "
        crossCompileAndArch="--enable-cross-compile --arch=arm64"
    else
        archInFlags=""
        crossCompileAndArch=""
    fi

    ./configure \
    --cc=/usr/bin/clang \
    --extra-ldexeflags="${archInFlags}-mmacosx-version-min=${minMacOSVersion} -isysroot ${sdk}" \
    --extra-ldflags="${archInFlags}-mmacosx-version-min=${minMacOSVersion} -isysroot ${sdk}" \
    --extra-cflags="${archInFlags}-mmacosx-version-min=${minMacOSVersion} -isysroot ${sdk}" \
    ${crossCompileAndArch} \
    --enable-gpl \
    --enable-version3 \
    --enable-shared \
    --disable-static \
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
    --disable-sdl2 \
    --disable-ffplay \
    --disable-ffmpeg \
    --disable-ffprobe \
    --disable-network \
    --disable-postproc \
    --disable-appkit \
    --enable-avfoundation \
    --enable-audiotoolbox \
    --disable-libspeex \
    --disable-libopencore_amrnb \
    --disable-libopencore_amrwb \
    --disable-coreimage \
    --disable-protocols \
    --disable-iconv \
    --enable-zlib \
    --disable-bzlib \
    --disable-lzma \
    --enable-protocol=file \
    --disable-indevs \
    --disable-outdevs \
    --disable-videotoolbox \
    --disable-securetransport \
    --disable-bsfs \
    --disable-filters \
    --disable-muxers \
    --enable-demuxers \
    --disable-hwaccels \
    --disable-nvenc \
    --disable-xvmc \
    --enable-parsers \
    --disable-encoders \
    --enable-decoders
    
    # Build FFmpeg
    make
    
    cd ..
}

function copyLibs {

    arch=$1

    # Create the directory where the libs will be installed in.
    mkdir -p "sharedLibs/${arch}"
    cd "sharedLibs/${arch}"

    cp ../../$sourceDirectoryName/libavcodec/libavcodec.58.dylib .
    cp ../../$sourceDirectoryName/libavformat/libavformat.58.dylib .
    cp ../../$sourceDirectoryName/libavutil/libavutil.56.dylib .
    cp ../../$sourceDirectoryName/libswresample/libswresample.3.dylib .

    cd ../..
}

function fixInstallNames {

    arch=$1
    
    cd "sharedLibs/${arch}"

    install_name_tool -id @loader_path/../Frameworks/libavcodec.58.dylib libavcodec.58.dylib
    install_name_tool -change /usr/local/lib/libswresample.3.dylib @loader_path/../Frameworks/libswresample.3.dylib libavcodec.58.dylib
    install_name_tool -change /usr/local/lib/libavutil.56.dylib @loader_path/../Frameworks/libavutil.56.dylib libavcodec.58.dylib

    install_name_tool -id @loader_path/../Frameworks/libavformat.58.dylib libavformat.58.dylib
    install_name_tool -change /usr/local/lib/libavcodec.58.dylib @loader_path/../Frameworks/libavcodec.58.dylib libavformat.58.dylib
    install_name_tool -change /usr/local/lib/libswresample.3.dylib @loader_path/../Frameworks/libswresample.3.dylib libavformat.58.dylib
    install_name_tool -change /usr/local/lib/libavutil.56.dylib @loader_path/../Frameworks/libavutil.56.dylib libavformat.58.dylib

    install_name_tool -id @loader_path/../Frameworks/libavutil.56.dylib libavutil.56.dylib

    install_name_tool -id @loader_path/../Frameworks/libswresample.3.dylib libswresample.3.dylib
    install_name_tool -change /usr/local/lib/libavutil.56.dylib @loader_path/../Frameworks/libavutil.56.dylib libswresample.3.dylib

    cd ../..
}

function createFatLibs {

    # Combine x86_64 and arm64 dylibs into "fat" universal dylibs.

    cd sharedLibs/x86_64
    for file in *; do
        lipo "${file}" "../arm64/${file}" -output "../${file}" -create
    done
    
    cd ../..
}

function deleteNonFatLibs {
    
    cd sharedLibs
    rm -rf x86_64
    rm -rf arm64
    
    cd ..
}

buildFFmpeg "x86_64"
buildFFmpeg "arm64"

createFatLibs
deleteNonFatLibs

echo "\nAll done !\n"
