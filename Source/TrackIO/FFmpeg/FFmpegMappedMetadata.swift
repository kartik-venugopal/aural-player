import Foundation

class FFmpegMappedMetadata {
    
    let fileCtx: FFmpegFileContext
    let fileType: String
    
    let audioStream: FFmpegAudioStream?
    let imageStream: FFmpegImageStream?
    
    var map: [String: String] = [:]
    
    let commonMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let id3Metadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let wmMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let vorbisMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let apeMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let otherMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    
    init(for fileCtx: FFmpegFileContext) {
        
        self.fileCtx = fileCtx
        self.fileType = fileCtx.file.lowerCasedExtension
        
        self.audioStream = fileCtx.bestAudioStream
        self.imageStream = fileCtx.bestImageStream

        for (key, value) in fileCtx.metadata {
            map[key] = value
        }
        
        for (key, value) in audioStream?.metadata ?? [:] {
            map[key] = value
        }
    }
}

class FFmpegParserMetadataMap {
    
    var essentialFields: [String: String] = [:]
    var genericFields: [String: String] = [:]
}
