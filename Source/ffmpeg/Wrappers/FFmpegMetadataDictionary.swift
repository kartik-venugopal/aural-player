import Foundation

///
/// Reads metadata from an AVDictionary.
///
class FFmpegMetadataDictionary {

    ///
    /// A dictionary of String key / value pairs produced by reading the underlying AVDictionary.
    ///
    let dictionary: [String: String]
    
    ///
    /// Reads key / value pairs from a pointer to an AVDictionary and stores them in a Swift String-typed Dictionary.
    ///
    /// - Parameter pointer: Pointer to the source AVDictionary from which key / value pairs are to be read.
    ///
    /// # Note #
    ///
    /// After this initializer has finished executing, all the metadata that was read will be available in the **dictionary**
    /// property of this object.
    ///
    init(readingFrom pointer: OpaquePointer!) {
        
        var metadata: [String: String] = [:]
        var tagPtr: UnsafeMutablePointer<AVDictionaryEntry>?
        
        while let tag = av_dict_get(pointer, "", tagPtr, AV_DICT_IGNORE_SUFFIX) {
            
            metadata[String(cString: tag.pointee.key)] = String(cString: tag.pointee.value)
            tagPtr = tag
        }
        
        self.dictionary = metadata
    }
}
