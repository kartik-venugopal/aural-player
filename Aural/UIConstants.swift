/*
    A collection of constants for use by the UI
*/
import Cocoa

struct UIConstants {
    
    // Y co-ordinates for the Track Name label, depending on whether it is displaying one or two lines of text
    static let trackNameLabelLocationY_oneLine: CGFloat = 53
    static let trackNameLabelLocationY_twoLines: CGFloat = 53
    
    // Height values for the Track Name label, depending on whether it is displaying one or two lines of text
    static let trackNameLabelHeight_oneLine: CGFloat = 30
    static let trackNameLabelHeight_twoLines: CGFloat = 45
    
    static let minImgScopeLocationX: CGFloat = 85
    
    // Playlist view column identifiers
    static let playlistIndexColumnID: String = "cid_Index"
    static let playlistNameColumnID: String = "cid_Name"
    static let playlistDurationColumnID: String = "cid_Duration"
    
    // Track info view column identifiers (popover)
    static let trackInfoKeyColumnID: String = "cid_TrackInfoKey"
    static let trackInfoValueColumnID: String = "cid_TrackInfoValue"
    
    // Index set used to reload specific playlist rows
    static let flatPlaylistViewColumnIndexes: IndexSet = IndexSet([0, 1, 2])
    static let groupingPlaylistViewColumnIndexes: IndexSet = IndexSet([0, 1])
    
    // Values used to determine the row height of table rows in the detailed track info popover view
    static let trackInfoKeyColumnWidth: CGFloat = 125
    static let trackInfoValueColumnWidth: CGFloat = 315
    
    // Default seek timer interval (milliseconds)
    static let seekTimerIntervalMillis: Int = 500
    
    // Recorder timer interval (milliseconds)
    static let recorderTimerIntervalMillis: Int = 500
    
    // Window width (never changes)
    static let windowWidth: CGFloat = 480
    static let minPlaylistWidth: CGFloat = 480
    static let minPlaylistHeight: CGFloat = 180
 
    // Window heights for different views
    static let windowHeight_compact: CGFloat = 230
    static let windowHeight_playlistAndEffects: CGFloat = 408
    static let windowHeight_playlistOnly: CGFloat = 218
    static let windowHeight_effectsOnly: CGFloat = 420
    
    // Angles used to fill gradients
    static let verticalGradientDegrees: CGFloat = -90.0
    static let horizontalGradientDegrees: CGFloat = -180.0
    
    // Time intervals for which feedback labels or views that are to be auto-hidden are displayed, before being hidden
    static let feedbackLabelAutoHideIntervalSeconds: TimeInterval = 1
    static let favoritesPopupAutoHideIntervalSeconds: TimeInterval = 1.5
    
    // Maximum time gap between scroll events for them to be considered as being part of the same scroll session
    static let scrollSessionMaxTimeGapSeconds: TimeInterval = (1/6)
}
