/*
    Custom error types for error handling
 */
import Foundation

// Protocol that marks an error as being displayable (in an alert, for instance)
class DisplayableError: Error {
    
    // A user-friendly message describing the error
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}

class NoRequestedTrackError: DisplayableError {
    
    static let instance: NoRequestedTrackError = NoRequestedTrackError()
    
    private init() {
        super.init("No requested track !")
    }
}

// Base error class indicating a track that cannot be played
class InvalidTrackError: DisplayableError {
    
    let file: URL
    
    init(_ file: URL, _ message: String) {

        self.file = file
        super.init(message)
    }
}

// Denotes a non-existent file
class FileNotFoundError: DisplayableError {
    
    let file: URL
    
    init(_ file: URL) {

        self.file = file
        super.init("File not found on the filesystem. It may have been renamed/moved/deleted.")
    }
}

// Denotes a file with no audio tracks. For ex, a text/image file
class NoAudioTracksError: InvalidTrackError {
    
    init(_ file: URL) {
        super.init(file, "No audio tracks found in file. Is it a valid audio file ?")
    }
}

// Denotes an audio track that cannot be played
class TrackNotPlayableError: InvalidTrackError {
    
    init(_ file: URL) {
        super.init(file, "File is not a playable audio track. Is it a valid audio file of a supported format ?")
    }
}

// Denotes a file that has an unsupported audio format (e.g. WMA)
class UnsupportedFormatError: InvalidTrackError {
    
    init(_ file: URL, format: String) {
        super.init(file, String(format: "Track format '%@' is not supported.", format))
    }
}

class DRMProtectionError: InvalidTrackError {
    
    init(_ file: URL) {
        super.init(file, "This track has Digital Rights Management (DRM) protection, and cannot be played back.")
    }
}

// Indicates invalid user input
class InvalidInputError: DisplayableError {
}

// Marker class indicating that an option to load a playlist file has been selected but no playlist file specified
class PlaylistFileNotSpecifiedError: InvalidInputError {
}
