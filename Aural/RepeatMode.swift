/*
    Enumeration of all possible playback repeat modes
*/

import Foundation

enum RepeatMode: String {
    
    // Play all tracks once, in playlist order
    case off
    
    // Repeat one track forever
    case one
    
    // Repeat all tracks forever, in playlist order
    case all
}
