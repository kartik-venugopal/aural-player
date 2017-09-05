/*
    A collection of constants for use by the UI
*/

import AppKit

class UIConstants {
    
    // Playlist view column identifiers
    static let trackNameColumnID: String = "cv_trackName"
    static let durationColumnID: String = "cv_duration"
    
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
    
    // Fonts used by the playlist view
    static let playlistBoldFont: NSFont = NSFont(name: "Gill Sans", size: 13.5)!
    static let playlistRegularFont: NSFont = NSFont(name: "Gill Sans Light", size: 13.5)!
    
    // Fonts used by the effects tab view buttons
    static let tabViewButtonFont: NSFont = NSFont(name: "Gill Sans", size: 12)!
    
    // Fonts used by the search/sort modal dialog done/cancel buttons
    static let modalDialogButtonFont: NSFont = NSFont(name: "Gill Sans", size: 12)!
    
    // Fonts used by the search/sort modal dialog navigation buttons
    static let modalDialogNavButtonFont: NSFont = NSFont(name: "Gill Sans Bold", size: 12)!
    
    // Fonts used by the search/sort modal dialog check and radio buttons
    static let checkRadioButtonFont: NSFont = NSFont(name: "Gill Sans", size: 11)!
    
    static let popoverValueFont: NSFont = NSFont(name: "Gill Sans Light", size: 13)!
    
    // Fonts used by the popup menus
    static let popupMenuFont: NSFont = NSFont(name: "Gill Sans", size: 10)!
    
    // For the label that shows a track's playback position
    static let zeroDurationString: String = "0:00"
    
    // Values used to determine the row height of table rows in the detailed track info popover view
    static let trackInfoValueColumnWidth: CGFloat = 340
    static let trackInfoValueRowHeight: CGFloat = 26
    static let trackInfoLongValueRowHeight: CGFloat = 1.75 * trackInfoValueRowHeight
    static let trackInfoLongValueRowHeightMultiplier: CGFloat = 0.9
    
    // Seek timer interval (milliseconds)
    static let seekTimerIntervalMillis: Int = 500
    
    // Recorder timer interval (milliseconds)
    static let recorderTimerIntervalMillis: Int = 500
    
    // Spacing between collapsible views
    static let collapsibleViewSpacing: CGFloat = 12
    
    // Window width never changes
    static let windowWidth: CGFloat = 415
 
    // Window heights for different views
    static let windowHeight_compact: CGFloat = 223
    static let windowHeight_playlistAndEffects: CGFloat = 629
    static let windowHeight_playlistOnly: CGFloat = 443
    static let windowHeight_effectsOnly: CGFloat = 411
}
