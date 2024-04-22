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
export platform="macOS"

# Architectures
export architectures=("x86_64" "arm64")

# Deployment target for Aural Player.
export deploymentTarget="11.0"

# Points to the latest MacOS SDK installed.
export sdk="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"

export createFatLibs="true"

# MARK: Functions -------------------------------------------------------------------------------------

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

function copyHeaders {

    mkdir "headers"
    
    srcBaseDir="src/${platform}/arm64"
    headersBaseDir="headers/${platform}"
    
    copyHeadersForLib $srcBaseDir $avcodecLibName $headersBaseDir "${avcodecHeaderNames[@]}"
    copyHeadersForLib $srcBaseDir $avformatLibName $headersBaseDir "${avformatHeaderNames[@]}"
    copyHeadersForLib $srcBaseDir $avutilLibName $headersBaseDir "${avutilHeaderNames[@]}"
    copyHeadersForLib $srcBaseDir $swresampleLibName $headersBaseDir "${swresampleHeaderNames[@]}"
}
