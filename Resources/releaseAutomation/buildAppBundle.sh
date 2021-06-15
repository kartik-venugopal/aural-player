#!/bin/sh

export releaseVersion="2.13.0"

export baseDir=$HOME/Projects/xcode/Aural

export releasesDir="${HOME}/Projects/Aural-Releases/${releaseVersion}"
export releaseDir="${releasesDir}/Aural Player ${releaseVersion}"
export archive="${releaseDir}/Aural.xcarchive"

export installer="${releasesDir}/AuralPlayer-${releaseVersion}.dmg"
export releaseNotesFile="../../Documentation/Release Notes.md"

echo "Cleaning up old archive & app ..."

if [ -d "${releaseDir}" ]; then
    rm "${releaseDir}/*"
else
    mkdir "${releaseDir}"
fi

echo "Building archive ..."
xcodebuild -project $baseDir/Aural.xcodeproj -config Release -scheme Aural -archivePath "${archive}" archive

echo "Exporting archive ..."
xcodebuild -archivePath "${archive}" -exportArchive -exportPath "${releaseDir}" -exportOptionsPlist exportOptions.plist

echo "Cleaning up archive ..."
rm -rf "${archive}"

echo "Building installer ..."

if [ -f "${installer}" ]; then
    rm "${installer}"
fi

create-dmg \
  --volname "Aural Player ${releaseVersion}" \
  --volicon "./appIcon.icns" \
  --background "./dmg-background.png" \
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

echo "Done"
