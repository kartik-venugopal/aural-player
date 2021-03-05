import Foundation

protocol FileReaderProtocol {
    
    func getPrimaryMetadata(for file: URL) throws -> PrimaryMetadata
    
    func getSecondaryMetadata(for file: URL) -> SecondaryMetadata
    
    func getArt(for file: URL) -> CoverArt?
    
    func getPlaybackMetadata(for file: URL) throws -> PlaybackContextProtocol
}

class FileReader: FileReaderProtocol {
    
    let avfReader: AVFFileReader = AVFFileReader()
    let ffmpegReader: FFmpegFileReader = FFmpegFileReader()
    
    func getPrimaryMetadata(for file: URL) throws -> PrimaryMetadata {
        
        let fileExtension = file.pathExtension.lowercased()
        
        if AppConstants.SupportedTypes.nativeAudioExtensions.contains(fileExtension) {
            return try avfReader.getPrimaryMetadata(for: file)
            
        } else {
            return try ffmpegReader.getPrimaryMetadata(for: file)
        }
    }
    
    func getSecondaryMetadata(for file: URL) -> SecondaryMetadata {
        return SecondaryMetadata()
    }
    
    func getArt(for file: URL) -> CoverArt? {
        
        let fileExtension = file.pathExtension.lowercased()
        
        if AppConstants.SupportedTypes.nativeAudioExtensions.contains(fileExtension) {
            return avfReader.getArt(for: file)
            
        } else {
            return ffmpegReader.getArt(for: file)
        }
    }
    
    func getPlaybackMetadata(for file: URL) throws -> PlaybackContextProtocol {
        
        let fileExtension = file.pathExtension.lowercased()
        
        if AppConstants.SupportedTypes.nativeAudioExtensions.contains(fileExtension) {
            return try avfReader.getPlaybackMetadata(for: file)
            
        } else {
            return try ffmpegReader.getPlaybackMetadata(for: file)
        }
    }
}
