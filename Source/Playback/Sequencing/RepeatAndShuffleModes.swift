import Foundation

// Enumeration of all possible playback repeat modes
enum RepeatMode: String, CaseIterable {
    
    // Play all tracks once, in sequence order
    case off
    
    // Repeat one track forever
    case one
    
    // Repeat all tracks forever, in sequence order
    case all
    
    // Returns a RepeatMode that is the result of toggling this RepeatMode.
    func toggled() -> RepeatMode {
        
        switch self {
            
        case .off:
            
            return .one
            
        case .one:
            
            return .all
            
        case .all:
            
            return .off
        }
    }
}

// Enumeration of all possible playback shuffle modes
enum ShuffleMode: String, CaseIterable {
    
    // Play tracks in random order
    case on
    
    // Don't shuffle
    case off
    
    // Returns a ShuffleMode that is the result of toggling this ShuffleMode.
    func toggled() -> ShuffleMode {
        return self == .on ? .off : .on
    }
}

// Enumeration of all possible states of an A->B segment playback loop
enum LoopState: String, CaseIterable {
    
    case none
    case started
    case complete
}
