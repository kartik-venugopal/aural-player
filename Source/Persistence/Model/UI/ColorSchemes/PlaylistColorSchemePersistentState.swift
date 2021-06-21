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
        
        self.trackNameTextColor = map.persistentColorValue(forKey: "trackNameTextColor")
        self.groupNameTextColor = map.persistentColorValue(forKey: "groupNameTextColor")
        self.indexDurationTextColor = map.persistentColorValue(forKey: "indexDurationTextColor")
        self.trackNameSelectedTextColor = map.persistentColorValue(forKey: "trackNameSelectedTextColor")
        self.groupNameSelectedTextColor = map.persistentColorValue(forKey: "groupNameSelectedTextColor")
        self.indexDurationSelectedTextColor = map.persistentColorValue(forKey: "indexDurationSelectedTextColor")
        self.groupIconColor = map.persistentColorValue(forKey: "groupIconColor")
        self.groupDisclosureTriangleColor = map.persistentColorValue(forKey: "groupDisclosureTriangleColor")
        self.selectionBoxColor = map.persistentColorValue(forKey: "selectionBoxColor")
        self.playingTrackIconColor = map.persistentColorValue(forKey: "playingTrackIconColor")
        self.summaryInfoColor = map.persistentColorValue(forKey: "summaryInfoColor")
    }
}
