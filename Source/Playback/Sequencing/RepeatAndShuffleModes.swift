import Foundation

// Enumeration of all possible playback repeat modes
enum RepeatMode: String {
    
    // Play all tracks once, in sequence order
    case off
    
    // Repeat one track forever
    case one
    
    // Repeat all tracks forever, in sequence order
    case all
}

// Enumeration of all possible playback shuffle modes
enum ShuffleMode: String {
    
    // Play tracks in random order
    case on
    
    // Don't shuffle
    case off
}

// Enumeration of all possible states of an A->B segment playback loop
enum LoopState: String {
    
    case none
    case started
    case complete
}
