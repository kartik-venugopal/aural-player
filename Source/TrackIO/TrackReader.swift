import Foundation

class TrackReader {
    
    let avfReader: AVFFileReader = AVFFileReader()
    let ffmpegReader: FFmpegFileReader = FFmpegFileReader()
    
    func loadPrimaryMetadata(for track: Track) {
        
        do {
            
            let metadata: PrimaryMetadata
            
            if track.isNativelySupported {
                metadata = try avfReader.getPrimaryMetadata(for: track.file)
            } else {
                metadata = try ffmpegReader.getPrimaryMetadata(for: track.file)
            }

            track.title = metadata.title
            track.artist = metadata.artist
            track.albumArtist = metadata.albumArtist
            track.album = metadata.album
            track.genre = metadata.genre

            track.composer = metadata.composer
            track.conductor = metadata.conductor
            track.lyricist = metadata.lyricist
            track.performer = metadata.performer
            
            track.year = metadata.year
            track.bpm = metadata.bpm
            
            track.duration = metadata.duration
            
            track.art = metadata.art
            
            track.audioFormat = metadata.audioFormat
            
        } catch {
            
            track.isPlayable = false
            track.validationError = (error as? DisplayableError) ?? InvalidTrackError(track.file, "Track is not playable.")
        }
    }
    
    func computePlaybackContext(for track: Track) throws {
        
        if track.isNativelySupported {
            track.playbackContext = try avfReader.getPlaybackMetadata(file: track.file)
        } else {
            track.playbackContext = try ffmpegReader.getPlaybackMetadata(file: track.file)
        }
    }
    
    func prepareForPlayback(track: Track) throws {
        try track.playbackContext?.open()
    }
    
    func loadSecondaryMetadata(for track: Track) {
        
    }
    
    func loadAllMetadata() {
    }
    
    func loadFileSystemInfo(_ track: Track) {
        
        let attrs = FileSystemUtils.fileAttributes(path: track.file.path)
        
        // Filesystem info
        track.fileSize = attrs.size
        track.fileCreationDate = attrs.creationDate
        track.fileLastModifiedDate = attrs.lastModified
        track.fileLastOpenedDate = attrs.lastOpened
    }
}
