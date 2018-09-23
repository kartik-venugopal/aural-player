/*
    Custom error types for error handling
 */
import Foundation

// Protocol that marks an error as being displayable (in an alert, for instance)
protocol DisplayableError {
    
    // A user-friendly message describing the error
    var message: String {get}
}

// Base error class indicating a track that cannot be played
class InvalidTrackError: Error, DisplayableError {
    
    var track: Track
    var message: String
    
    init(_ track: Track) {
        self.track = track
        self.message = "Invalid track"
    }
}

// Denotes a non-existent file
class FileNotFoundError: Error, DisplayableError {
    
    var file: URL
    var message: String
    
    init(_ file: URL) {
        self.file = file
        self.message = "File not found on the filesystem. It may have been renamed/moved/deleted."
    }
}

// Denotes a file with no audio tracks. For ex, a text/image file
class NoAudioTracksError: InvalidTrackError {
    
    override init(_ track: Track) {
        super.init(track)
        self.message = "No audio tracks found in file. Is it a valid audio file ?"
    }
}

// Denotes an audio track that cannot be played
class TrackNotPlayableError: InvalidTrackError {
    
    override init(_ track: Track) {
        super.init(track)
        self.message = "File is not a playable audio track. Is it a valid audio file of a supported format ?"
    }
}

// Denotes a file that has an unsupported audio format (e.g. WMA)
class UnsupportedFormatError: InvalidTrackError {
    
    init(_ track: Track, _ format: String) {
        super.init(track)
        self.message = String(format: "Track format '%@' is not supported.", format)
    }
}

// Indicates invalid user input
class InvalidInputError: Error, DisplayableError {
    
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}

// Marker class indicating that an option to load a playlist file has been selected but no playlist file specified
class PlaylistFileNotSpecifiedError: InvalidInputError {
}
