#!/bin/sh

#
#  build-release.sh
#  Aural
#
#  Copyright © 2021 Kartik Venugopal. All rights reserved.
#
#  This software is licensed under the MIT software license.
#  See the file "LICENSE" in the project root directory for license terms.
#

#
# Builds an Aural Player app bundle and optionally packages it in a compressed read-only DMG disk image suitable
# for distribution as a product release.
#
# This script accepts 1 optional argument that will determine whether to build an app bundle (.app)
# or a DMG disk image (.dmg). If no argument is specified, a DMG image will be built.
#
# Usage:
#
# ./buildReleasePackage.sh          (No argument specified, will build DMG)
# ./buildReleasePackage.sh app      (Will build app bundle)
# ./buildReleasePackage.sh dmg      (Will build DMG)
#
# NOTE - Building the DMG image requires a tool called "create-dmg". This tool must be installed on the system.
# It can be installed by running "brew install create-dmg". For more info, see:
# https://github.com/create-dmg/create-dmg.
#

# Directory containing the Aural Player Xcode project.
export projectDir="../../.."

echo "Reading build version from Aural Player project ..."

# Get release version from the project.
export releaseVersion=$(xcodebuild -project $projectDir/Aural.xcodeproj -showBuildSettings | grep MARKETING_VERSION | cut -d'=' -f2 | tr -d ' ')

# Destination directory where the app bundle / DMG image will be stored.
export releaseDir="./Aural Player ${releaseVersion}"

# File names.
export archive="${releaseDir}/Aural.xcarchive"
export bundle="${releaseDir}/Aural.app"
export installer="./AuralPlayer-${releaseVersion}.dmg"
export releaseNotesFile="${projectDir}/Documentation/Release Notes.md"
export licenseFile="${projectDir}/LICENSE"

function buildAppBundle {

    echo "Building Aural Player ${releaseVersion} app bundle ..."

    if [ -d "${bundle}" ]; then
        rm -rf "${bundle}"
    else
        mkdir -p "${releaseDir}"
    fi

    # Build an Xcode archive.
    xcodebuild -project $projectDir/Aural.xcodeproj -config Release -scheme Aural -archivePath "${archive}" archive
    
    # Export the app bundle from the archive.
    xcodebuild -archivePath "${archive}" -exportArchive -exportPath "${releaseDir}" -exportOptionsPlist exportOptions.plist
    
    # Remove the archive (no longer required).
    rm -rf "${archive}"
}

function buildDMG {

    echo "Building Aural Player ${releaseVersion} DMG image ..."

    # The app bundle needs to be built first.
    buildAppBundle

    # Remove any old installer, if present.
    if [ -f "${installer}" ]; then
        rm "${installer}"
    fi

    # Invoke the "create-dmg" tool.
    create-dmg \
      --volname "Aural Player ${releaseVersion}" \
      --volicon "assets/appIcon.icns" \
      --background "assets/dmg-background.png" \
      --window-pos 200 120 \
      --window-size 800 450 \
      --icon-size 70 \
      --icon "Aural.app" 230 150 \
      --hide-extension "Aural.app" \
      --app-drop-link 590 150 \
      --add-file "Release Notes.md" "${releaseNotesFile}" 470 270 \
      --add-file "LICENSE.txt" "${licenseFile}" 320 270 \
      "${installer}" \
      "${releaseDir}"
      
    # Remove the app bundle (no longer required).
    rm -rf "${releaseDir}"
}

# Determine build type based on program argument.
if [[ $1 == "app" ]]
then
    buildAppBundle
elif [[ $1 == "dmg" || $1 == "" ]]
then
    buildDMG
else
    echo "Invalid argument supplied: '$1'. Valid argument values include 'app', 'dmg', or no value."
    exit 1
fi

echo "Done"
