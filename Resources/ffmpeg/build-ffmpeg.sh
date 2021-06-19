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
export srcArchiveName="ffmpeg-${ffmpegVersion}.tar.bz2"

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
    srcBaseDir="src-${arch}"
    mkdir ${srcBaseDir}
    tar xjf ${srcArchiveName} -C ${srcBaseDir}
    
    configureAndMake $arch
    copyLibs $arch
    fixInstallNames $arch
    
    # Delete source directory
    rm -rf ${srcBaseDir}
}

function configureAndMake {

    arch=$1
    
    # CD to the source directory.
    cd "src-${arch}/${srcDirName}"
    
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
    --enable-hardcoded-tables \
    --enable-pthreads \
    --disable-doc \
    --disable-debug \
    --disable-all \
    --enable-avcodec \
    --enable-avformat \
    --enable-swresample \
    --enable-avfoundation \
    --enable-audiotoolbox \
    --enable-coreimage \
    --enable-zlib \
    --disable-everything \
    --disable-appkit \
    --disable-iconv \
    --disable-bzlib \
    --disable-sdl2 \
    --disable-videotoolbox \
    --disable-securetransport \
    --enable-demuxer=ape,asf,asf_o,dsf,flac,iff,matroska,mpc,mpc8,ogg,rm,tak,tta,wv \
    --enable-parser=bmp,cook,flac,gif,jpeg2000,mjpeg,mpegaudio,opus,png,sipr,tak,vorbis,webp \
    --enable-protocol=file \
    --enable-decoder=ape,cook,dsd_lsbf,dsd_lsbf_planar,dsd_msbf,dsd_msbf_planar,flac,mpc7,mpc8,musepack7,musepack8,opus,ra_144,ra_288,ralf,sipr,tta,tak,vorbis,wavpack,wmav1,wmav2,wmalossless,wmapro,wmavoice
    
    # Build FFmpeg (use multithreading).
    tokens=$(sysctl hw.physicalcpu)
    numCores="$(cut -d' ' -f2 <<<$tokens)"
    make -j${numCores}
    
    cd ../..
}

function copyLibs {

    arch=$1

    # Create the directory where the libs will be installed in.
    mkdir -p "sharedLibs/${arch}"
    cd "sharedLibs/${arch}"
    
    srcDir="../../src-${arch}/${srcDirName}"

    cp ${srcDir}/libavcodec/${avcodecLib} .
    cp ${srcDir}/libavformat/${avformatLib} .
    cp ${srcDir}/libavutil/${avutilLib} .
    cp ${srcDir}/libswresample/${swresampleLib} .

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

function cleanSharedLibsDir {

    if [ -d "sharedLibs" ]; then
        rm sharedLibs/*
    fi
}

cleanSharedLibsDir

buildFFmpeg "x86_64" &
buildFFmpeg "arm64" &
wait

createFatLibs
deleteNonFatLibs

echo "\nAll done !\n"
