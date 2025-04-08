//
//  MetadataPreferencesViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MetadataPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    override var nibName: NSNib.Name? {"MetadataPreferences"}
    
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var btnCacheTrackMetadata: CheckBox!
    @IBOutlet weak var btnClearCache: NSButton!
    
    @IBOutlet weak var timeoutStepper: NSStepper!
    @IBOutlet weak var lblTimeout: NSTextField!
    
    private let lyricsPreferencesView: PreferencesViewProtocol = LyricsPreferencesViewController()
    private let musicBrainzPreferencesView: PreferencesViewProtocol = MusicBrainzPreferencesViewController()
    private let lastFMPreferencesView: PreferencesViewProtocol = LastFMPreferencesViewController()
    
    var preferencesView: NSView {
        view
    }
    
    private var subViews: [PreferencesViewProtocol] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        subViews = [lyricsPreferencesView, musicBrainzPreferencesView, lastFMPreferencesView]
        
        let actualViews = subViews.map {$0.preferencesView}
        for (index, view) in actualViews.enumerated() {
            tabView.tabViewItem(at: index).view?.addSubview(view)
        }
    }
    
    private var metadataPrefs: MetadataPreferences {
        preferences.metadataPreferences
    }
    
    func resetFields() {
        
        btnCacheTrackMetadata.onIf(metadataPrefs.cacheTrackMetadata)
        enableCacheAction(self)
        
        timeoutStepper.integerValue = metadataPrefs.httpTimeout
        lblTimeout.stringValue = "\(timeoutStepper.integerValue) sec"
        
        subViews.forEach {$0.resetFields()}
    }
    
    @IBAction func enableCacheAction(_ sender: Any) {
        btnClearCache.enableIf(btnCacheTrackMetadata.isOn)
    }
    
    @IBAction func clearCacheAction(_ sender: NSButton) {
        
        metadataRegistry.clearRegistry()
        NSAlert.showInfo(withTitle: "Action completed", andText: "The metadata cache has been cleared!")
    }
    
    @IBAction func httpTimeoutStepperAction(_ sender: NSStepper) {
        lblTimeout.stringValue = "\(timeoutStepper.integerValue) sec"
    }
    
    func save() throws {
        
        let wasCachingMetadata: Bool = metadataPrefs.cacheTrackMetadata
        metadataPrefs.cacheTrackMetadata = btnCacheTrackMetadata.isOn
        
        // If no longer caching track metadata, empty the cache.
        if wasCachingMetadata && (metadataPrefs.cacheTrackMetadata == false) {
            metadataRegistry.clearRegistry()
            
        } else if (!wasCachingMetadata) && metadataPrefs.cacheTrackMetadata {
            
            // Was not caching before, now need to cache all PQ tracks.
            
            DispatchQueue.global(qos: .utility).async {
                metadataRegistry.bulkAddMetadata(from: playQueueDelegate.tracks)
            }
        }
        
        metadataPrefs.httpTimeout = timeoutStepper.integerValue
        
        for subView in subViews {
            try subView.save()
        }
    }
}
