#!/bin/sh

#
#  build-ffmpeg.sh
#  Aural
#
#  Copyright © 2024 Kartik Venugopal. All rights reserved.
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

source ./common.sh

# MARK: Constants -------------------------------------------------------------------------------------

# Target platform
export platform="iOS"

# Architectures
export architectures=("x86_64" "arm64")

export crossCompileOption="--enable-cross-compile"

# Deployment target for Aural Player.
export deploymentTarget="15.0"

export createFatLibs="false"

# MARK: Functions -------------------------------------------------------------------------------------

# Determine compiler / linker flags based on architecture.
function setCompilerAndLinkerFlags {

    arch=$1
    
    export archOption="--arch=${arch}"
    archFlag="-arch $arch"
    
    if [ "$arch" = "x86_64" ]
    
    then
        iOSPlatform="iPhoneSimulator"
        export extraCompilerFlags="$archFlag -mios-simulator-version-min=$deploymentTarget"
    else
        iOSPlatform="iPhoneOS"
        export extraCompilerFlags="$archFlag -mios-version-min=$deploymentTarget -fembed-bitcode"
        if [ "$arch" = "arm64" ]
        then
            EXPORT="GASPP_FIX_XCODE5=1"
        fi
    fi
    
    export extraLinkerFlags=${extraCompilerFlags}

    xcRunSDK=`echo $iOSPlatform | tr '[:upper:]' '[:lower:]'`
    export compiler="xcrun -sdk $xcRunSDK clang"

    # force "configure" to use "gas-preprocessor.pl" (FFmpeg 3.3)
    if [ "$arch" = "arm64" ]
    then
        export assembler="gas-preprocessor.pl -arch aarch64 -- $compiler"
    else
        export assembler="gas-preprocessor.pl -- $compiler"
    fi
}

function copyHeaders {

    mkdir "headers"
    
    for arch in ${architectures[@]}; do
        
        srcBaseDir="src/${platform}/${arch}"
        headersBaseDir="headers/${platform}/${arch}"
        
        copyHeadersForLib $srcBaseDir $avcodecLibName $headersBaseDir "${avcodecHeaderNames[@]}"
        copyHeadersForLib $srcBaseDir $avformatLibName $headersBaseDir "${avformatHeaderNames[@]}"
        copyHeadersForLib $srcBaseDir $avutilLibName $headersBaseDir "${avutilHeaderNames[@]}"
        copyHeadersForLib $srcBaseDir $swresampleLibName $headersBaseDir "${swresampleHeaderNames[@]}"
    done
}
