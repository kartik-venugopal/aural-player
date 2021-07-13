//
//  FileReaderProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A contract for a class that handles loading of metadata for a track.
///
/// NOTE - Since this class accepts files as input (as opposed to Track objects), it can be used to load
/// metadata for files that are not present in the playlist as tracks. (e.g. files in the history or favorites menu)
///
protocol FileReaderProtocol {
    
    ///
    /// Loads the essential metadata fields that are required for a track to be loaded into the playlist upon app startup.
    ///
    func getPlaylistMetadata(for file: URL) throws -> PlaylistMetadata
    
    func computeAccurateDuration(for file: URL) -> Double?
    
    ///
    /// Loads all metadata and resources that are required for track playback.
    ///
    func getPlaybackMetadata(for file: URL) throws -> PlaybackContextProtocol
    
    ///
    /// Loads cover art for a file.
    ///
    func getArt(for file: URL) -> CoverArt?
    
    ///
    /// Loads all non-essential ("auxiliary") metadata associated with a track, for display in the "Detailed track info" view.
    ///
    func getAuxiliaryMetadata(for file: URL, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol?) -> AuxiliaryMetadata
    
    func getAllMetadata(for file: URL) -> FileMetadata
}

///
/// A facade for loading metadata for a track.
/// Delegates to either AVFoundation or FFmpeg depending on whether or not the track is natively supported.
///
class FileReader: FileReaderProtocol {
    
    ///
    /// The actual file reader for natively supported tracks. Uses AVFoundation.
    ///
    let avfReader: AVFFileReader = AVFFileReader()
    
    ///
    /// The actual file reader for non-native tracks. Uses FFmpeg.
    ///
    let ffmpegReader: FFmpegFileReader = FFmpegFileReader()
    
    func getPlaylistMetadata(for file: URL) throws -> PlaylistMetadata {
        
        return file.isNativelySupported ?
            try avfReader.getPlaylistMetadata(for: file) :
            try ffmpegReader.getPlaylistMetadata(for: file)
    }
    
    func computeAccurateDuration(for file: URL) -> Double? {
        
        return file.isNativelySupported ?
            avfReader.computeAccurateDuration(for: file) :
            ffmpegReader.computeAccurateDuration(for: file)
    }
    
    func getPlaybackMetadata(for file: URL) throws -> PlaybackContextProtocol {
        
        return file.isNativelySupported ?
            try avfReader.getPlaybackMetadata(for: file) :
            try ffmpegReader.getPlaybackMetadata(for: file)
    }
    
    func getArt(for file: URL) -> CoverArt? {
        
        // Try retrieving cover art from the cache.
        if let cachedArt = CoverArtCache.forFile(file) {
            return cachedArt.art
        }
        
        // Cover art was not found in the cache, load it from the appropriate file reader.
        let art: CoverArt? = file.isNativelySupported ?
            avfReader.getArt(for: file) :
            ffmpegReader.getArt(for: file)
        
        // Update the cache with the newly loaded cover art.
        CoverArtCache.addEntry(file, art)
        
        return art
    }
    
    func getAuxiliaryMetadata(for file: URL, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol? = nil) -> AuxiliaryMetadata {
        
        // Load aux metadata for the track.
        
        let actualFileReader: FileReaderProtocol = file.isNativelySupported ? avfReader : ffmpegReader
        var auxMetadata: AuxiliaryMetadata = actualFileReader.getAuxiliaryMetadata(for: file, loadingAudioInfoFrom: playbackContext)
        
        // Load file system info for the track.
        
        let fileSystemInfo = FileSystemInfo(file)
        let attrs = file.attributes
        
        fileSystemInfo.size = attrs.size
        fileSystemInfo.creationDate = attrs.creationDate
        fileSystemInfo.kindOfFile = attrs.kindOfFile
        fileSystemInfo.lastModified = attrs.lastModified
        fileSystemInfo.lastOpened = attrs.lastOpened
        
        auxMetadata.fileSystemInfo = fileSystemInfo
        
        return auxMetadata
    }
    
    func getAllMetadata(for file: URL) -> FileMetadata {
        
        return file.isNativelySupported ?
            avfReader.getAllMetadata(for: file) :
            ffmpegReader.getAllMetadata(for: file)
    }
}
