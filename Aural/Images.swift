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
    
    static var imgPlayingArt: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgPlayingArt_0
            
        case .lightBackground_darkText:     return imgPlayingArt_1
            
        }
    }
    
    private static let imgPlayingArt_0: NSImage = NSImage(named: "PlayingArt")!
    private static let imgPlayingArt_1: NSImage = NSImage(named: "PlayingArt_1")!
    
    static var imgPlayingTrack: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgPlayingTrack_0
            
        case .lightBackground_darkText:     return imgPlayingTrack_1
            
        }
    }
    
    private static let imgPlayingTrack_0: NSImage = NSImage(named: "PlayingTrack")!
    private static let imgPlayingTrack_1: NSImage = NSImage(named: "PlayingTrack_1")!
    
    static var imgTranscodingTrack: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgTranscodingTrack_0
            
        case .lightBackground_darkText:     return imgTranscodingTrack_1
            
        }
    }
    
    private static let imgTranscodingTrack_0: NSImage = NSImage(named: "TranscodingTrack")!
    private static let imgTranscodingTrack_1: NSImage = NSImage(named: "TranscodingTrack_1")!
    
    static var imgWaitingTrack: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgWaitingTrack_0
            
        case .lightBackground_darkText:     return imgWaitingTrack_1
            
        }
    }
    
    private static let imgWaitingTrack_0: NSImage = NSImage(named: "WaitingTrack")!
    private static let imgWaitingTrack_1: NSImage = NSImage(named: "WaitingTrack_1")!
    
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
    
    static var imgRepeatOff: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgRepeatOff_0
            
        case .lightBackground_darkText:     return imgRepeatOff_1
            
        }
    }
    
    private static let imgRepeatOff_0: NSImage = NSImage(named: "RepeatOff")!
    private static let imgRepeatOff_1: NSImage = NSImage(named: "RepeatOff_1")!
    
    static var imgRepeatOne: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgRepeatOne_0
            
        case .lightBackground_darkText:     return imgRepeatOne_1
            
        }
    }
    
    private static let imgRepeatOne_0: NSImage = NSImage(named: "RepeatOne")!
    private static let imgRepeatOne_1: NSImage = NSImage(named: "RepeatOne_1")!
    
    static var imgRepeatAll: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgRepeatAll_0
            
        case .lightBackground_darkText:     return imgRepeatAll_1
            
        }
    }
    
    private static let imgRepeatAll_0: NSImage = NSImage(named: "RepeatAll")!
    private static let imgRepeatAll_1: NSImage = NSImage(named: "RepeatAll_1")!
    
    static var imgShuffleOff: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgShuffleOff_0
            
        case .lightBackground_darkText:     return imgShuffleOff_1
            
        }
    }
    
    private static let imgShuffleOff_0: NSImage = NSImage(named: "ShuffleOff")!
    private static let imgShuffleOff_1: NSImage = NSImage(named: "ShuffleOff_1")!
    
    static var imgShuffleOn: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgShuffleOn_0
            
        case .lightBackground_darkText:     return imgShuffleOn_1
            
        }
    }
    
    static let imgShuffleOn_0: NSImage = NSImage(named: "ShuffleOn")!
    static let imgShuffleOn_1: NSImage = NSImage(named: "ShuffleOn_1")!
    
    static var imgLoopOff: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgLoopOff_0
            
        case .lightBackground_darkText:     return imgLoopOff_1
            
        }
    }
    
    private static let imgLoopOff_0: NSImage = NSImage(named: "LoopOff")!
    private static let imgLoopOff_1: NSImage = NSImage(named: "LoopOff_1")!
    
    static var imgLoopStarted: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgLoopStarted_0
            
        case .lightBackground_darkText:     return imgLoopStarted_1
            
        }
    }
    
    private static let imgLoopStarted_0: NSImage = NSImage(named: "LoopStarted")!
    private static let imgLoopStarted_1: NSImage = NSImage(named: "LoopStarted_1")!
    
    static var imgLoopComplete: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgLoopComplete_0
            
        case .lightBackground_darkText:     return imgLoopComplete_1
            
        }
    }
    
    private static let imgLoopComplete_0: NSImage = NSImage(named: "LoopComplete")!
    private static let imgLoopComplete_1: NSImage = NSImage(named: "LoopComplete_1")!
    
    static var imgSwitchOff: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgSwitchOff_0
            
        case .lightBackground_darkText:     return imgSwitchOff_1
            
        }
    }
    
    private static let imgSwitchOff_0: NSImage = NSImage(named: "SwitchOff")!
    private static let imgSwitchOff_1: NSImage = NSImage(named: "SwitchOff_1")!
    
    static var imgSwitchOn: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgSwitchOn_0
            
        case .lightBackground_darkText:     return imgSwitchOn_1
            
        }
    }
    
    private static let imgSwitchOn_0: NSImage = NSImage(named: "SwitchOn")!
    private static let imgSwitchOn_1: NSImage = NSImage(named: "SwitchOn_1")!
    
    static var imgSwitchMixed: NSImage {
        
        switch Colors.scheme {
            
        case .darkBackground_lightText:     return imgSwitchMixed_0
            
        case .lightBackground_darkText:     return imgSwitchMixed_1
            
        }
    }
    
    private static let imgSwitchMixed_0: NSImage = NSImage(named: "SwitchMixed")!
    private static let imgSwitchMixed_1: NSImage = NSImage(named: "SwitchMixed_1")!
    
    static let imgPlaylistOn: NSImage = NSImage(named: "PlaylistView-On")!
    static let imgPlaylistOff: NSImage = NSImage(named: "PlaylistView-Off")!
    
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
