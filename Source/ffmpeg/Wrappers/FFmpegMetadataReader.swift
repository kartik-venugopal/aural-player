import Foundation

///
/// Reads metadata from an AVDictionary.
///
class FFmpegMetadataReader {

    ///
    /// Reads key / value pairs from a pointer to an AVDictionary and returns them in a Swift String-typed Dictionary.
    ///
    /// - Parameter pointer: Pointer to the source AVDictionary from which key / value pairs are to be read.
    ///
    static func read(from pointer: OpaquePointer!) -> [String: String] {
        
        var metadata: [String: String] = [:]
        var tagPtr: UnsafeMutablePointer<AVDictionaryEntry>?
        
        while let tag = av_dict_get(pointer, "", tagPtr, AV_DICT_IGNORE_SUFFIX) {
            
            metadata[String(cString: tag.pointee.key)] = String(cString: tag.pointee.value)
            tagPtr = tag
        }
        
        return metadata
    }
}
