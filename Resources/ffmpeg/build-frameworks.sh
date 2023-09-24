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

# Library versions
export avcodecVersion=58
export avformatVersion=58
export avutilVersion=56
export swresampleVersion=3

export avcodecLibName="libavcodec"
export avformatLibName="libavformat"
export avutilLibName="libavutil"
export swresampleLibName="libswresample"

# Aliases for the library files.
export avcodecLib="${avcodecLibName}.${avcodecVersion}.dylib"
export avformatLib="${avformatLibName}.${avformatVersion}.dylib"
export avutilLib="${avutilLibName}.${avutilVersion}.dylib"
export swresampleLib="${swresampleLibName}.${swresampleVersion}.dylib"

function createFatLibs {

    # Combine x86_64 and arm64 dylibs into "fat" universal dylibs.

    cd dylibs/x86_64
    for file in *; do
        lipo "${file}" "../arm64/${file}" -output "../${file}" -create
    done
    
    cd ../..
}

function cleanFrameworksDir {

    if [ -d "Frameworks" ]; then
        rm -rf Frameworks
    fi
}

function createFrameworks {

    mkdir "Frameworks"

    createXCFrameworkForLib ${avcodecLibName} ${avcodecLib}
    createXCFrameworkForLib ${avformatLibName} ${avformatLib}
    createXCFrameworkForLib ${avutilLibName} ${avutilLib}
    createXCFrameworkForLib ${swresampleLibName} ${swresampleLib}
    
    cp dylibs/libopenmpt.0.dylib Frameworks
}

function createXCFrameworkForLib {

    libName=$1
    lib=$2
    
    xcrun xcodebuild -create-xcframework \
        -library "dylibs/${lib}" -headers "headers/${libName}" \
        -output "Frameworks/${libName}.xcframework"
}

function deleteDylibs {
    rm -rf dylibs
}

function deleteHeaders {
    rm -rf headers
}

cleanFrameworksDir

createFatLibs
install_name_tool -change $(pwd)/libopenmpt/installDir/lib/libopenmpt.0.dylib @loader_path/../Frameworks/libopenmpt.0.dylib dylibs/${avformatLib}
createFrameworks

deleteDylibs
deleteHeaders

echo "\nAll done !\n"
