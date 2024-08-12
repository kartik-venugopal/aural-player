#!/bin/sh

#  build-libcue.sh
#  Aural
#
#  Created by Kartik Venugopal on 13/08/24.
#  Copyright © 2024 Kartik Venugopal. All rights reserved.
#

export libVersion="2.3.0"

# The name of the source archive file.
export srcArchiveName="libcue-${libVersion}.zip"

export sharedLibName="libcue.${libVersion}.dylib"

# The name of the source directory (once the archive has been uncompressed).
export srcDirName="libcue-${libVersion}"

function runBuild {

    cleanXCFrameworkDir
    extractSources
    
    cd ${srcDirName}
    buildLibCue
    fixInstallName

    cd ../..
    copyHeaders
    createXCFramework
    cleanUp
}

function cleanXCFrameworkDir {

    if [ -d "libcue.xcframework" ]; then
        rm -rf libcue.xcframework
    fi
}

function extractSources {

    # Extract source code from archive.
    if [ ! -d ${srcDirName} ]; then
        tar xjf ${srcArchiveName}
    fi
}

function buildLibCue {

    mkdir bin
    cd bin
    
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON ../
    make
}

function fixInstallName {
    install_name_tool -id @rpath/${sharedLibName} ${sharedLibName}
}

function copyHeaders {

    mkdir "headers"
    cp ${srcDirName}/libcue.h headers
}

function createXCFramework {

    xcrun xcodebuild -create-xcframework \
        -library "${srcDirName}/bin/libcue.${libVersion}.dylib" -headers "headers" \
        -output "libcue.xcframework"
}

function cleanUp {

    if [ -d ${srcDirName} ]; then
        rm -rf ${srcDirName}
    fi
    
        if [ -d "headers" ]; then
        rm -rf "headers"
    fi
}

runBuild
