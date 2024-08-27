//
//  MetadataPreferencesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MetadataPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    override var nibName: NSNib.Name? {"MetadataPreferences"}
    
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var btnCacheTrackMetadata: CheckBox!
    
    @IBOutlet weak var timeoutStepper: NSStepper!
    @IBOutlet weak var lblTimeout: NSTextField!
    
    private let musicBrainzPreferencesView: PreferencesViewProtocol = MusicBrainzPreferencesViewController()
    private let lastFMPreferencesView: PreferencesViewProtocol = LastFMPreferencesViewController()
    
    var preferencesView: NSView {
        view
    }
    
    private var subViews: [PreferencesViewProtocol] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        subViews = [musicBrainzPreferencesView, lastFMPreferencesView]
        
        let actualViews = subViews.map {$0.preferencesView}
        for (index, view) in actualViews.enumerated() {
            tabView.tabViewItem(at: index).view?.addSubview(view)
        }
    }
    
    private var metadataPrefs: MetadataPreferences {
        preferences.metadataPreferences
    }
    
    func resetFields() {
        
        btnCacheTrackMetadata.onIf(metadataPrefs.cacheTrackMetadata.value)
        
        timeoutStepper.integerValue = metadataPrefs.httpTimeout.value
        lblTimeout.stringValue = "\(timeoutStepper.integerValue) sec"
        
        subViews.forEach {$0.resetFields()}
    }
    
    @IBAction func clearCacheAction(_ sender: NSButton) {
        
        metadataRegistry.clearRegistry()
        NSAlert.showInfo(withTitle: "Action completed", andText: "The metadata cache has been cleared!")
    }
    
    @IBAction func httpTimeoutStepperAction(_ sender: NSStepper) {
        lblTimeout.stringValue = "\(timeoutStepper.integerValue) sec"
    }
    
    func save() throws {
        
        metadataPrefs.cacheTrackMetadata.value = btnCacheTrackMetadata.isOn
        metadataPrefs.httpTimeout.value = timeoutStepper.integerValue
        
        for subView in subViews {
            try subView.save()
        }
    }
}
