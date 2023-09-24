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

mkdir -p "dylibs"

libopenmpt/build-libopenmpt.sh
export PKG_CONFIG_PATH="$(pwd)/libopenmpt/installDir/lib/pkgconfig"
./build-ffmpeg.sh

cd dylibs
mkdir arm64
mv *.dylib arm64
mkdir x86_64
cd ..

rm -rf libopenmpt/installDir

echo "\nAll done !\n"
