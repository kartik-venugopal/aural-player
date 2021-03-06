import Foundation

protocol FileReaderProtocol {
    
    func getPlaylistMetadata(for file: URL) throws -> PlaylistMetadata
    
    func getPlaybackMetadata(for file: URL) throws -> PlaybackContextProtocol
    
    func getArt(for file: URL) -> CoverArt?
    
    func getAuxiliaryMetadata(for file: URL, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol?, loadArt: Bool) -> AuxiliaryMetadata
}

class FileReader: FileReaderProtocol {
    
    let avfReader: AVFFileReader = AVFFileReader()
    let ffmpegReader: FFmpegFileReader = FFmpegFileReader()
    
    func getPlaylistMetadata(for file: URL) throws -> PlaylistMetadata {
        return file.isNativelySupported ? try avfReader.getPlaylistMetadata(for: file) : try ffmpegReader.getPlaylistMetadata(for: file)
    }
    
    func getPlaybackMetadata(for file: URL) throws -> PlaybackContextProtocol {
        return file.isNativelySupported ? try avfReader.getPlaybackMetadata(for: file) : try ffmpegReader.getPlaybackMetadata(for: file)
    }
    
    func getArt(for file: URL) -> CoverArt? {
        
        if let cachedArt = AlbumArtCache.forFile(file) {
            return cachedArt.art
        }
        
        let art: CoverArt? = file.isNativelySupported ? avfReader.getArt(for: file) : ffmpegReader.getArt(for: file)
        AlbumArtCache.addEntry(file, art)
        
        return art
    }
    
    func getAuxiliaryMetadata(for file: URL, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol? = nil, loadArt: Bool) -> AuxiliaryMetadata {
        
        var auxMetadata: AuxiliaryMetadata
        
        var foundInCache: Bool = false
        var artInCache: CoverArt? = nil
        
        // Check the cache for the art
        if loadArt, let cachedArt = AlbumArtCache.forFile(file) {

            foundInCache = true
            artInCache = cachedArt.art
        }
        
        if file.isNativelySupported {
            auxMetadata = avfReader.getAuxiliaryMetadata(for: file, loadingAudioInfoFrom: playbackContext, loadArt: loadArt && !foundInCache)
        } else {
            auxMetadata = ffmpegReader.getAuxiliaryMetadata(for: file, loadingAudioInfoFrom: playbackContext, loadArt: loadArt && !foundInCache)
        }
        
        if loadArt {
            
            if foundInCache {
                auxMetadata.art = artInCache
            } else {
                AlbumArtCache.addEntry(file, auxMetadata.art)
            }
        }
        
        let fileSystemInfo = FileSystemInfo(file)
        let attrs = FileSystemUtils.fileAttributes(path: file.path)
        
        // Filesystem info
        fileSystemInfo.size = attrs.size
        fileSystemInfo.creationDate = attrs.creationDate
        fileSystemInfo.kindOfFile = attrs.kindOfFile
        fileSystemInfo.lastModified = attrs.lastModified
        fileSystemInfo.lastOpened = attrs.lastOpened
        
        auxMetadata.fileSystemInfo = fileSystemInfo
        
        return auxMetadata
    }
}
