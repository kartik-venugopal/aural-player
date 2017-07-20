/*
    A collection of constants for use by the UI
*/

import AppKit

class UIConstants {
    
    // Toggled images
    static let imgPlay: NSImage = NSImage(named: "Play")!
    static let imgPause: NSImage = NSImage(named: "Pause")!

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
    static let boldFont: NSFont = NSFont(name: "Gill Sans", size: 13.5)!
    static let regularFont: NSFont = NSFont(name: "Gill Sans Light", size: 13.5)!
    
    static let popoverValueFont: NSFont = NSFont(name: "Gill Sans Light", size: 13)!
    
    // Fonts used by the reverb popup menu
    static let reverbMenuFont: NSFont = NSFont(name: "Gill Sans", size: 11)!
    
    // Overall UI color scheme
    static let colorScheme: ColorSchemes = ColorSchemes.gray
    
    // For the label that shows a track's playback position
    static let zeroDurationString: String = "0:00"
    
    static let trackInfoValueColumnWidth: CGFloat = 340
    static let trackInfoValueRowHeight: CGFloat = 26
    static let trackInfoLongValueRowHeight: CGFloat = 1.75 * trackInfoValueRowHeight
    static let trackInfoLongValueRowHeightMultiplier: CGFloat = 0.9
    
    // Seek timer interval (milliseconds)
    static let seekTimerIntervalMillis: Int = 500
    
    // Default user's music directory (default place to look in, when opening/saving files)
    static let musicDirURL: URL = URL(fileURLWithPath: NSHomeDirectory() + "/Music")
}
