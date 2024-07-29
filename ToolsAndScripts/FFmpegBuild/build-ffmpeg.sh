#!/bin/sh

#  common.sh
#  Aural-macOS
#
#  Created by Kartik Venugopal on 22/09/22.
#  Copyright © 2024 Kartik Venugopal. All rights reserved.

# Common variables and functions used across the ffmpeg build scripts.

# MARK: Constants -------------------------------------------------------------------------------------

# Architectures
export architectures=("x86_64" "arm64")

# Deployment target for Aural Player.
export deploymentTarget="11.0"

# Points to the latest MacOS SDK installed.
export sdk="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"

# FFmpeg release version
export ffmpegVersion="7.0.1"

export avcodecLibName="libavcodec"
export avformatLibName="libavformat"
export avutilLibName="libavutil"
export swresampleLibName="libswresample"

# Library versions
export avcodecVersion=61
export avformatVersion=61
export avutilVersion=59
export swresampleVersion=5

# Aliases for the library files.
export avcodecLib="${avcodecLibName}.${avcodecVersion}.dylib"
export avformatLib="${avformatLibName}.${avformatVersion}.dylib"
export avutilLib="${avutilLibName}.${avutilVersion}.dylib"
export swresampleLib="${swresampleLibName}.${swresampleVersion}.dylib"

# Components to enable and build
export demuxersToEnable="ape,asf,asf_o,dsf,flac,iff,matroska,mpc,mpc8,ogg,rm,tak,tta,wv"
export parsersToEnable="bmp,cook,flac,gif,jpeg2000,mjpeg,mpegaudio,opus,png,sipr,tak,vorbis,webp"
export decodersToEnable="ape,cook,dsd_lsbf,dsd_lsbf_planar,dsd_msbf,dsd_msbf_planar,flac,mpc7,mpc8,musepack7,musepack8,opus,ra_144,ra_288,ralf,sipr,tta,tak,vorbis,wavpack,wmav1,wmav2,wmalossless,wmapro,wmavoice"

# Names of public headers to include in XCFrameworks
export avcodecHeaderNames=("ac3_parser.h" "adts_parser.h" "avcodec.h" "avdct.h" "avfft.h" "bsf.h" "codec.h" "codec_desc.h" "codec_id.h" "codec_par.h" "d3d11va.h" "defs.h" "dirac.h" "dv_profile.h" "dxva2.h" "jni.h" "mediacodec.h" "packet.h" "qsv.h" "vdpau.h" "version.h" "version_major.h" "videotoolbox.h" "vorbis_parser.h")

export avformatHeaderNames=("avformat.h" "avio.h" "version.h" "version_major.h")

export avutilHeaderNames=("adler32.h" "aes.h" "aes_ctr.h" "attributes.h" "audio_fifo.h" "avassert.h" "avconfig.h" "avstring.h" "avutil.h" "base64.h" "blowfish.h" "bprint.h" "bswap.h" "buffer.h" "camellia.h" "cast5.h" "channel_layout.h" "common.h" "cpu.h" "crc.h" "des.h" "dict.h" "display.h" "dovi_meta.h" "downmix_info.h" "encryption_info.h" "error.h" "eval.h" "fifo.h" "file.h" "film_grain_params.h" "frame.h" "hash.h" "hdr_dynamic_metadata.h" "hmac.h" "hwcontext.h" "hwcontext_cuda.h" "hwcontext_d3d11va.h" "hwcontext_drm.h" "hwcontext_dxva2.h" "hwcontext_mediacodec.h" "hwcontext_opencl.h" "hwcontext_qsv.h" "hwcontext_vaapi.h" "hwcontext_vdpau.h" "hwcontext_videotoolbox.h" "hwcontext_vulkan.h" "imgutils.h" "intfloat.h" "intreadwrite.h" "lfg.h" "log.h" "lzo.h" "macros.h" "mastering_display_metadata.h" "mathematics.h" "md5.h" "mem.h" "motion_vector.h" "murmur3.h" "opt.h" "parseutils.h" "pixdesc.h" "pixelutils.h" "pixfmt.h" "random_seed.h" "rational.h" "rc4.h" "replaygain.h" "ripemd.h" "samplefmt.h" "sha.h" "sha512.h" "spherical.h" "stereo3d.h" "tea.h" "threadmessage.h" "time.h" "timecode.h" "timestamp.h" "tree.h" "twofish.h" "tx.h" "version.h" "version_major.h" "video_enc_params.h" "xtea.h")

export swresampleHeaderNames=("swresample.h" "version.h" "version_major.h")

# The name of the FFmpeg source archive file.
export srcArchiveName="ffmpeg-${ffmpegVersion}.tar.xz"

# The name of the FFmpeg source directory (once the archive has been uncompressed).
export srcDirName="ffmpeg-${ffmpegVersion}"

# MARK: Functions -------------------------------------------------------------------------------------

function runBuild {

    cleanXCFrameworksDir
    buildFFmpeg
    createFatLibs
    copyHeaders
}

function cleanXCFrameworksDir {

    if [ -d "xcframeworks" ]; then
        rm -rf xcframeworks
    fi
}

function extractSources {

    # Extract source code from archive.
    if [ ! -d ${srcDirName} ]; then
        tar xjf ${srcArchiveName}
    fi
}

function buildFFmpeg {

    extractSources
    
    # Run all builds in parallel and wait till they all finish.
    for arch in ${architectures[@]}; do
        buildFFmpegForArch $arch &
    done
    
    wait
}

function buildFFmpegForArch {

    arch=$1
    
    echo "\nBuilding FFmpeg for architecture '${arch}' ..."
    
    # Make a copy of the source code.
    srcBaseDir="src/${arch}"
    mkdir -p ${srcBaseDir}
    cp -r $srcDirName/* $srcBaseDir
    
    configureFFmpeg $arch $srcBaseDir
    makeFFmpeg

    copyLibs $arch
    fixInstallNames $arch
}

# Determine compiler / linker flags based on architecture.
function setCompilerAndLinkerFlags {

    arch=$1
    
    export compiler="/usr/bin/clang"
    
    # Architecture of the host machine running this build.
    hostArchitecture=$(uname -m)
    
    if [[ "$arch" != "$hostArchitecture" ]]
    then
        archInFlags="-arch ${arch} "
        export crossCompileOption="--enable-cross-compile"
        export archOption="--arch=${arch}"
    fi
    
    export extraCompilerFlags="${archInFlags}-mmacosx-version-min=${deploymentTarget} -isysroot ${sdk}"
    export extraLinkerFlags=${extraCompilerFlags}
}

function configureFFmpeg {

    arch=$1
    srcDir=$2
    
    # CD to the source directory.
    cd ${srcDir}
    
    setCompilerAndLinkerFlags $arch
    
    # Configure FFmpeg
    ./configure \
    --target-os=darwin \
    ${archOption} \
    --cc="${compiler}" \
    --as="${assembler}" \
    --extra-cflags="${extraCompilerFlags}" \
    --extra-ldflags="${extraLinkerFlags}" \
    ${crossCompileOption} \
    --enable-gpl \
    --enable-version3 \
    --enable-shared \
    --disable-static \
    --enable-runtime-cpudetect \
    --enable-hardcoded-tables \
    --enable-pthreads \
    --disable-doc \
    --disable-debug \
    --disable-network \
    --disable-all \
    --enable-avcodec \
    --enable-avformat \
    --enable-swresample \
    --disable-avfoundation \
    --disable-audiotoolbox \
    --disable-coreimage \
    --disable-zlib \
    --disable-everything \
    --disable-appkit \
    --disable-iconv \
    --disable-bzlib \
    --disable-sdl2 \
    --disable-videotoolbox \
    --disable-securetransport \
    --enable-demuxer=$demuxersToEnable \
    --enable-parser=$parsersToEnable \
    --enable-decoder=$decodersToEnable \
    --enable-protocol=file
}

function makeFFmpeg {

    # Build FFmpeg (use multithreading).
    tokens=$(sysctl hw.physicalcpu)
    numCores="$(cut -d' ' -f2 <<<$tokens)"
    make -j${numCores}
    
    cd ../..
}

function copyLibs {

    arch=$1

    # Create the directory where the libs will be installed in.
    libsDir="dylibs/${arch}"
    mkdir -p $libsDir
    cd $libsDir
    
    srcDir="../../src/${arch}"
    
    cp ${srcDir}/${avcodecLibName}/${avcodecLib} .
    cp ${srcDir}/${avformatLibName}/${avformatLib} .
    cp ${srcDir}/${avutilLibName}/${avutilLib} .
    cp ${srcDir}/${swresampleLibName}/${swresampleLib} .

    cd ../..
}

function fixInstallNames {

    arch=$1
    
    cd "dylibs/${arch}"

    install_name_tool -id @rpath/${avcodecLib} ${avcodecLib}
    install_name_tool -change /usr/local/lib/${swresampleLib} @rpath/${swresampleLib} ${avcodecLib}
    install_name_tool -change /usr/local/lib/${avutilLib} @rpath/${avutilLib} ${avcodecLib}

    install_name_tool -id @rpath/${avformatLib} ${avformatLib}
    install_name_tool -change /usr/local/lib/${avcodecLib} @rpath/${avcodecLib} ${avformatLib}
    install_name_tool -change /usr/local/lib/${swresampleLib} @rpath/${swresampleLib} ${avformatLib}
    install_name_tool -change /usr/local/lib/${avutilLib} @rpath/${avutilLib} ${avformatLib}

    install_name_tool -id @rpath/${avutilLib} ${avutilLib}

    install_name_tool -id @rpath/${swresampleLib} ${swresampleLib}
    install_name_tool -change /usr/local/lib/${avutilLib} @rpath/${avutilLib} ${swresampleLib}

    cd ../../..
}

function createFatLibs {

    # Combine x86_64 and arm64 dylibs into "fat" universal dylibs.
    cd dylibs
    
    allDylibs=($avcodecLib $avformatLib $avutilLib $swresampleLib)
    
    for lib in ${allDylibs[@]}; do
    
        nonFatLibFiles=""
    
        for arch in ${architectures[@]}; do
            nonFatLibFiles="${nonFatLibFiles} ${arch}/${lib}"
        done
        
        lipo ${nonFatLibFiles} -output ${lib} -create
        
    done
    
    cd ..
}

function copyHeaders {

    mkdir "headers"
    
    srcBaseDir="src/arm64"
    headersBaseDir="headers"
    
    copyHeadersForLib $srcBaseDir $avcodecLibName $headersBaseDir "${avcodecHeaderNames[@]}"
    copyHeadersForLib $srcBaseDir $avformatLibName $headersBaseDir "${avformatHeaderNames[@]}"
    copyHeadersForLib $srcBaseDir $avutilLibName $headersBaseDir "${avutilHeaderNames[@]}"
    copyHeadersForLib $srcBaseDir $swresampleLibName $headersBaseDir "${swresampleHeaderNames[@]}"
}

function copyHeadersForLib {

    srcBaseDir=$1
    libName=$2
    headersBaseDir=$3
    shift
    shift
    shift
    headerNames=("$@")
    srcDir="${srcBaseDir}/${libName}"
    
    # Add a 2nd level folder with the same library name (otherwise headers are not resolved properly in the XCode project).
    # For example: "/libavcodec/libavcodec/someHeader.h"
    
    headersDestDir="${headersBaseDir}/${libName}/${libName}"
    mkdir -p $headersDestDir
    
    for file in ${headerNames[@]}; do
        cp "${srcDir}/${file}" "${headersDestDir}"
    done
}

function createXCFrameworks {

    mkdir "xcframeworks"

    createXCFrameworkForLib ${avcodecLibName} ${avcodecLib}
    createXCFrameworkForLib ${avformatLibName} ${avformatLib}
    createXCFrameworkForLib ${avutilLibName} ${avutilLib}
    createXCFrameworkForLib ${swresampleLibName} ${swresampleLib}
}

function createXCFrameworkForLib {

    libName=$1
    lib=$2
    
    xcrun xcodebuild -create-xcframework \
        -library "dylibs/${lib}" -headers "headers/${libName}" \
        -output "xcframeworks/${libName}.xcframework"
}

function cleanUp {

    rm -rf ${srcDirName}
    rm -rf src
    rm -rf dylibs
    rm -rf headers
}

runBuild
createXCFrameworks
cleanUp

echo "\nAll done !\n"
