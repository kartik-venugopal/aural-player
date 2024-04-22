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

import Foundation

extension PlatformImage {
    
    static let imgPlayQueueTableView: PlatformImage = PlatformImage(systemSymbolName: "list.dash", accessibilityDescription: nil)!
    static let imgPlayQueueExpandedView: PlatformImage = PlatformImage(systemSymbolName: "text.below.photo.rtl", accessibilityDescription: nil)!
    
    static let imgPlayQueue: PlatformImage = PlatformImage(named: "PlayQueue")!
    static let imgEffects: PlatformImage = PlatformImage(systemSymbolName: "slider.vertical.3", accessibilityDescription: nil)!
    static let imgLibrary: PlatformImage = PlatformImage(named: "Library")!
    static let imgPlaylist: PlatformImage = PlatformImage(systemSymbolName: "list.dash", accessibilityDescription: nil)!
    
    static let imgPlay: PlatformImage = PlatformImage(named: "Play")!
    static let imgPlayFilled: PlatformImage = PlatformImage(systemSymbolName: "play.fill", accessibilityDescription: nil)!
    
    static let imgPause: PlatformImage = PlatformImage(named: "Pause")!
    
    static let imgChecked: PlatformImage = PlatformImage(named: "Checked")!
    static let imgNotChecked: PlatformImage = PlatformImage(named: "NotChecked")!
    
    static let imgPlayingArt: PlatformImage = PlatformImage(systemSymbolName: "music.quarternote.3", accessibilityDescription: nil)!
    
    static let imgSave: PlatformImage = PlatformImage(named: "Save")!
    
    static let imgFavorite: PlatformImage = PlatformImage(systemSymbolName: "heart", accessibilityDescription: nil)!
    static let imgBookmark: PlatformImage = PlatformImage(systemSymbolName: "bookmark", accessibilityDescription: nil)!
    
    static let imgVolumeZero: PlatformImage = PlatformImage(systemSymbolName: "volume", accessibilityDescription: nil)!
    static let imgVolumeLow: PlatformImage = PlatformImage(systemSymbolName: "speaker.wave.1", accessibilityDescription: nil)!
    static let imgVolumeMedium: PlatformImage = PlatformImage(systemSymbolName: "speaker.wave.2", accessibilityDescription: nil)!
    static let imgVolumeHigh: PlatformImage = PlatformImage(systemSymbolName: "speaker.wave.3", accessibilityDescription: nil)!
    static let imgMute: PlatformImage = PlatformImage(systemSymbolName: "volume.slash", accessibilityDescription: nil)!
    
    static let imgRepeatOne: PlatformImage = PlatformImage(systemSymbolName: "repeat.1", accessibilityDescription: nil)!
    static let imgRepeat: PlatformImage = PlatformImage(systemSymbolName: "repeat", accessibilityDescription: nil)!
    
    static let imgShuffle: PlatformImage = PlatformImage(systemSymbolName: "shuffle", accessibilityDescription: nil)!
    
    static let imgLoop: PlatformImage = PlatformImage(named: "Loop")!
    static let imgLoopStarted: PlatformImage = PlatformImage(named: "LoopStarted")!
    
    static let imgSwitch: PlatformImage = PlatformImage(systemSymbolName: "power", accessibilityDescription: nil)!
    
    static let imgRememberSettings: PlatformImage = PlatformImage(systemSymbolName: "clock.arrow.2.circlepath", accessibilityDescription: nil)!
    
    static let imgHistory: PlatformImage = PlatformImage(systemSymbolName: "clock", accessibilityDescription: nil)!
    static let imgHistory_playlist_padded: PlatformImage = PlatformImage(named: "History_PaddedPlaylist")!
    
    // Displayed in the playlist view
    static let imgGroup: PlatformImage = PlatformImage(named: "Group")!
    
    // Displayed in the History menu
    static let imgGroup_menu: PlatformImage = PlatformImage(named: "Group-Menu")!
    
    // Images displayed in alerts
    static let imgWarning: PlatformImage = PlatformImage(named: "Warning")!
    static let imgError: PlatformImage = PlatformImage(named: "Error")!
    
    static let imgPlayedTrack: PlatformImage = PlatformImage(named: "PlayedTrack")!
    
    static let imgPlayerPreview: PlatformImage = PlatformImage(named: "PlayerPreview")!
    static let imgPlaylistPreview: PlatformImage = PlatformImage(named: "Playlist-Padded")!
    static let imgEffectsPreview: PlatformImage = PlatformImage(named: "EffectsView-On")!
    
    static let imgDisclosure_collapsed: PlatformImage = PlatformImage(named: "DisclosureTriangle-Collapsed")!
    static let imgDisclosure_expanded: PlatformImage = PlatformImage(named: "DisclosureTriangle-Expanded")!
    
    // --------------- Device type icons -------------------
    
    static let imgDeviceType_builtIn: PlatformImage = PlatformImage(systemSymbolName: "speaker.wave.2.fill", accessibilityDescription: nil)!
    static let imgDeviceType_headphones: PlatformImage = PlatformImage(systemSymbolName: "headphones", accessibilityDescription: nil)!
    static let imgDeviceType_bluetooth: PlatformImage = PlatformImage(named: "DeviceType_Bluetooth")!
    static let imgDeviceType_displayPort: PlatformImage = PlatformImage(named: "DeviceType_DisplayPort")!
    static let imgDeviceType_hdmi: PlatformImage = PlatformImage(named: "DeviceType_HDMI")!
    static let imgDeviceType_usb: PlatformImage = PlatformImage(named: "DeviceType_USB")!
    static let imgDeviceType_pci: PlatformImage = PlatformImage(named: "DeviceType_PCI")!
    static let imgDeviceType_firewire: PlatformImage = PlatformImage(named: "DeviceType_FireWire")!
    static let imgDeviceType_thunderbolt: PlatformImage = PlatformImage(named: "DeviceType_Thunderbolt")!
    static let imgDeviceType_virtual: PlatformImage = PlatformImage(systemSymbolName: "waveform", accessibilityDescription: nil)!
    static let imgDeviceType_airplay: PlatformImage = PlatformImage(systemSymbolName: "airplayaudio", accessibilityDescription: nil)!
    static let imgDeviceType_aggregate: PlatformImage = PlatformImage(named: "DeviceType_Aggregate")!
    static let imgDeviceType_avb: PlatformImage = PlatformImage(named: "DeviceType_AVB")!
    
    // --------------- Playlist group icons -----------------
    
    static let imgTracks: PlatformImage = PlatformImage(named: "Tracks")!
    static let imgArtistGroup: PlatformImage = PlatformImage(named: "Artists")!
    static let imgAlbumGroup: PlatformImage = PlatformImage(named: "Albums")!
    static let imgGenreGroup: PlatformImage = PlatformImage(named: "Genres")!
    static let imgDecadeGroup: PlatformImage = PlatformImage(systemSymbolName: "calendar", accessibilityDescription: nil)!
    static let imgFileSystem: PlatformImage = PlatformImage(systemSymbolName: "folder", accessibilityDescription: nil)!
    
    static let imgArtistGroup_menu: PlatformImage = PlatformImage(named: "Artists_Menu")!
    static let imgAlbumGroup_menu: PlatformImage = PlatformImage(named: "Albums_Menu")!
    
    // --------------- Effects Unit icons -----------------

    static let imgMasterUnit: PlatformImage = PlatformImage(systemSymbolName: "powerplug.fill", accessibilityDescription: nil)!
    static let imgEQUnit: PlatformImage = PlatformImage(systemSymbolName: "slider.vertical.3", accessibilityDescription: nil)!
    static let imgPitchShiftUnit: PlatformImage = PlatformImage(systemSymbolName: "waveform.path.ecg", accessibilityDescription: nil)!
    static let imgTimeStretchUnit: PlatformImage = PlatformImage(systemSymbolName: "timer", accessibilityDescription: nil)!
    static let imgReverbUnit: PlatformImage = PlatformImage(named: "ReverbTab")!
    static let imgDelayUnit: PlatformImage = PlatformImage(named: "DelayTab")!
    static let imgFilterUnit: PlatformImage = PlatformImage(named: "FilterTab")!
    static let imgAudioUnit: PlatformImage = PlatformImage(named: "AUTab")!
    
    #if os(iOS)
    
    ///
    /// Convenience initializer to match the signature of the equivalent initializer on iOS.
    ///
    convenience init?(systemSymbolName name: String, accessibilityDescription: String?) {
        self.init(systemName: name)
    }
    
    convenience init?(contentsOf file: URL) {
        self.init(contentsOfFile: file.path)
    }
    
    #endif
}
