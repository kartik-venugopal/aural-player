#!/bin/sh

# FFmpeg release version
export ffmpegVersion="4.4"

# Library versions
export avcodecVersion=58
export avformatVersion=58
export avutilVersion=56
export swresampleVersion=3

# Aliases for the library files.
export avcodecLib="libavcodec.${avcodecVersion}.dylib"
export avformatLib="libavformat.${avformatVersion}.dylib"
export avutilLib="libavutil.${avutilVersion}.dylib"
export swresampleLib="libswresample.${swresampleVersion}.dylib"

# The name of the FFmpeg source archive file.
export srcArchiveName="ffmpeg-sourceCode.bz2"

# The name of the FFmpeg source directory (once the archive has been uncompressed).
export srcDirName="ffmpeg-${ffmpegVersion}"

# Deployment target for Aural Player.
export minMacOSVersion="10.12"

# Points to the latest MacOS SDK installed.
export sdk="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"

function buildFFmpeg {

    arch=$1
    echo "\nBuilding FFmpeg for architecture '${arch}' ...\n"
    
    # Extract source code from archive
    tar xjf ${srcArchiveName}
    
    configureAndMake $arch
    copyLibs $arch
    fixInstallNames $arch
    
    # Delete source directory
    rm -rf $srcDirName
}

function configureAndMake {

    arch=$1
    
    # CD to the source directory.
    cd $srcDirName
    
    
    # Determine compiler / linker flags based on architecture.
    if [[ "$arch" == "arm64" ]]
    then
        archInFlags="-arch arm64 "
        crossCompileAndArch="--enable-cross-compile --arch=arm64"
    else
        archInFlags=""
        crossCompileAndArch=""
    fi
    
    # Configure FFmpeg
    ./configure \
    --cc=/usr/bin/clang \
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
    --disable-debug \
    --disable-swscale \
    --disable-avdevice \
    --disable-sdl2 \
    --disable-programs \
    --disable-network \
    --disable-postproc \
    --disable-appkit \
    --enable-avfoundation \
    --enable-audiotoolbox \
    --disable-libspeex \
    --disable-libopencore_amrnb \
    --disable-libopencore_amrwb \
    --disable-coreimage \
    --disable-iconv \
    --enable-zlib \
    --disable-bzlib \
    --disable-lzma \
    --disable-videotoolbox \
    --disable-securetransport \
    --disable-everything \
    --enable-demuxers \
    --enable-parsers \
    --enable-protocol=file \
    --enable-decoders
    
    # Build FFmpeg (use multithreading).
    tokens=$(sysctl hw.physicalcpu)
    numCores="$(cut -d' ' -f2 <<<$tokens)"
    make -j${numCores}
    
    cd ..
}

function copyLibs {

    arch=$1

    # Create the directory where the libs will be installed in.
    mkdir -p "sharedLibs/${arch}"
    cd "sharedLibs/${arch}"

    cp ../../${srcDirName}/libavcodec/${avcodecLib} .
    cp ../../${srcDirName}/libavformat/${avformatLib} .
    cp ../../${srcDirName}/libavutil/${avutilLib} .
    cp ../../${srcDirName}/libswresample/${swresampleLib} .

    cd ../..
}

function fixInstallNames {

    arch=$1
    
    cd "sharedLibs/${arch}"

    install_name_tool -id @loader_path/../Frameworks/${avcodecLib} ${avcodecLib}
    install_name_tool -change /usr/local/lib/${swresampleLib} @loader_path/../Frameworks/${swresampleLib} ${avcodecLib}
    install_name_tool -change /usr/local/lib/${avutilLib} @loader_path/../Frameworks/${avutilLib} ${avcodecLib}

    install_name_tool -id @loader_path/../Frameworks/${avformatLib} ${avformatLib}
    install_name_tool -change /usr/local/lib/${avcodecLib} @loader_path/../Frameworks/${avcodecLib} ${avformatLib}
    install_name_tool -change /usr/local/lib/${swresampleLib} @loader_path/../Frameworks/${swresampleLib} ${avformatLib}
    install_name_tool -change /usr/local/lib/${avutilLib} @loader_path/../Frameworks/${avutilLib} ${avformatLib}

    install_name_tool -id @loader_path/../Frameworks/${avutilLib} ${avutilLib}

    install_name_tool -id @loader_path/../Frameworks/${swresampleLib} ${swresampleLib}
    install_name_tool -change /usr/local/lib/${avutilLib} @loader_path/../Frameworks/${avutilLib} ${swresampleLib}

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
