//
//  MusicBrainzPreferencesViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class MusicBrainzPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    override var nibName: NSNib.Name? {"MusicBrainzPreferences"}
    
    @IBOutlet weak var btnEnableCoverArtSearch: NSButton!
    
    @IBOutlet weak var btnEnableOnDiskCache: NSButton!
    @IBOutlet weak var btnDisableOnDiskCache: NSButton!
    
    var preferencesView: NSView {
        view
    }
    
    private var musicBrainzPrefs: MusicBrainzPreferences {
        preferences.metadataPreferences.musicBrainz
    }
    
    func resetFields() {

        btnEnableCoverArtSearch.onIf(musicBrainzPrefs.enableCoverArtSearch)

        if musicBrainzPrefs.enableOnDiskCoverArtCache {
            btnEnableOnDiskCache.on()
        } else {
            btnDisableOnDiskCache.on()
        }
    }
    
    // Needed for radio button group
    @IBAction func onDiskCacheRadioButtonAction(_ sender: NSButton) {}
    
    func save() throws {
        
        let wasSearchDisabled: Bool = !musicBrainzPrefs.enableCoverArtSearch
        musicBrainzPrefs.enableCoverArtSearch = btnEnableCoverArtSearch.isOn
        
        musicBrainzPrefs.enableOnDiskCoverArtCache = btnEnableOnDiskCache.isOn
        
        // If searching was disabled before but has been switched on, let's search for art for the playing track, if required.
        if wasSearchDisabled && musicBrainzPrefs.enableCoverArtSearch, let playingTrack = player.playingTrack {
            trackReader.loadArtAsync(for: playingTrack, immediate: true)
        }
        
        musicBrainzPrefs.cachingEnabled ? musicBrainzCache.onDiskCachingEnabled() : musicBrainzCache.onDiskCachingDisabled()
    }
}
