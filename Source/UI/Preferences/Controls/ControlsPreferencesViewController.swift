//
//  ControlsPreferencesViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ControlsPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    override var nibName: NSNib.Name? {"ControlsPreferences"}
    
    @IBOutlet weak var tabView: NSTabView!
    
    private let mediaKeysPreferencesView: PreferencesViewProtocol = MediaKeysPreferencesViewController()
    private let gesturesPreferencesView: PreferencesViewProtocol = GesturesPreferencesViewController()
    private let remoteControlPreferencesView: PreferencesViewProtocol = RemoteControlPreferencesViewController()
    
    private var subViews: [PreferencesViewProtocol] = []
    
    var preferencesView: NSView {
        view
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
    
    func resetFields() {
        subViews.forEach {$0.resetFields()}
    }
    
    func save() throws {
        
        for subView in subViews {
            try subView.save()
        }
    }
}
