import Foundation

///
/// Encapsulates a single chapter marking (AVChapter) within an audio file.
///
class FFmpegChapter {
    
    /// Time when the represented chapter begins, in seconds.
    let startTime: Double
    
    /// Time when the represented chapter ends, in seconds.
    let endTime: Double
    
    /// Title metadata for the represented chapter.
    let title: String
    
    /// All metadata key / value pairs for this chapter marking (e.g. title, artist, etc)
    let metadata: [String: String]
    
    init(encapsulating chapter: AVChapter, atIndex index: Int) {
        
        // Ratio used to convert from the chapter's time base units to seconds.
        let conversionFactor: Double = Double(chapter.time_base.num) / Double(chapter.time_base.den)
        
        self.startTime = Double(chapter.start) * conversionFactor
        self.endTime = Double(chapter.end) * conversionFactor
        
        self.metadata = FFmpegMetadataReader.read(from: chapter.metadata)

        // If the chapter's metadata does not have a "title" tag, create a default title
        // that contains the index of the chapter, e.g. "Chapter 2".
        let titleInMetadata: String? = metadata.filter {$0.key.lowercased() == "title"}.first?.value
        self.title = titleInMetadata ?? "Chapter \(index + 1)"
    }
}
