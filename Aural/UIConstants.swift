/*
    A collection of constants for use by the UI
*/
import Cocoa

class UIConstants {
    
    // Y co-ordinates for the Track Name label, depending on whether it is displaying one or two lines of text
    static let trackNameLabelLocationY_oneLine: CGFloat = 23
    static let trackNameLabelLocationY_twoLines: CGFloat = 33
    
    // Playlist view column identifiers
    static let trackNameColumnID: String = "cv_trackName"
    static let durationColumnID: String = "cv_duration"
    
    // Track info view column identifiers (popover)
    static let trackInfoKeyColumnID: String = "cv_trackInfoKey"
    static let trackInfoValueColumnID: String = "cv_trackInfoValue"
    
    // Index set used to reload specific playlist rows
    static let playlistViewColumnIndexes: IndexSet = IndexSet([0,1])
    
    // Toggled images
    static let imgPlay: NSImage = NSImage(named: "Play")!
    static let imgPause: NSImage = NSImage(named: "Pause")!
    
    static let imgRecord: NSImage = NSImage(named: "Record")!
    static let imgRecorderStop: NSImage = NSImage(named: "RecorderStop")!

    static let imgVolumeZero: NSImage = NSImage(named: "VolumeZero")!
    static let imgVolumeLow: NSImage = NSImage(named: "VolumeLow")!
    static let imgVolumeMedium: NSImage = NSImage(named: "VolumeMedium")!
    static let imgVolumeHigh: NSImage = NSImage(named: "VolumeHigh")!
    static let imgMute: NSImage = NSImage(named: "Mute")!
    
    static let imgRepeatOff: NSImage = NSImage(named: "RepeatOff")!
    static let imgRepeatOne: NSImage = NSImage(named: "RepeatOne")!
    static let imgRepeatAll: NSImage = NSImage(named: "RepeatAll")!
    
    static let imgShuffleOff: NSImage = NSImage(named: "ShuffleOff")!
    static let imgShuffleOn: NSImage = NSImage(named: "ShuffleOn")!

    static let imgSwitchOff: NSImage = NSImage(named: "SwitchOff")!
    static let imgSwitchOn: NSImage = NSImage(named: "SwitchOn")!
    
    static let imgMusicArt: NSImage = NSImage(named: "MusicArt")!
    
    static let imgPlaylistOn: NSImage = NSImage(named: "PlaylistView-On")!
    static let imgPlaylistOff: NSImage = NSImage(named: "PlaylistView-Off")!
    static let imgEffectsOn: NSImage = NSImage(named: "EffectsView-On")!
    static let imgEffectsOff: NSImage = NSImage(named: "EffectsView-Off")!
    
    // Images displayed in alerts
    static let imgWarning: NSImage = NSImage(named: "Warning")!
    static let imgError: NSImage = NSImage(named: "Error")!
    
    private static let gillSans12Font: NSFont = NSFont(name: "Gill Sans", size: 12)!
    private static let gillSans13Font: NSFont = NSFont(name: "Gill Sans", size: 13)!
    private static let gillSans12LightFont: NSFont = NSFont(name: "Gill Sans Light", size: 12)!
    private static let gillSans13LightFont: NSFont = NSFont(name: "Gill Sans Light", size: 13)!
    
    // Fonts used by the playlist view
    static let playlistSelectedTextFont: NSFont = gillSans12Font
    static let playlistTextFont: NSFont = gillSans12LightFont
    
    // Font used by the effects tab view buttons
    static let tabViewButtonFont: NSFont = gillSans12Font
    
    // Font used by modal dialog buttons
    static let modalDialogButtonFont: NSFont = gillSans12Font
    
    // Font used by the search modal dialog navigation buttons
    static let modalDialogNavButtonFont: NSFont = NSFont(name: "Gill Sans Bold", size: 12)!
    
    // Font used by modal dialog check and radio buttons
    static let checkRadioButtonFont: NSFont = NSFont(name: "Gill Sans", size: 11)!
    
    // Fonts used by the track info popover view (key column and view column)
    static let popoverKeyFont: NSFont = gillSans13Font
    static let popoverValueFont: NSFont = gillSans13LightFont
    
    // Font used by the popup menus
    static let popupMenuFont: NSFont = NSFont(name: "Gill Sans", size: 10)!
    
    // Default value for the label that shows a track's seek position
    static let zeroDurationString: String = "0:00"
    
    // Values used to determine the row height of table rows in the detailed track info popover view
    static let trackInfoKeyColumnWidth: CGFloat = 125
    static let trackInfoValueColumnWidth: CGFloat = 315
    
    // Default seek timer interval (milliseconds)
    static let seekTimerIntervalMillis: Int = 500
    
    // Recorder timer interval (milliseconds)
    static let recorderTimerIntervalMillis: Int = 500
    
    // Window width (never changes)
    static let windowWidth: CGFloat = 415
    static let minPlaylistWidth: CGFloat = 415
    static let minPlaylistHeight: CGFloat = 150
 
    // Window heights for different views
    static let windowHeight_compact: CGFloat = 208
    static let windowHeight_playlistAndEffects: CGFloat = 381
    static let windowHeight_playlistOnly: CGFloat = 196
    static let windowHeight_effectsOnly: CGFloat = 393
    
    // Angle used to fill vertical gradients
    static let verticalGradientDegrees: CGFloat = -90.0
    
    // Time interval for which feedback labels that are to be auto-hidden are displayed, before being hidden
    static let feedbackLabelAutoHideIntervalSeconds: TimeInterval = 1
}
