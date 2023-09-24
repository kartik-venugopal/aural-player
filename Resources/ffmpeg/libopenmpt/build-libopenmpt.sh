export libName="libopenmpt"

export srcArchivePrefix="libopenmpt-0.7.3+release.autotools"
export srcArchiveName="${srcArchivePrefix}.tar.gz"
export srcBaseDir="src"

# Deployment target for Aural Player.
export minMacOSVersion="10.12"

# Points to the latest MacOS SDK installed.
export sdk="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"

function extractSource {

    mkdir ${srcBaseDir}
    tar xjf ${srcArchiveName} -C ${srcBaseDir}
}

function configureAndMake {

    prefixDir=$1

    cd ${srcBaseDir}/${srcArchivePrefix}

    ./configure \
    LDFLAGS="-mmacosx-version-min=${minMacOSVersion} -isysroot ${sdk}" \
    CFLAGS="-mmacosx-version-min=${minMacOSVersion} -isysroot ${sdk}" \
    --enable-shared --disable-static \
    --without-mpg123 --without-ogg --without-vorbis --without-vorbisfile --without-portaudio --without-portaudiocpp --without-sndfile --without-flac --disable-openmpt123 --disable-examples --disable-tests --disable-doxygen-doc \
    --prefix=$prefixDir/installDir
    
    make install
    
    cd ../..
}

function fixInstallNames {

    cd "installDir/lib"

    install_name_tool -id @loader_path/../Frameworks/libopenmpt.0.dylib libopenmpt.0.dylib

    cd ../..
}

function copyLib {
    
    cp installDir/lib/libopenmpt.0.dylib ../dylibs
}

function cleanUp {

    rm -rf ${srcBaseDir}
}

cd libopenmpt
extractSource
configureAndMake $(pwd)
fixInstallNames
copyLib
cleanUp
