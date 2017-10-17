/*
    A collection of constants for use by the UI
*/
import Cocoa

class UIConstants {
    
    // Y co-ordinates for the Track Name label, depending on whether it is displaying one or two lines of text
    static let trackNameLabelLocationY_oneLine: CGFloat = 38
    static let trackNameLabelLocationY_twoLines: CGFloat = 33
    
    // Height values for the Track Name label, depending on whether it is displaying one or two lines of text
    static let trackNameLabelHeight_oneLine: CGFloat = 30
    static let trackNameLabelHeight_twoLines: CGFloat = 45
    
    // Playlist view column identifiers
    static let trackIndexColumnID: String = "cv_trackIndex"
    static let trackNameColumnID: String = "cv_trackName"
    static let durationColumnID: String = "cv_duration"
    
    // Track info view column identifiers (popover)
    static let trackInfoKeyColumnID: String = "cv_trackInfoKey"
    static let trackInfoValueColumnID: String = "cv_trackInfoValue"
    
    // Index set used to reload specific playlist rows
    static let playlistViewColumnIndexes: IndexSet = IndexSet([0, 1, 2])
    
    // Animation displayed in playlist to mark the currently playing track
    static let imgPlayingTrack: NSImage = NSImage(byReferencing: URL(fileURLWithPath: Bundle.main.path(forResource: "playingTrack", ofType: "gif")!))
    
    // Animation displayed in the Now Playing art image view (for track artwork)
    static let imgPlayingArt: NSImage = NSImage(byReferencing: URL(fileURLWithPath: Bundle.main.path(forResource: "playingArt", ofType: "gif")!))
    
    // Toggled images
    static let imgPlay: NSImage = NSImage(named: NSImage.Name(rawValue: "Play"))!
    static let imgPause: NSImage = NSImage(named: NSImage.Name(rawValue: "Pause"))!
    
    static let imgRecord: NSImage = NSImage(named: NSImage.Name(rawValue: "Record"))!
    static let imgRecorderStop: NSImage = NSImage(named: NSImage.Name(rawValue: "RecorderStop"))!

    static let imgVolumeZero: NSImage = NSImage(named: NSImage.Name(rawValue: "VolumeZero"))!
    static let imgVolumeLow: NSImage = NSImage(named: NSImage.Name(rawValue: "VolumeLow"))!
    static let imgVolumeMedium: NSImage = NSImage(named: NSImage.Name(rawValue: "VolumeMedium"))!
    static let imgVolumeHigh: NSImage = NSImage(named: NSImage.Name(rawValue: "VolumeHigh"))!
    static let imgMute: NSImage = NSImage(named: NSImage.Name(rawValue: "Mute"))!
    
    static let imgRepeatOff: NSImage = NSImage(named: NSImage.Name(rawValue: "RepeatOff"))!
    static let imgRepeatOne: NSImage = NSImage(named: NSImage.Name(rawValue: "RepeatOne"))!
    static let imgRepeatAll: NSImage = NSImage(named: NSImage.Name(rawValue: "RepeatAll"))!
    
    static let imgShuffleOff: NSImage = NSImage(named: NSImage.Name(rawValue: "ShuffleOff"))!
    static let imgShuffleOn: NSImage = NSImage(named: NSImage.Name(rawValue: "ShuffleOn"))!

    static let imgSwitchOff: NSImage = NSImage(named: NSImage.Name(rawValue: "SwitchOff"))!
    static let imgSwitchOn: NSImage = NSImage(named: NSImage.Name(rawValue: "SwitchOn"))!
    
    static let imgPlaylistOn: NSImage = NSImage(named: NSImage.Name(rawValue: "PlaylistView-On"))!
    static let imgPlaylistOff: NSImage = NSImage(named: NSImage.Name(rawValue: "PlaylistView-Off"))!
    static let imgEffectsOn: NSImage = NSImage(named: NSImage.Name(rawValue: "EffectsView-On"))!
    static let imgEffectsOff: NSImage = NSImage(named: NSImage.Name(rawValue: "EffectsView-Off"))!
    
    // Images displayed in alerts
    static let imgWarning: NSImage = NSImage(named: NSImage.Name(rawValue: "Warning"))!
    static let imgError: NSImage = NSImage(named: NSImage.Name(rawValue: "Error"))!
    
    private static let gillSans12LightFont: NSFont = NSFont(name: "Gill Sans Light", size: 12)!
    private static let gillSans12Font: NSFont = NSFont(name: "Gill Sans", size: 12)!
    private static let gillSans12SemiBoldFont: NSFont = NSFont(name: "Gill Sans Semibold", size: 12)!
    private static let gillSans12BoldFont: NSFont = NSFont(name: "Gill Sans Bold", size: 12)!
    
    private static let gillSans13Font: NSFont = NSFont(name: "Gill Sans", size: 13)!
    private static let gillSans13LightFont: NSFont = NSFont(name: "Gill Sans Light", size: 13)!
    
    // Fonts used by the playlist view
    static let playlistSelectedTextFont: NSFont = gillSans12Font
    static let playlistTextFont: NSFont = gillSans12LightFont
    
    // Font used by the effects tab view buttons
    static let tabViewButtonFont: NSFont = gillSans12Font
    static let tabViewButtonBoldFont: NSFont = gillSans12SemiBoldFont
    
    // Font used by modal dialog buttons
    static let modalDialogButtonFont: NSFont = gillSans12Font
    
    // Font used by the search modal dialog navigation buttons
    static let modalDialogNavButtonFont: NSFont = gillSans12BoldFont
    
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
