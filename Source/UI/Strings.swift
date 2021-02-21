import Foundation

struct Strings {
    
    // Default value for the label that shows a track's seek position
    static let zeroDurationString: String = "0:00"
    
    static let info_seekLengthPrimary: String = "The time interval by which the player will increment/decrement the playback position within the current track, each time the user seeks forward or backward. This value will be used by the application's main seek controls (on the player and in the Playback menu). Set this value as appropriate for frequent use.\n\nTip - Use this in conjunction with the Secondary seek length, to combine fine-grained seeking with more coarse-grained seeking. For instance, Primary seek length could specify a shorter interval for more accurate seeking and Secondary seek length could specify a larger interval for quickly skipping through larger tracks."
    
    static let info_seekLengthSecondary: String = "The time interval by which the player will increment/decrement the playback position within the current track, each time the user seeks forward or backward. This value will be used by the secondary seek controls in the Playback menu (and the corresponding keyboard shortcuts). Set this value as appropriate for relatively infrequent use.\n\nTip - Use this in conjunction with the Primary seek length, to combine fine-grained seeking with more coarse-grained seeking. For instance, Primary seek length could specify a shorter interval for more accurate seeking and Secondary seek length could specify a larger interval for quickly skipping through larger tracks."
}
