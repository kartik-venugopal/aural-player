import Cocoa

///
/// Encapsulates all metadata for a single audio track.
///
struct FFmpegTrackMetadata {
    
    ///
    /// Technical audio data for the audio stream in this file. e.g. codec name, sample rate, bit rate, etc.
    ///
    var audioInfo: FFmpegAudioInfo
    
    ///
    /// ID3 / iTunes tags (e.g. artist / album, etc)
    ///
    var metadata: [String: String]
    
    ///
    /// Cover art, if present
    ///
    var art: NSImage?
    
    ///
    /// Metadata about the cover art (e.g. image type, dimensions, etc)
    ///
    var artMetadata: [String: String]?
    
    ///
    /// Chapter markings in the track, if present. Empty array if none present.
    ///
    var chapters: [FFmpegChapter]
    
    ///
    /// A UI-friendly formatted title for this track. May be nil.
    /// It is computed from the artist and/or title tags in the metadata, if present.
    ///
    var displayedTitle: String? {
        
        let title = self.title
        let artist = self.artist

        // If both the title and artist tags are present, return a formatted string with both tags.
        if let theArtist = artist, let theTitle = title {
            return "\(theArtist) - \(theTitle)"
            
        } else {
            
            // No artist present, return the title if present.
            return title
        }
    }
    
    ///
    /// The "title" metadata tag, if present.
    ///
    var title: String? {
        metadata.filter {$0.key.lowercased() == "title"}.first?.value
    }
    
    ///
    /// The "artist" metadata tag, if present.
    ///
    var artist: String? {
        metadata.filter {$0.key.lowercased() == "artist"}.first?.value
    }
    
    ///
    /// The "album" metadata tag, if present.
    ///
    var album: String? {
        metadata.filter {$0.key.lowercased() == "album"}.first?.value
    }
    
    ///
    /// The "genre" metadata tag, if present.
    ///
    var genre: String? {
        metadata.filter {$0.key.lowercased() == "genre"}.first?.value
    }
    
    ///
    /// The "year" metadata tag, if present.
    ///
    var year: String? {
        
        metadata.filter {$0.key.lowercased() == "year"}.first?.value ??
        metadata.filter {$0.key.lowercased() == "date"}.first?.value
    }
    
    ///
    /// A UI-friendly formatted track number string for this track. May be nil.
    /// It is computed from the track number and/or total tracks tags in the metadata, if present.
    ///
    var displayedTrackNum: String? {
        
        let trackNum = self.trackNum
        let trackTotal = self.trackTotal
        
        // If both the track number and total tracks tags are present, return a formatted string with both tags.
        if let theTrackNum = trackNum, let theTrackTotal = trackTotal {
            return "\(theTrackNum) / \(theTrackTotal)"
            
        } else {
            
            // No total tracks tag present, return the track number tag if present.
            return trackNum
        }
    }
    
    ///
    /// The "track" (track number) metadata tag, if present.
    ///
    var trackNum: String? {
        metadata.filter {$0.key.lowercased() == "track"}.first?.value
    }
    
    ///
    /// The total tracks metadata tag, if present.
    ///
    var trackTotal: String? {
        
        metadata.filter {$0.key.lowercased() == "tracktotal"}.first?.value ??
        metadata.filter {$0.key.lowercased() == "totaltracks"}.first?.value
    }
    
    ///
    /// A UI-friendly formatted disc number string for this track. May be nil.
    /// It is computed from the disc number and/or total discs tags in the metadata, if present.
    ///
    var displayedDiscNum: String? {
        
        let discNum = self.discNum
        let discTotal = self.discTotal
        
        // If both the disc number and total discs tags are present, return a formatted string with both tags.
        if let theDiscNum = discNum, let theDiscTotal = discTotal {
            return "\(theDiscNum) / \(theDiscTotal)"
            
        } else {
            
            // No total discs tag present, return the disc number tag if present.
            return discNum
        }
    }
    
    ///
    /// The "disc" (disc number) metadata tag, if present.
    ///
    var discNum: String? {
        metadata.filter {$0.key.lowercased() == "disc"}.first?.value
    }
    
    ///
    /// The total discs metadata tag, if present.
    ///
    var discTotal: String? {
        
        metadata.filter {$0.key.lowercased() == "disctotal"}.first?.value ??
        metadata.filter {$0.key.lowercased() == "totaldiscs"}.first?.value
    }
    
    ///
    /// Miscellaneous metadata tags (excluding the ones above).
    ///
    var otherMetadata: [String: String] {
        
        let excludedKeys = ["title", "artist", "album", "genre", "year", "date", "track", "disc", "tracktotal", "totaltracks", "disctotal", "totaldiscs"]
        
        return metadata.filter {!excludedKeys.contains($0.key.lowercased())}
    }
}

///
/// Encapsulates all technical audio data for an audio track.
///
struct FFmpegAudioInfo {
    
    /// File format (e.g. "WAV" or "MP3").
    var fileType: String
    
    /// Name of the codec used to decode this audio stream (e.g. "Vorbis" or "Musepack v7").
    var codec: String
    
    /// Duration of this audio stream, in seconds.
    var duration: Double
    
    /// Sampling rate of this audio stream, in Hz (eg. 44.1 KHz).
    var sampleRate: Int
    
    /// Format of the PCM samples in this audio stream. (eg. Signed 32-bit integer planar)
    var sampleFormat: FFmpegSampleFormat
    
    /// Bit rate of the audio stream, in bits per second.
    var bitRate: Int64
    
    /// The layout of channels in the audio stream (e.g. "Stereo" or "5.1 Surround")
    var channelLayout: String
    
    /// Total number of frames present in this audio stream.
    var frameCount: Int64
}
