import Foundation

/*
    Encapsulates playback sequence state
 */
class PlaybackSequenceState: PersistentState {
    
    var repeatMode: RepeatMode = AppDefaults.repeatMode
    var shuffleMode: ShuffleMode = AppDefaults.shuffleMode
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaybackSequenceState()
        
        state.repeatMode = mapEnum(map, "repeatMode", AppDefaults.repeatMode)
        state.shuffleMode = mapEnum(map, "shuffleMode", AppDefaults.shuffleMode)
        
        return state
    }
}

extension Sequencer: PersistentModelObject {
    
    var persistentState: PersistentState {
        
        let state = PlaybackSequenceState()
        
        let modes = sequence.repeatAndShuffleModes
        state.repeatMode = modes.repeatMode
        state.shuffleMode = modes.shuffleMode
        
        return state
    }
}
