/*
    Custom error types for error handling around adding/playing tracks
 */
import Foundation

// Base error class indicating a track that cannot be added/played
class InvalidTrackError: Error {
    
    var file: URL
    var message: String
    
    init(_ file: URL) {
        self.file = file
        self.message = "Invalid track"
    }
}

// Denotes a file with no audio tracks. For ex, a text/image file
class NoAudioTracksError: InvalidTrackError {
    
    override init(_ file: URL) {
        super.init(file)
        self.message = "No audio tracks found in file."
    }
}

// Denotes an audio track that cannot be played
class TrackNotPlayableError: InvalidTrackError {
    
    override init(_ file: URL) {
        super.init(file)
        self.message = "Track is not playable."
    }
}

// Denotes a file that has an unsupported audio format (e.g. WMA)
class UnsupportedFormatError: InvalidTrackError {
    
    init(_ file: URL, _ format: String) {
        super.init(file)
        self.message = String(format: "Track format '%@' is not supported.", format)
    }
}
