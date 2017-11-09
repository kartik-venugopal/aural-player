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
