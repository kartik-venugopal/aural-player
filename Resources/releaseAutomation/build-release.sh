#!/bin/sh

#
# Builds an Aural Player app bundle and packages it in a compressed read-only DMG disk image suitable
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

export releaseVersion="3.0.0"

# Directory containing the Aural Player Xcode project.
export projectDir="../.."

# Destination directory where the DMG installer will be stored.
export releaseDir="./Aural Player ${releaseVersion}"

# File names.
export archive="${releaseDir}/Aural.xcarchive"
export bundle="${releaseDir}/Aural.app"
export installer="./AuralPlayer-${releaseVersion}.dmg"
export releaseNotesFile="../../Documentation/Release Notes.md"

function buildAppBundle {

    echo "Building Aural Player ${releaseVersion} app bundle ..."

    if [ -d "${bundle}" ]; then
        rm -rf "${bundle}"
    else
        mkdir -p "${releaseDir}"
    fi

    xcodebuild -project $projectDir/Aural.xcodeproj -config Release -scheme Aural -archivePath "${archive}" archive
    xcodebuild -archivePath "${archive}" -exportArchive -exportPath "${releaseDir}" -exportOptionsPlist exportOptions.plist
    
    rm -rf "${archive}"
}

function buildDMG {

    echo "Building Aural Player ${releaseVersion} DMG installer ..."

    buildAppBundle

    if [ -f "${installer}" ]; then
        rm "${installer}"
    fi

    create-dmg \
      --volname "Aural Player ${releaseVersion}" \
      --volicon "assets/appIcon.icns" \
      --background "assets/dmg-background.png" \
      --window-pos 200 120 \
      --window-size 800 400 \
      --icon-size 90 \
      --icon "Aural.app" 200 175 \
      --hide-extension "Aural.app" \
      --app-drop-link 620 170 \
      --add-file "Release Notes.md" "${releaseNotesFile}" 390 270 \
      "${installer}" \
      "${releaseDir}"
      
    rm -rf "${releaseDir}"
}

# Determine compiler / linker flags based on architecture.
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
