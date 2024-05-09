//
//  ControlsPreferencesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ControlsPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var tabView: NSTabView!
    
    private let mediaKeysPreferencesView: PreferencesViewProtocol = MediaKeysPreferencesViewController()
    private let gesturesPreferencesView: PreferencesViewProtocol = GesturesPreferencesViewController()
    private let remoteControlPreferencesView: PreferencesViewProtocol = RemoteControlPreferencesViewController()
    
    private var subViews: [PreferencesViewProtocol] = []
    
    override var nibName: String? {"ControlsPreferences"}
    
    override func viewDidLoad() {
        
        subViews = [mediaKeysPreferencesView, gesturesPreferencesView, remoteControlPreferencesView]
        
        let actualViews = subViews.map {$0.preferencesView}
        for (index, view) in actualViews.enumerated() {
            tabView.tabViewItem(at: index).view?.addSubview(view)
        }
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        // Select the Media Keys prefs tab
        tabView.selectTabViewItem(at: 0)
    }
    
    var preferencesView: NSView {
        view
    }
    
    func resetFields() {
        subViews.forEach {$0.resetFields()}
    }
    
    func save() throws {
        
        for subView in subViews {
            try subView.save()
        }
    }
}
