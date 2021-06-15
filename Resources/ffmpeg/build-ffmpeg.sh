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
    --enable-demuxer=aac,ac3,aiff,amr,amrnb,amrwb,ape,asf,asf_o,caf,dsf,dts,dtshd,eac3,flac,iff,matroska,mp3,mpc,mpc8,ogg,rm,tak,tta,wav,wv \
    --enable-parsers \
    --disable-parser=adx,av1,avs2,avs3,cavsvideo,cri,dirac,dnxhd,dolby_e,dpx,dvaudio,dvbsub,dvd_nav,dvdsub,g723_1,g729,gsm,h261,h263,h264,hevc,ipu,mlp,mpeg4video,mpegvideo,pnm,rv30,rv40,sbc,vc1,vp3,vp8,vp9,xma \
    --enable-protocol=file \
    --enable-decoder=aac,aac_at,aac_fixed,aac_latm,ac3,ac3_at,ac3_fixed,acelp.kelvin,alac,alac_at,amr_nb,amr_nb_at,amr_wb,amrnb,amrwb,ape,cook,dca,dsd_lsbf,dsd_lsbf_planar,dsd_msbf,dsd_msbf_planar,eac3,eac3_at,flac,mp1,mp1_at,mp1float,mp2,mp2_at,mp2float,mp3,mp3_at,mp3adu,mp3adufloat,mp3float,mp3on4,mp3on4float,mp4als,mpc7,mpc8,musepack7,musepack8,opus,pcm_dvd,pcm_f16le,pcm_f24le,pcm_f32be,pcm_f32le,pcm_f64be,pcm_f64le,pcm_lxf,pcm_mulaw,pcm_mulaw_at,pcm_s16be,pcm_s16be_planar,pcm_s16le,pcm_s16le_planar,pcm_s24be,pcm_s24daud,pcm_s24le,pcm_s24le_planar,pcm_s32be,pcm_s32le,pcm_s32le_planar,pcm_s64be,pcm_s64le,pcm_s8,pcm_s8_planar,pcm_sga,pcm_u16be,pcm_u16le,pcm_u24be,pcm_u24le,pcm_u32be,pcm_u32le,pcm_u8,pcm_vidc,ra_144,ra_288,ralf,sipr,tta,tak,vorbis,wavpack,wmav1,wmav2,wmalossless,wmapro,wmavoice
    
    # Build FFmpeg (use multithreading).
    tokens=$(sysctl hw.logicalcpu)
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

function cleanSharedLibsDir {

    if [ -d "sharedLibs" ]; then
        rm sharedLibs/*
    fi
}

cleanSharedLibsDir

buildFFmpeg "x86_64"
buildFFmpeg "arm64"

createFatLibs
deleteNonFatLibs

echo "\nAll done !\n"
