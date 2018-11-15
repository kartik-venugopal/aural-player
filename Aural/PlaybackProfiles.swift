import Foundation

// TODO: Code duplication with SoundProfiles
class PlaybackProfiles: TrackKeyedMap<PlaybackProfile> {}

class PlaybackProfile {
    
    let file: URL
    
    // Last playback position
    var lastPosition: Double = 0
    
    // TODO: Seek length ? Long for audiobooks, short for tracks
    init(_ file: URL, _ lastPosition: Double) {
        self.file = file
        self.lastPosition = lastPosition
    }
}
