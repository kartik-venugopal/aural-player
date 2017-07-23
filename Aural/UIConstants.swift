/*
    A collection of constants for use by the UI
*/

import AppKit

class UIConstants {
    
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
    
    // Fonts used by the playlist view
    static let playlistBoldFont: NSFont = NSFont(name: "Gill Sans", size: 13.5)!
    static let playlistRegularFont: NSFont = NSFont(name: "Gill Sans Light", size: 13.5)!
    
    static let popoverValueFont: NSFont = NSFont(name: "Gill Sans Light", size: 13)!
    
    // Fonts used by the popup menus
    static let popupMenuFont: NSFont = NSFont(name: "Gill Sans", size: 10)!
    
    // Overall UI color scheme
    static let colorScheme: ColorSchemes = ColorSchemes.gray
    
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
 
    // Window heights for different views
    static let windowHeight_compact: CGFloat = 223
    static let windowHeight_playlistAndEffects: CGFloat = 622
    static let windowHeight_playlistOnly: CGFloat = 436
    static let windowHeight_effectsOnly: CGFloat = 411
}
