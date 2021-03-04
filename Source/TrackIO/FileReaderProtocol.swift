import Foundation

protocol FileReaderProtocol {
    
    func getPrimaryMetadata(for file: URL) throws -> PrimaryMetadata
    
    func getSecondaryMetadata(for file: URL) -> SecondaryMetadata
    
    func getPlaybackMetadata(file: URL) throws -> PlaybackContextProtocol
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
    
    func getPlaybackMetadata(file: URL) throws -> PlaybackContextProtocol {
        
        let fileExtension = file.pathExtension.lowercased()
        
        if AppConstants.SupportedTypes.nativeAudioExtensions.contains(fileExtension) {
            return try avfReader.getPlaybackMetadata(file: file)
            
        } else {
            return try ffmpegReader.getPlaybackMetadata(file: file)
        }
    }
}
