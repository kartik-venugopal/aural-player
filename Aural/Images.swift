/*
    Container for images used by the UI
*/
import Cocoa

struct Images {
    
    // Toggled images
    static let imgPlay: NSImage = NSImage(named: "Play")!
    static let imgPause: NSImage = NSImage(named: "Pause")!
    
    static let imgPlayingArt: NSImage = NSImage(named: "PlayingArt")!
    
    static let imgPlayingTrack: NSImage = NSImage(named: "PlayingTrack")!
    static let imgTranscodingTrack: NSImage = NSImage(named: "TranscodingTrack")!
    static let imgWaitingTrack: NSImage = NSImage(named: "WaitingTrack")!
    
    static let imgVolumeZero: NSImage = NSImage(named: "VolumeZero")!
    static let imgVolumeLow: NSImage = NSImage(named: "VolumeLow")!
    static let imgVolumeMedium: NSImage = NSImage(named: "VolumeMedium")!
    static let imgVolumeHigh: NSImage = NSImage(named: "VolumeHigh")!
    static let imgMute: NSImage = NSImage(named: "Mute")!
    
    static let imgRepeatOff: NSImage = NSImage(named: "RepeatOff")!
    static let imgRepeatOn: NSImage = NSImage(named: "RepeatOn")!
    static let imgRepeatOne: NSImage = NSImage(named: "RepeatOne")!
    static let imgRepeatAll: NSImage = NSImage(named: "RepeatAll")!
    
    static let imgShuffleOff: NSImage = NSImage(named: "ShuffleOff")!
    static let imgShuffleOn: NSImage = NSImage(named: "ShuffleOn")!
    
    static let imgLoopOff: NSImage = NSImage(named: "LoopOff")!
    static let imgLoopStarted: NSImage = NSImage(named: "LoopStarted")!
    static let imgLoopComplete: NSImage = NSImage(named: "LoopComplete")!
    
    static let imgSwitchOff: NSImage = NSImage(named: "SwitchOff")!
    static let imgSwitchOn: NSImage = NSImage(named: "SwitchOn")!
    static let imgSwitchMixed: NSImage = NSImage(named: "SwitchMixed")!
    
    static let imgPlaylistOn: NSImage = NSImage(named: "PlaylistView-On")!
    static let imgPlaylistOff: NSImage = NSImage(named: "PlaylistView-Off")!
    static let imgPlaylist_padded: NSImage = NSImage(named: "Playlist-Padded")!
    
    static let imgHistory_playlist_padded: NSImage = NSImage(named: "History_PaddedPlaylist")!
    
    // Displayed in the playlist view
    static let imgGroup: NSImage = NSImage(named: "Group")!
    static let imgGroup_noPadding: NSImage = NSImage(named: "Group-NoPadding")!
    
    // Images displayed in alerts
    static let imgWarning: NSImage = NSImage(named: "Warning")!
    static let imgError: NSImage = NSImage(named: "Error")!
    
    static let imgPlayedTrack: NSImage = NSImage(named: "PlayedTrack")!
    static let imgPlayedTrackMissing: NSImage = NSImage(named: "PlayedTrack-Missing")!
    
    static let historyMenuItemImageSize: NSSize = NSSize(width: 22, height: 22)
    
    static let imgPlayerPreview: NSImage = NSImage(named: "PlayerPreview")!
    static let imgEffectsPreview: NSImage = NSImage(named: "EffectsView-On")!
}
