#!/bin/sh

#
#  build-ffmpeg.sh
#  Aural
#
#  Copyright © 2022 Kartik Venugopal. All rights reserved.
#
#  This software is licensed under the MIT software license.
#  See the file "LICENSE" in the project root directory for license terms.
#

#
# This script builds XCFrameworks that wrap FFmpeg shared libraries (.dylib) and their
# corresponding public headers. These frameworks are suitable for use by Aural Player but not for general
# purpose FFmpeg use.
#
# Please see "README.txt" (in the same directory as this script) for detailed instructions and notes
# related to the use of this script.
#

# MARK: Constants -------------------------------------------------------------------------------------

# FFmpeg release version
export ffmpegVersion="4.4"

# Architectures
export architectures=("x86_64" "arm64")

# Library versions
export avcodecVersion=58
export avformatVersion=58
export avutilVersion=56
export swresampleVersion=3

export avcodecLibName="libavcodec"
export avformatLibName="libavformat"
export avutilLibName="libavutil"
export swresampleLibName="libswresample"

export libNames=($avcodecLibName $avformatLibName $avutilLibName $swresampleLibName)

export avcodecHeaderNames=("ac3_parser.h" "adts_parser.h" "avcodec.h" "avdct.h" "avfft.h" "bsf.h" "codec.h" "codec_desc.h" "codec_id.h" "codec_par.h" "d3d11va.h" "dirac.h" "dv_profile.h" "dxva2.h" "jni.h" "mediacodec.h" "packet.h" "qsv.h" "vaapi.h" "vdpau.h" "version.h" "videotoolbox.h" "vorbis_parser.h" "xvmc.h")

export avformatHeaderNames=("avformat.h" "avio.h" "version.h")

export avutilHeaderNames=("adler32.h" "aes.h" "aes_ctr.h" "attributes.h" "audio_fifo.h" "avassert.h" "avconfig.h" "avstring.h" "avutil.h" "base64.h" "blowfish.h" "bprint.h" "bswap.h" "buffer.h" "camellia.h" "cast5.h" "channel_layout.h" "common.h" "cpu.h" "crc.h" "des.h" "dict.h" "display.h" "dovi_meta.h" "downmix_info.h" "encryption_info.h" "error.h" "eval.h" "fifo.h" "file.h" "film_grain_params.h" "frame.h" "hash.h" "hdr_dynamic_metadata.h" "hmac.h" "hwcontext.h" "hwcontext_cuda.h" "hwcontext_d3d11va.h" "hwcontext_drm.h" "hwcontext_dxva2.h" "hwcontext_mediacodec.h" "hwcontext_opencl.h" "hwcontext_qsv.h" "hwcontext_vaapi.h" "hwcontext_vdpau.h" "hwcontext_videotoolbox.h" "hwcontext_vulkan.h" "imgutils.h" "intfloat.h" "intreadwrite.h" "lfg.h" "log.h" "lzo.h" "macros.h" "mastering_display_metadata.h" "mathematics.h" "md5.h" "mem.h" "motion_vector.h" "murmur3.h" "opt.h" "parseutils.h" "pixdesc.h" "pixelutils.h" "pixfmt.h" "random_seed.h" "rational.h" "rc4.h" "replaygain.h" "ripemd.h" "samplefmt.h" "sha.h" "sha512.h" "spherical.h" "stereo3d.h" "tea.h" "threadmessage.h" "time.h" "timecode.h" "timestamp.h" "tree.h" "twofish.h" "tx.h" "version.h" "video_enc_params.h" "xtea.h")

export swresampleHeaderNames=("swresample.h" "version.h")

# Aliases for the library files.
export avcodecLib="${avcodecLibName}.${avcodecVersion}.dylib"
export avformatLib="${avformatLibName}.${avformatVersion}.dylib"
export avutilLib="${avutilLibName}.${avutilVersion}.dylib"
export swresampleLib="${swresampleLibName}.${swresampleVersion}.dylib"

# The name of the FFmpeg source archive file.
export srcArchiveName="ffmpeg-${ffmpegVersion}.tar.bz2"

# The name of the FFmpeg source directory (once the archive has been uncompressed).
export srcDirName="ffmpeg-${ffmpegVersion}"

# Deployment target for Aural Player.
export minMacOSVersion="10.12"

# Points to the latest MacOS SDK installed.
export sdk="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"

# arm64
export PKG_CONFIG_PATH="/opt/homebrew/Cellar/libopenmpt/0.7.3/lib/pkgconfig"

# x86_64
#export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"

# MARK: Functions -------------------------------------------------------------------------------------

function cleanXCFrameworksDir {

    if [ -d "xcframeworks" ]; then
        rm -rf xcframeworks
    fi
}

function buildFFmpeg {

    for arch in ${architectures[@]}; do
        buildFFmpegForArch $arch &
    done

    wait
    
#    buildFFmpegForArch arm64
}

function buildFFmpegForArch {

    arch=$1
    echo "\nBuilding FFmpeg for architecture '${arch}' ..."
    
    # Extract source code from archive
    srcBaseDir="src-${arch}"
    mkdir ${srcBaseDir}
    tar xjf ${srcArchiveName} -C ${srcBaseDir}
    
    configureAndMake $arch
    copyLibs $arch
    fixInstallNames $arch
}

function configureAndMake {

    arch=$1
    
    # CD to the source directory.
    cd "src-${arch}/${srcDirName}"
    
    hostArch=$(uname -a | awk 'NF>1{print $NF}')
    
    # Determine compiler / linker flags based on architecture.
    if [[ "$arch" == "$hostArch" ]]
    then
    
        archInFlags=""
        crossCompileAndArch=""
        
    else
    
        archInFlags="-arch $arch "
        crossCompileAndArch="--enable-cross-compile --arch=$arch"
        
    fi
    
    # Configure FFmpeg
    ./configure \
    --cc=/usr/bin/clang \
    --extra-ldflags="${archInFlags}-mmacosx-version-min=${minMacOSVersion} -isysroot ${sdk}" \
    --extra-cflags="${archInFlags}-mmacosx-version-min=${minMacOSVersion} -isysroot ${sdk}" \
    ${crossCompileAndArch} \
    --extra-libs=-lpthread \
    --pkg-config-flags="--static" \
    --pkg-config="pkg-config --static" \
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
    --enable-libopenmpt \
    --enable-nonfree \
    --disable-everything \
    --disable-appkit \
    --disable-iconv \
    --disable-bzlib \
    --disable-sdl2 \
    --disable-videotoolbox \
    --disable-securetransport \
    --enable-demuxer=ape,asf,asf_o,dsf,flac,iff,matroska,mpc,mpc8,ogg,rm,tak,tta,wv,libopenmpt \
    --enable-parser=bmp,cook,flac,gif,jpeg2000,mjpeg,mpegaudio,opus,png,sipr,tak,vorbis,webp,xma \
    --enable-decoder=ape,cook,dsd_lsbf,dsd_lsbf_planar,dsd_msbf,dsd_msbf_planar,flac,mpc7,mpc8,musepack7,musepack8,opus,ra_144,ra_288,ralf,sipr,tta,tak,vorbis,wavpack,wmav1,wmav2,wmalossless,wmapro,wmavoice,adpcm_4xm,adpcm_adx,adpcm_afc,adpcm_agm,adpcm_aica,adpcm_argo,adpcm_ct,adpcm_dtk,adpcm_ea,adpcm_ea_maxis_xa,adpcm_ea_r1,adpcm_ea_r2,adpcm_ea_r3,adpcm_ea_xas,adpcm_g722,adpcm_g726,adpcm_g726le,adpcm_ima_alp,adpcm_ima_amv,adpcm_ima_apc,adpcm_ima_apm,adpcm_ima_cunning,adpcm_ima_dat4,adpcm_ima_dk3,adpcm_ima_dk4,adpcm_ima_ea_eacs,adpcm_ima_ea_sead,adpcm_ima_iss,adpcm_ima_moflex,adpcm_ima_mtf,adpcm_ima_oki,adpcm_ima_qt,adpcm_ima_qt_at,adpcm_ima_rad,adpcm_ima_smjpeg,adpcm_ima_ssi,adpcm_ima_wav,adpcm_ima_ws,adpcm_ms,adpcm_mtaf,adpcm_psx,adpcm_sbpro_2,adpcm_sbpro_3,adpcm_sbpro_4,adpcm_swf,adpcm_thp,adpcm_thp_le,adpcm_vima,adpcm_xa,adpcm_yamaha,adpcm_zork,pcm_alaw,pcm_alaw_at,pcm_bluray,pcm_dvd,pcm_f16le,pcm_f24le,pcm_f32be,pcm_f32le,pcm_f64be,pcm_f64le,pcm_lxf,pcm_mulaw,pcm_mulaw_at,pcm_s16be,pcm_s16be_planar,pcm_s16le,pcm_s16le_planar,pcm_s24be,pcm_s24daud,pcm_s24le,pcm_s24le_planar,pcm_s32be,pcm_s32le,pcm_s32le_planar,pcm_s64be,pcm_s64le,pcm_s8,pcm_s8_planar,pcm_sga,pcm_u16be,pcm_u16le,pcm_u24be,pcm_u24le,pcm_u32be,pcm_u32le,pcm_u8,pcm_vidc \
    --enable-protocol=file
    
    # Build FFmpeg (use multithreading).
    tokens=$(sysctl hw.physicalcpu)
    numCores="$(cut -d' ' -f2 <<<$tokens)"
    make -j${numCores}

    cd ../..
}

function copyLibs {

    arch=$1

    # Create the directory where the libs will be installed in.
    mkdir -p "dylibs/${arch}"
    cd "dylibs/${arch}"
    
    srcDir="../../src-${arch}/${srcDirName}"
    
    cp ${srcDir}/${avcodecLibName}/${avcodecLib} .
    cp ${srcDir}/${avformatLibName}/${avformatLib} .
    cp ${srcDir}/${avutilLibName}/${avutilLib} .
    cp ${srcDir}/${swresampleLibName}/${swresampleLib} .

    cd ../..
}

function fixInstallNames {

    arch=$1
    
    cd "dylibs/${arch}"

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

    cd dylibs/x86_64
    for file in *; do
        lipo "${file}" "../arm64/${file}" -output "../${file}" -create
    done
    
    cd ../..
}

function copyHeaders {

    mkdir "headers"
    
    copyHeadersForLib $avcodecLibName "${avcodecHeaderNames[@]}"
    copyHeadersForLib $avformatLibName "${avformatHeaderNames[@]}"
    copyHeadersForLib $avutilLibName "${avutilHeaderNames[@]}"
    copyHeadersForLib $swresampleLibName "${swresampleHeaderNames[@]}"
}

function copyHeadersForLib {

    libName=$1
    shift
    headerNames=("$@")
    srcDir="src-arm64/${srcDirName}/${libName}"
    
    # Add a 2nd level folder with the same library name (otherwise headers are not resolved properly in the XCode project).
    # For example: "/libavcodec/libavcodec/someHeader.h"
    
    mkdir -p "headers/${libName}/${libName}"
    
    for file in ${headerNames[@]}; do
        cp "${srcDir}/${file}" "./headers/${libName}/${libName}"
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

function deleteSource {
    
    for arch in ${architectures[@]}; do
        rm -rf "src-${arch}"
    done
}

function deleteDylibs {
    rm -rf dylibs
}

function deleteHeaders {
    rm -rf headers
}

# MARK: Script -------------------------------------------------------------------------------------

cleanXCFrameworksDir
buildFFmpeg

createFatLibs
copyHeaders

createXCFrameworks

deleteSource
deleteDylibs
deleteHeaders

echo "\nAll done !\n"

