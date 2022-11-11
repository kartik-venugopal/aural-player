//
//  Errors.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Custom error types for error handling.
///

///
/// Represents an error that is displayable (in the UI).
///
class DisplayableError: Error {
    
    // A user-friendly message describing the error
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}

///
/// Represents an error signifying that no track was requested for playback, indicating
/// that playback cannot begin.
///
class NoRequestedTrackError: DisplayableError {
    
    static let instance: NoRequestedTrackError = NoRequestedTrackError()
    
    private init() {
        super.init("No requested track !")
    }
}

///
/// Base error class indicating that a particular track cannot be played.
///
class InvalidTrackError: DisplayableError {
    
    let file: URL
    
    init(_ file: URL, _ message: String) {

        self.file = file
        super.init(message)
    }
}

///
/// Error indicating that the given file cannot be found on the file system.
///
class FileNotFoundError: DisplayableError {
    
    let file: URL
    
    init(_ file: URL) {

        self.file = file
        super.init("File not found on the filesystem. It may have been renamed/moved/deleted.")
    }
}

///
/// Represents an error indicating a file with no audio tracks. For ex, a text/image file.
///
class NoAudioTracksError: InvalidTrackError {
    
    init(_ file: URL) {
        super.init(file, "No audio tracks found in file. Is it a valid audio file ?")
    }
}

///
/// Represents an error indicating a track that cannot be played.
///
class TrackNotPlayableError: InvalidTrackError {
    
    init(_ file: URL) {
        super.init(file, "File is not a playable audio track. Is it a valid audio file of a supported format ?")
    }
}

///
/// Represents an error indicating that a track has Digital Rights Management (DRM)
/// protection and cannot be played.
///
class DRMProtectionError: InvalidTrackError {
    
    init(_ file: URL) {
        super.init(file, "This track has Digital Rights Management (DRM) protection, and cannot be played back.")
    }
}

///
/// Represents an error indicating invalid user input.
///
class InvalidInputError: DisplayableError {
}

///
/// Represents an error indicating that an option to load a playlist file has been selected
/// but no playlist file was specified.
///
class PlaylistFileNotSpecifiedError: InvalidInputError {
}
