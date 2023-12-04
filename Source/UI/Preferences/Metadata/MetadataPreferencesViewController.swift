//
//  MetadataPreferencesViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MetadataPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnEnableMusicBrainzCoverArtSearch: NSButton!
    
    @IBOutlet weak var timeoutStepper: NSStepper!
    @IBOutlet weak var lblTimeout: NSTextField!
    
    @IBOutlet weak var btnEnableMusicBrainzOnDiskCoverArtCache: NSButton!
    @IBOutlet weak var btnDisableMusicBrainzOnDiskCoverArtCache: NSButton!
    
    @IBOutlet weak var btnEnableLastFMScrobbling: NSButton!
    @IBOutlet weak var btnEnableLastFMLoveUnlove: NSButton!
    
    @IBOutlet weak var lblLastFMAuthInstructions1: NSTextField!
    @IBOutlet weak var lblLastFMAuthInstructions2: NSTextField!
    
    @IBOutlet weak var imgLastFMAuthStatus: NSImageView!
    @IBOutlet weak var lblLastFMAuthStatus: NSTextField!
    
    @IBOutlet weak var btnLastFMGrantPermission: NSButton!
    @IBOutlet weak var btnLastFMGetSessionKey: NSButton!
    
    private let playbackInfo: PlaybackInfoDelegateProtocol = objectGraph.playbackInfoDelegate
    private let trackReader: TrackReader = objectGraph.trackReader
    private let musicBrainzCache: MusicBrainzCache = objectGraph.musicBrainzCache
    private let lastFMClient: LastFM_WSClientProtocol = objectGraph.lastFMClient
    
    override var nibName: String? {"MetadataPreferences"}
    
    private var lastFMToken: LastFMToken? = nil
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let prefs = preferences.metadataPreferences
        let musicBrainzPrefs = prefs.musicBrainz
        let lastFMPrefs = prefs.lastFM
        
        timeoutStepper.integerValue = prefs.httpTimeout
        lblTimeout.stringValue = "\(timeoutStepper.integerValue) sec"
       
        btnEnableMusicBrainzCoverArtSearch.onIf(musicBrainzPrefs.enableCoverArtSearch)
        
        if musicBrainzPrefs.enableOnDiskCoverArtCache {
            btnEnableMusicBrainzOnDiskCoverArtCache.on()
        } else {
            btnDisableMusicBrainzOnDiskCoverArtCache.on()
        }
        
        btnEnableLastFMScrobbling.onIf(lastFMPrefs.enableScrobbling)
        btnEnableLastFMLoveUnlove.onIf(lastFMPrefs.enableLoveUnlove)
        
        if lastFMPrefs.sessionKey == nil {
            
            lblLastFMAuthInstructions1.show()
            lblLastFMAuthInstructions2.show()
            
            imgLastFMAuthStatus.image = Images.imgError
            lblLastFMAuthStatus.stringValue = "(Not Authenticated)"
            
            btnLastFMGrantPermission.show()
            btnLastFMGetSessionKey.show()
            
        } else {
            hideLastFMAuthFields()
        }
    }
    
    private func hideLastFMAuthFields() {
        
        lblLastFMAuthInstructions1.hide()
        lblLastFMAuthInstructions2.hide()
        
        imgLastFMAuthStatus.image = Images.imgGreenCheck
        lblLastFMAuthStatus.stringValue = "(Authenticated)"
        
        btnLastFMGrantPermission.hide()
        btnLastFMGetSessionKey.hide()
    }
    
    @IBAction func timeoutStepperAction(_ sender: NSStepper) {
        lblTimeout.stringValue = "\(timeoutStepper.integerValue) sec"
    }
    
    // Needed for radio button group
    @IBAction func musicBrainzOnDiskCacheCoverArtAction(_ sender: NSButton) {}
    
    @IBAction func grantLastFMPermissionAction(_ sender: Any) {
        
        // TODO: Make this async
        
        if let token = lastFMClient.getToken() {
            
            self.lastFMToken = token
            lastFMClient.requestUserAuthorization(withToken: token)
        }
    }
    
    @IBAction func getLastFMSessionKeyAction(_ sender: Any) {

        // TODO: Make this async
        
        if let token = self.lastFMToken,
           let session = lastFMClient.getSession(forToken: token) {
            
            let prefs = objectGraph.preferences.metadataPreferences.lastFM
            prefs.sessionKey = session.key
            prefs.persistSessionKey(to: .standard)
            
            print("Got SK = \(session.key) !!!")
            
            hideLastFMAuthFields()
        }
    }
    
    func save(_ preferences: Preferences) throws {
        
        let prefs = preferences.metadataPreferences
        let mbPrefs: MusicBrainzPreferences = prefs.musicBrainz
        let lastFMPrefs = prefs.lastFM
        
        prefs.httpTimeout = timeoutStepper.integerValue
        
        let wasSearchDisabled: Bool = !mbPrefs.enableCoverArtSearch
        mbPrefs.enableCoverArtSearch = btnEnableMusicBrainzCoverArtSearch.isOn
        
        mbPrefs.enableOnDiskCoverArtCache = btnEnableMusicBrainzOnDiskCoverArtCache.isOn
        
        // If searching was disabled before but has been switched on, let's search for art for the playing track, if required.
        if wasSearchDisabled && mbPrefs.enableCoverArtSearch, let playingTrack = playbackInfo.playingTrack {
            trackReader.loadArtAsync(for: playingTrack, immediate: true)
        }
        
        if mbPrefs.enableCoverArtSearch && mbPrefs.enableOnDiskCoverArtCache {
            musicBrainzCache.onDiskCachingEnabled()
        } else {
            musicBrainzCache.onDiskCachingDisabled()
        }
        
        lastFMPrefs.enableScrobbling = btnEnableLastFMScrobbling.isOn
        lastFMPrefs.enableLoveUnlove = btnEnableLastFMLoveUnlove.isOn
    }
}
