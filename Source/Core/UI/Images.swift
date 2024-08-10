//
//  Images.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Container for images used by the UI
*/

import AppKit

extension NSImage {
    
    convenience init(systemSymbolName: String) {
        self.init(systemSymbolName: systemSymbolName, accessibilityDescription: nil)!
    }
    
    static let imgPlayQueueTableView: NSImage = NSImage(systemSymbolName: "list.dash")
    static let imgPlayQueueExpandedView: NSImage = NSImage(systemSymbolName: "text.below.photo.rtl")
    
    static let imgPlayQueue: NSImage = imgPlayQueueTableView
    static let imgEffects: NSImage = NSImage(systemSymbolName: "slider.vertical.3")
//    static let imgLibrary: NSImage = NSImage(named: "Library")!
    static let imgPlaylist: NSImage = NSImage(systemSymbolName: "list.dash")
    
//    static let imgPlay: NSImage = NSImage(named: "Play")!
    static let imgPlay: NSImage = NSImage(systemSymbolName: "play")
    static let imgPlayFilled: NSImage = NSImage(systemSymbolName: "play.fill")
    
    static let imgPause: NSImage = NSImage(named: "Pause")!
    
    static let imgChecked: NSImage = NSImage(named: "Checked")!
    static let imgNotChecked: NSImage = NSImage(named: "NotChecked")!
    
    static let imgInfo: NSImage = NSImage(systemSymbolName: "info")
    
    static let imgPlayingArt: NSImage = NSImage(systemSymbolName: "music.quarternote.3")
    
    static let imgFavorite: NSImage = NSImage(systemSymbolName: "heart")
    static let imgBookmark: NSImage = NSImage(systemSymbolName: "bookmark")
    
    static let imgVolumeZero: NSImage = NSImage(systemSymbolName: "volume")
    static let imgVolumeLow: NSImage = NSImage(systemSymbolName: "speaker.wave.1")
    static let imgVolumeMedium: NSImage = NSImage(systemSymbolName: "speaker.wave.2")
    static let imgVolumeHigh: NSImage = NSImage(systemSymbolName: "speaker.wave.3")
    static let imgMute: NSImage = NSImage(systemSymbolName: "volume.slash")
    
    static let imgRepeatOne: NSImage = NSImage(systemSymbolName: "repeat.1")
    static let imgRepeat: NSImage = NSImage(systemSymbolName: "repeat")
    
    static let imgShuffle: NSImage = NSImage(systemSymbolName: "shuffle")
    
    static let imgLoop: NSImage = NSImage(named: "Loop")!
    static let imgLoopStarted: NSImage = NSImage(named: "LoopStarted")!
    
    static let imgSwitch: NSImage = NSImage(systemSymbolName: "power")
    
    static let imgRememberSettings: NSImage = NSImage(systemSymbolName: "clock.arrow.2.circlepath")
    
    static let imgHistory: NSImage = NSImage(systemSymbolName: "clock")
    
    // Displayed in the playlist view
    static let imgGroup: NSImage = NSImage(named: "Group")!
    
    // Displayed in the History menu
    static let imgGroup_menu: NSImage = NSImage(named: "Group-Menu")!
    
    // Images displayed in alerts
    static let imgWarning: NSImage = NSImage(named: "Warning")!
    static let imgError: NSImage = NSImage(named: "Error")!
    
    static let imgPlayedTrack: NSImage = NSImage(systemSymbolName: "music.quarternote.3")
    
    static let imgGreenCheck: NSImage = NSImage(named: "GreenCheck")!
    
    // --------------- Device type icons -------------------
    
    static let imgDeviceType_builtIn: NSImage = NSImage(systemSymbolName: "speaker.wave.2.fill")
    static let imgDeviceType_headphones: NSImage = NSImage(systemSymbolName: "headphones")
    static let imgDeviceType_bluetooth: NSImage = NSImage(named: "DeviceType_Bluetooth")!
    static let imgDeviceType_displayPort: NSImage = NSImage(named: "DeviceType_DisplayPort")!
    static let imgDeviceType_hdmi: NSImage = NSImage(named: "DeviceType_HDMI")!
    static let imgDeviceType_usb: NSImage = NSImage(named: "DeviceType_USB")!
    static let imgDeviceType_pci: NSImage = NSImage(named: "DeviceType_PCI")!
    static let imgDeviceType_firewire: NSImage = NSImage(named: "DeviceType_FireWire")!
    static let imgDeviceType_thunderbolt: NSImage = NSImage(named: "DeviceType_Thunderbolt")!
    static let imgDeviceType_virtual: NSImage = NSImage(systemSymbolName: "waveform")
    static let imgDeviceType_airplay: NSImage = NSImage(systemSymbolName: "airplayaudio")
    static let imgDeviceType_aggregate: NSImage = NSImage(named: "DeviceType_Aggregate")!
    static let imgDeviceType_avb: NSImage = NSImage(named: "DeviceType_AVB")!
    
    // --------------- Playlist group icons -----------------
    
    static let imgTracks: NSImage = NSImage(named: "Tracks")!
    static let imgArtistGroup: NSImage = NSImage(named: "Artists")!
    static let imgAlbumGroup: NSImage = NSImage(named: "Albums")!
    static let imgGenreGroup: NSImage = NSImage(named: "Genres")!
    static let imgDecadeGroup: NSImage = NSImage(systemSymbolName: "calendar")
    static let imgFileSystem: NSImage = NSImage(systemSymbolName: "folder")
    
    static let imgArtistGroup_menu: NSImage = NSImage(named: "Artists_Menu")!
    static let imgAlbumGroup_menu: NSImage = NSImage(named: "Albums_Menu")!
    
    // --------------- Effects Unit icons -----------------

    static let imgMasterUnit: NSImage = NSImage(systemSymbolName: "powerplug.fill")
    static let imgEQUnit: NSImage = NSImage(systemSymbolName: "slider.vertical.3")
    static let imgPitchShiftUnit: NSImage = NSImage(systemSymbolName: "waveform.path.ecg")
    static let imgTimeStretchUnit: NSImage = NSImage(systemSymbolName: "timer")
    static let imgReverbUnit: NSImage = NSImage(named: "ReverbTab")!
    static let imgDelayUnit: NSImage = NSImage(named: "DelayTab")!
    static let imgFilterUnit: NSImage = NSImage(named: "FilterTab")!
    static let imgAudioUnit: NSImage = NSImage(named: "AUTab")!
    
    static let imgWaveform: NSImage = NSImage(systemSymbolName: "waveform")
}
