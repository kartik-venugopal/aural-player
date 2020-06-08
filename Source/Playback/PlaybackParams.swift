import Foundation

/*
    Encapsulates request parameters related to the playback of a track
 */
class PlaybackParams {
    
    // Whether or not there can be a delay before the track begins playing
    // eg. if there is a gap defined in the playlist.
    // A false value indicates immediate playback.
    var allowDelay: Bool = true
    
    // The explicit delay interval provided specifically for this request.
    var delay: Double? = nil
    
    // An optional seek time at which playback will start for the relevant track.
    // e.g. used when playing a bookmark
    var startPosition: Double? = nil
    
    // An optional seek time at which playback will end for the relevant track.
    // The presence of a non-nil value in this parameter indicates a segment loop
    // bounded by startPosition/endPosition.
    var endPosition: Double? = nil
    
    // Whether or not this request can interrupt (i.e. stop) the playback
    // of a currently playing track, if there is one.
    // If false, playback will occur only if no track is currently playing.
    // e.g. used for autoplay
    var interruptPlayback: Bool = true
    
    // Builder pattern function to set a delay.
    func withDelay(_ delay: Double?) -> PlaybackParams {
        
        self.delay = delay
        return self
    }
    
    // Builder pattern function to set a start position.
    func withStartPosition(_ startPosition: Double) -> PlaybackParams {
        
        self.startPosition = startPosition
        return self
    }
    
    // Builder pattern function to set a start/end position, i.e. a segment loop.
    func withStartAndEndPosition(_ startPosition: Double, _ endPosition: Double?) -> PlaybackParams {
        
        self.startPosition = startPosition
        self.endPosition = endPosition
        
        return self
    }
    
    // Builder pattern function to set the allowDelay parameter.
    func withAllowDelay(_ allowDelay: Bool) -> PlaybackParams {
        
        self.allowDelay = allowDelay
        return self
    }
    
    // Builder pattern function to set the interruptPlayback parameter.
    func withInterruptPlayback(_ interruptPlayback: Bool) -> PlaybackParams {
        
        self.interruptPlayback = interruptPlayback
        return self
    }
    
    // Factory method to create an instance with default request parameters.
    static func defaultParams() -> PlaybackParams {
        return PlaybackParams()
    }
}
