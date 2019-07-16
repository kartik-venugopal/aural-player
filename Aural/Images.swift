/*
    Container for images used by the UI
*/
import Cocoa

struct Images {
    
    struct WindowControls {
        
        private static let imgClose_0: NSImage = NSImage(named: "Close")!
        private static let imgClose_1: NSImage = NSImage(named: "Close_1")!
        
        private static let imgHide_0: NSImage = NSImage(named: "Hide")!
        private static let imgHide_1: NSImage = NSImage(named: "Hide_1")!
        
        static var imgClose: NSImage {
            
            switch Colors.scheme {
                
            case .darkBackground_lightText:     return imgClose_0
                
            case .lightBackground_darkText:     return imgClose_1
                
            }
        }
        
        static var imgHide: NSImage {
            
            switch Colors.scheme {
                
            case .darkBackground_lightText:     return imgHide_0
                
            case .lightBackground_darkText:     return imgHide_1
                
            }
        }
    }
    
    // Toggled images
    static var imgPlay: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgPlay_0
            
        case .lightBackground_darkText:     return imgPlay_1
            
        }
    }
    
    private static let imgPlay_0: NSImage = NSImage(named: "Play")!
    private static let imgPlay_1: NSImage = NSImage(named: "Play_1")!
    
    static let imgPause: NSImage = NSImage(named: "Pause")!
    
    static let imgPlayingArt: NSImage = NSImage(named: "PlayingArt")!
    
    static let imgPlayingTrack: NSImage = NSImage(named: "PlayingTrack")!
    static let imgTranscodingTrack: NSImage = NSImage(named: "TranscodingTrack")!
    static let imgWaitingTrack: NSImage = NSImage(named: "WaitingTrack")!
    
    static var imgVolumeZero: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgVolumeZero_0
            
        case .lightBackground_darkText:     return imgVolumeZero_1
            
        }
    }
    
    private static let imgVolumeZero_0: NSImage = NSImage(named: "VolumeZero")!
    private static let imgVolumeZero_1: NSImage = NSImage(named: "VolumeZero_1")!
    
    static var imgVolumeLow: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgVolumeLow_0
            
        case .lightBackground_darkText:     return imgVolumeLow_1
            
        }
    }
    
    private static let imgVolumeLow_0: NSImage = NSImage(named: "VolumeLow")!
    private static let imgVolumeLow_1: NSImage = NSImage(named: "VolumeLow_1")!
    
    static var imgVolumeMedium: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgVolumeMedium_0
            
        case .lightBackground_darkText:     return imgVolumeMedium_1
            
        }
    }
    
    private static let imgVolumeMedium_0: NSImage = NSImage(named: "VolumeMedium")!
    private static let imgVolumeMedium_1: NSImage = NSImage(named: "VolumeMedium_1")!
    
    static var imgVolumeHigh: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgVolumeHigh_0
            
        case .lightBackground_darkText:     return imgVolumeHigh_1
            
        }
    }
    
    private static let imgVolumeHigh_0: NSImage = NSImage(named: "VolumeHigh")!
    private static let imgVolumeHigh_1: NSImage = NSImage(named: "VolumeHigh_1")!
    
    static var imgMute: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgMute_0
            
        case .lightBackground_darkText:     return imgMute_1
            
        }
    }
    
    private static let imgMute_0: NSImage = NSImage(named: "Mute")!
    private static let imgMute_1: NSImage = NSImage(named: "Mute_1")!
    
    static let imgRepeatOff: NSImage = NSImage(named: "RepeatOff")!
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
