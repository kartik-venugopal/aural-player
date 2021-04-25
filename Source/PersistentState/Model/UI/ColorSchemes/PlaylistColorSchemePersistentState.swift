import Foundation

/*
    Encapsulates persistent app state for a single PlaylistColorScheme.
 */
class PlaylistColorSchemePersistentState: PersistentStateProtocol {
    
    var trackNameTextColor: ColorPersistentState?
    var groupNameTextColor: ColorPersistentState?
    var indexDurationTextColor: ColorPersistentState?
    
    var trackNameSelectedTextColor: ColorPersistentState?
    var groupNameSelectedTextColor: ColorPersistentState?
    var indexDurationSelectedTextColor: ColorPersistentState?

    var summaryInfoColor: ColorPersistentState?
    
    var playingTrackIconColor: ColorPersistentState?
    var selectionBoxColor: ColorPersistentState?
    var groupIconColor: ColorPersistentState?
    var groupDisclosureTriangleColor: ColorPersistentState?
    
    init() {}
    
    init(_ scheme: PlaylistColorScheme) {
        
        self.trackNameTextColor = ColorPersistentState.fromColor(scheme.trackNameTextColor)
        self.groupNameTextColor = ColorPersistentState.fromColor(scheme.groupNameTextColor)
        self.indexDurationTextColor = ColorPersistentState.fromColor(scheme.indexDurationTextColor)
        
        self.trackNameSelectedTextColor = ColorPersistentState.fromColor(scheme.trackNameSelectedTextColor)
        self.groupNameSelectedTextColor = ColorPersistentState.fromColor(scheme.groupNameSelectedTextColor)
        self.indexDurationSelectedTextColor = ColorPersistentState.fromColor(scheme.indexDurationSelectedTextColor)
        
        self.groupIconColor = ColorPersistentState.fromColor(scheme.groupIconColor)
        self.groupDisclosureTriangleColor = ColorPersistentState.fromColor(scheme.groupDisclosureTriangleColor)
        self.selectionBoxColor = ColorPersistentState.fromColor(scheme.selectionBoxColor)
        self.playingTrackIconColor = ColorPersistentState.fromColor(scheme.playingTrackIconColor)
        
        self.summaryInfoColor = ColorPersistentState.fromColor(scheme.summaryInfoColor)
    }
    
    required init?(_ map: NSDictionary) {
        
        self.trackNameTextColor = map.colorValue(forKey: "trackNameTextColor")
        self.groupNameTextColor = map.colorValue(forKey: "groupNameTextColor")
        self.indexDurationTextColor = map.colorValue(forKey: "indexDurationTextColor")
        self.trackNameSelectedTextColor = map.colorValue(forKey: "trackNameSelectedTextColor")
        self.groupNameSelectedTextColor = map.colorValue(forKey: "groupNameSelectedTextColor")
        self.indexDurationSelectedTextColor = map.colorValue(forKey: "indexDurationSelectedTextColor")
        self.groupIconColor = map.colorValue(forKey: "groupIconColor")
        self.groupDisclosureTriangleColor = map.colorValue(forKey: "groupDisclosureTriangleColor")
        self.selectionBoxColor = map.colorValue(forKey: "selectionBoxColor")
        self.playingTrackIconColor = map.colorValue(forKey: "playingTrackIconColor")
        self.summaryInfoColor = map.colorValue(forKey: "summaryInfoColor")
    }
}
