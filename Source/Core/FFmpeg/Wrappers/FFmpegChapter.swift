//
//  FFmpegChapter.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates a single chapter marking (**AVChapter**) within an audio file.
///
struct FFmpegChapter {
    
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
        let conversionFactor: Double = chapter.time_base.ratio
        
        self.startTime = Double(chapter.start) * conversionFactor
        self.endTime = Double(chapter.end) * conversionFactor
        
        self.metadata = FFmpegMetadataReader.read(from: chapter.metadata)

        // If the chapter's metadata does not have a "title" tag, create a default title
        // that contains the index of the chapter, e.g. "Chapter 2".
        let titleInMetadata: String? = metadata.filter {$0.key.lowercased() == "title"}.first?.value
        self.title = titleInMetadata ?? "Chapter \(index + 1)"
    }
}

extension Chapter {
    
    convenience init(_ ffmpegChapter: FFmpegChapter) {
        
        self.init(title: ffmpegChapter.title, startTime: ffmpegChapter.startTime, endTime: ffmpegChapter.endTime,
                  duration: max(ffmpegChapter.endTime - ffmpegChapter.startTime, 0))
    }
}
