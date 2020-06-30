import Foundation

/*
 Encapsulates playlist state
 */
class PlaylistState: PersistentState {
    
    // List of track files
    var tracks: [URL] = [URL]()
    var gaps: [PlaybackGapState] = []
    
    private var _transient_gapsBeforeMap: [URL: PlaybackGapState] = [:]
    private var _transient_gapsAfterMap: [URL: PlaybackGapState] = [:]
    
    func getGapsForTrack(_ file: URL) -> (gapBeforeTrack: PlaybackGapState?, gapAfterTrack: PlaybackGapState?) {
        return (_transient_gapsBeforeMap[file], _transient_gapsAfterMap[file])
    }
    
    func removeGapsForTrack(_ track: Track) {
        _transient_gapsBeforeMap.removeValue(forKey: track.file)
        _transient_gapsAfterMap.removeValue(forKey: track.file)
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaylistState()
        
        (map["tracks"] as? [String])?.forEach({state.tracks.append(URL(fileURLWithPath: $0))})
        
        (map["gaps"] as? [NSDictionary])?.forEach({
            
            let gap = PlaybackGapState.deserialize($0) as! PlaybackGapState
            
            // Gap is useless without an associated track
            if let track = gap.track {
                
                if gap.position == .beforeTrack {
                    state._transient_gapsBeforeMap[track] = gap
                } else {
                    state._transient_gapsAfterMap[track] = gap
                }
                
                state.gaps.append(gap)
            }
        })
        
        return state
    }
}

class PlaybackGapState: PersistentState {
    
    var track: URL?
    
    var duration: Double = AppDefaults.playbackGapDuration
    var position: PlaybackGapPosition = AppDefaults.playbackGapPosition
    var type: PlaybackGapType = AppDefaults.playbackGapType
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaybackGapState()
        
        if let trackStr = map["track"] as? String {
            
            state.track = URL(fileURLWithPath: trackStr)
            state.duration = mapNumeric(map, "duration", AppDefaults.playbackGapDuration)
            state.position = mapEnum(map, "position", AppDefaults.playbackGapPosition)
            state.type = mapEnum(map, "type", AppDefaults.playbackGapType)
        }
        
        return state
    }
}

extension Playlist: PersistentModelObject {
    
    // Returns all state for this playlist that needs to be persisted to disk
    var persistentState: PersistentState {
        
        let state = PlaylistState()
        state.tracks = tracks.map {$0.file}
        
        [gapsBeforeTracks, gapsAfterTracks].forEach({
            
            for (track, gap) in $0.filter({$0.value.type == .persistent}) {
                
                let gapState = PlaybackGapState()
                
                gapState.track = track.file
                gapState.duration = gap.duration
                gapState.position = gap.position
                gapState.type = gap.type
                
                state.gaps.append(gapState)
            }
        })
        
        return state
    }
}
