import Foundation

// Enumeration of all possible playback repeat modes
enum RepeatMode: String {
    
    // Play all tracks once, in playlist order
    case off
    
    // Repeat one track forever
    case one
    
    // Repeat all tracks forever, in playlist order
    case all
}

// Enumeration of all possible playback shuffle modes
enum ShuffleMode: String {
    
    // Play tracks in random order
    case on
    
    // Don't shuffle
    case off
}
