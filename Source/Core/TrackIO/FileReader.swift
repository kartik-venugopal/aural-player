//
//  FileReader.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A facade for loading metadata for a file.
/// 
/// Delegates to either **AVFoundation** or **FFmpeg** depending on whether or not
/// the file is natively supported.
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
    
    func getPrimaryMetadata(for file: URL) throws -> PrimaryMetadata {
        
        let isCacheEnabled: Bool = preferences.metadataPreferences.cacheTrackMetadata.value
        
        if isCacheEnabled, let cachedMetadata = metadataRegistry[file] {
            return cachedMetadata
        }
        
        let metadata = file.isNativelySupported ?
            try avfReader.getPrimaryMetadata(for: file) :
            try ffmpegReader.getPrimaryMetadata(for: file)
        
        if isCacheEnabled {
            metadataRegistry[file] = metadata
        }
        
        return metadata
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
    
    func getAudioInfo(for file: URL, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol? = nil) -> AudioInfo {
        
        // Load aux metadata for the track.
        
        let actualFileReader: FileReaderProtocol = file.isNativelySupported ? avfReader : ffmpegReader
        return actualFileReader.getAudioInfo(for: file, loadingAudioInfoFrom: playbackContext)
    }
    
    func getAllMetadata(for file: URL) -> FileMetadata {
        
        return file.isNativelySupported ?
            avfReader.getAllMetadata(for: file) :
            ffmpegReader.getAllMetadata(for: file)
    }
}
