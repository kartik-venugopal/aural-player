//
//  Images.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Container for images used by the UI
*/
import Cocoa

struct Images {
    
    static let imgPlayingArt: NSImage = NSImage(named: "PlayingArt")!
    
    static let imgPlayingTrack: NSImage = NSImage(named: "PlayingTrack")!
    
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
    
    static let imgLoopOff: NSImage = NSImage(named: "LoopOff")!
    static let imgLoopStarted: NSImage = NSImage(named: "LoopStarted")!
    static let imgLoopComplete: NSImage = NSImage(named: "LoopComplete")!
    
    static let imgSwitch: NSImage = NSImage(named: "Switch")!
    
    static let imgHistory_playlist_padded: NSImage = NSImage(named: "History_PaddedPlaylist")!
    
    // Displayed in the playlist view
    static let imgGroup: NSImage = NSImage(named: "Group")!
    
    // Displayed in the History menu
    static let imgGroup_menu: NSImage = NSImage(named: "Group-Menu")!
    
    // Images displayed in alerts
    static let imgWarning: NSImage = NSImage(named: "Warning")!
    static let imgError: NSImage = NSImage(named: "Error")!
    
    static let imgPlayedTrack: NSImage = NSImage(named: "PlayedTrack")!
    
    static let imgPlayerPreview: NSImage = NSImage(named: "PlayerPreview")!
    static let imgPlaylistPreview: NSImage = NSImage(named: "PlaylistView-On")!
    static let imgEffectsPreview: NSImage = NSImage(named: "EffectsView-On")!
    
    static let imgDisclosure_collapsed: NSImage = NSImage(named: "DisclosureTriangle-Collapsed")!
    static let imgDisclosure_expanded: NSImage = NSImage(named: "DisclosureTriangle-Expanded")!
}
