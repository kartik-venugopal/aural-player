/*
    Reads track info from the filesystem
 */

import Cocoa
import AVFoundation

class TrackIO {
    
    private static var fileReader: FileReader = FileReader()
    
    // Load display metadata (artist/title/art and all grouping info)
    static func loadPrimaryInfo(_ track: Track) throws {

        let fileMetadata = FileMetadata()
        fileMetadata.primary = try fileReader.getPrimaryMetadata(for: track.file)
        
        track.setPrimaryMetadata(from: fileMetadata)
    }
//
//    static func loadSecondaryInfo(_ track: Track) {
//
//        MetadataUtils.loadSecondaryMetadata(track)
//        track.lazyLoadingInfo.secondaryInfoLoaded = true
//    }
//
//    static func loadArt(_ track: Track) {
//
//        // Load art (asynchronously)
//        if !track.lazyLoadingInfo.artLoaded {
//
//            DispatchQueue.global(qos: .userInteractive).async {
//
//                MetadataUtils.loadArt(track)
//
//                // Only do this if there is art to show
//                if track.displayInfo.art != nil {
//                    Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .art))
//                }
//            }
//
//            track.lazyLoadingInfo.artLoaded = true
//        }
//    }
//
//    // Load all the information required to play this track
//    // Assumes that the track is valid (i.e. has at least one audio track, is supported, etc.)
//    static func prepareForPlayback(_ track: Track) {
//
//        loadArt(track)
//
//        // Track is valid, prepare it for playback
//        AudioUtils.loadPlaybackInfo(track)
//
//        // Chapters
//        loadChapters(track)
//
//        let lazyLoadInfo = track.lazyLoadingInfo
//
//        if !(lazyLoadInfo.preparedForPlayback) {
//
//            // If track couldn't be prepared, mark it as not playable
//            lazyLoadInfo.preparationFailed(TrackNotPlayableError(track))
//        }
//    }
//
//    static func prepareForInfo(_ track: Track) {
//
//        let lazyLoadInfo = track.lazyLoadingInfo
//
//        if lazyLoadInfo.preparedForPlayback || lazyLoadInfo.preparationFailed {
//            return
//        }
//
//        loadArt(track)
//
//        // Validate the audio track
//        track.validateAudio()
//        if lazyLoadInfo.preparationFailed {
//            return
//        }
//
//        // TODO: Call loadAudioInfo here, and put it before the 1st return above ^^.
//        // Track is valid, prepare it for displaying info
//        AudioUtils.loadPlaybackInfo_noPlayback(track)
//    }
//
//    // Load detailed track info
//    static func loadDetailedInfo(_ track: Track) {
//
//        if track.lazyLoadingInfo.detailedInfoLoaded {
//            return
//        }
//
//        // TODO: Merge the 2 following calls ... prepareForInfo and loadAudioInfo
//
//        if !track.lazyLoadingInfo.preparedForPlayback {
//            prepareForInfo(track)
//        }
//
//        // Audio info
//        AudioUtils.loadAudioInfo(track)
//
//        loadFileSystemInfo(track)
//
//        // ID3 / ITunes / other metadata
//        MetadataUtils.loadAllMetadata(track)
//
//        track.lazyLoadingInfo.detailedInfoLoaded = true
//    }
//
//    static func loadFileSystemInfo(_ track: Track) {
//
//        let attrs = FileSystemUtils.fileAttributes(path: track.file.path)
//
//        // Filesystem info
//        track.fileSystemInfo.size = attrs.size
//        track.fileSystemInfo.creationDate = attrs.creationDate
//        track.fileSystemInfo.kindOfFile = attrs.kindOfFile
//        track.fileSystemInfo.lastModified = attrs.lastModified
//        track.fileSystemInfo.lastOpened = attrs.lastOpened
//    }
//
//    static func loadChapters(_ track: Track) {
//        MetadataUtils.loadChapters(track)
//    }
}
