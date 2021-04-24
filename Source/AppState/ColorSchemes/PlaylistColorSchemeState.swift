import Foundation

/*
    Encapsulates persistent app state for a single PlaylistColorScheme.
 */
class PlaylistColorSchemeState: PersistentStateProtocol {
    
    var trackNameTextColor: ColorState?
    var groupNameTextColor: ColorState?
    var indexDurationTextColor: ColorState?
    
    var trackNameSelectedTextColor: ColorState?
    var groupNameSelectedTextColor: ColorState?
    var indexDurationSelectedTextColor: ColorState?

    var summaryInfoColor: ColorState?
    
    var playingTrackIconColor: ColorState?
    var selectionBoxColor: ColorState?
    var groupIconColor: ColorState?
    var groupDisclosureTriangleColor: ColorState?
    
    init() {}
    
    init(_ scheme: PlaylistColorScheme) {
        
        self.trackNameTextColor = ColorState.fromColor(scheme.trackNameTextColor)
        self.groupNameTextColor = ColorState.fromColor(scheme.groupNameTextColor)
        self.indexDurationTextColor = ColorState.fromColor(scheme.indexDurationTextColor)
        
        self.trackNameSelectedTextColor = ColorState.fromColor(scheme.trackNameSelectedTextColor)
        self.groupNameSelectedTextColor = ColorState.fromColor(scheme.groupNameSelectedTextColor)
        self.indexDurationSelectedTextColor = ColorState.fromColor(scheme.indexDurationSelectedTextColor)
        
        self.groupIconColor = ColorState.fromColor(scheme.groupIconColor)
        self.groupDisclosureTriangleColor = ColorState.fromColor(scheme.groupDisclosureTriangleColor)
        self.selectionBoxColor = ColorState.fromColor(scheme.selectionBoxColor)
        self.playingTrackIconColor = ColorState.fromColor(scheme.playingTrackIconColor)
        
        self.summaryInfoColor = ColorState.fromColor(scheme.summaryInfoColor)
    }
    
    required init?(_ map: NSDictionary) -> PlaylistColorSchemeState? {
        
        let state = PlaylistColorSchemeState()
        
        if let colorDict = map["trackNameTextColor"] as? NSDictionary {
            state.trackNameTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["groupNameTextColor"] as? NSDictionary {
            state.groupNameTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["indexDurationTextColor"] as? NSDictionary {
            state.indexDurationTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["trackNameSelectedTextColor"] as? NSDictionary {
            state.trackNameSelectedTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["groupNameSelectedTextColor"] as? NSDictionary {
            state.groupNameSelectedTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["indexDurationSelectedTextColor"] as? NSDictionary {
            state.indexDurationSelectedTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["groupIconColor"] as? NSDictionary {
            state.groupIconColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["groupDisclosureTriangleColor"] as? NSDictionary {
            state.groupDisclosureTriangleColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["selectionBoxColor"] as? NSDictionary {
            state.selectionBoxColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["playingTrackIconColor"] as? NSDictionary {
            state.playingTrackIconColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["summaryInfoColor"] as? NSDictionary {
            state.summaryInfoColor = ColorState.deserialize(colorDict)
        }
        
        return state
    }
}
