//
//  PreferencesWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Window controller for the preferences dialog
 */
class PreferencesWindowController: NSWindowController, ModalDialogDelegate {
    
    override var windowNibName: NSNib.Name? {"Preferences"}
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var toolbar: NSToolbar!
    
    // Sub views
    
    private let playQueuePrefsView: PreferencesViewProtocol = PlayQueuePreferencesViewController()
    private let playbackPrefsView: PreferencesViewProtocol = PlaybackPreferencesViewController()
    private let soundPrefsView: PreferencesViewProtocol = SoundPreferencesViewController()
    private let viewPrefsView: PreferencesViewProtocol = ViewPreferencesViewController()
    private let historyPrefsView: PreferencesViewProtocol = HistoryPreferencesViewController()
    private let controlsPrefsView: PreferencesViewProtocol = ControlsPreferencesViewController()
    private let metadataPrefsView: PreferencesViewProtocol = MetadataPreferencesViewController()
    
    private var subViews: [PreferencesViewProtocol] = []
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    private static let key_lastDisplayedTab: String = "preferencesWindow.lastDisplayedTab"
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        subViews = [playQueuePrefsView, playbackPrefsView, soundPrefsView, viewPrefsView, historyPrefsView, controlsPrefsView, metadataPrefsView]
        
        for (index, viewController) in subViews.enumerated() {
            tabView.tabViewItem(at: index).view?.addSubview(viewController.preferencesView)
        }
    }
    
    override func showWindow(_ sender: Any?) {
        
        let tabIndex = (userDefaults[Self.key_lastDisplayedTab] as? Int ?? 0).clampedTo(minValue: 0, maxValue: toolbar.items.count - 1)
        toolbar.selectedItemIdentifier = toolbar.items[tabIndex].itemIdentifier
        
        super.showWindow(self)
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    func showDialog() -> ModalDialogResponse {
     
        forceLoadingOfWindow()
        resetPreferencesFields()
        
        // Select the play queue prefs tab
        let tabIndex = userDefaults[Self.key_lastDisplayedTab] as? Int ?? 0
        tabView.selectTabViewItem(at: tabIndex)
        toolbar.selectedItemIdentifier = toolbar.items[tabIndex].itemIdentifier
        
        theWindow.center()
        showWindow(self)
        
        return modalDialogResponse
    }
    
    private func resetPreferencesFields() {
        subViews.forEach {$0.resetFields()}
    }
    
    // --------------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func switchToTabAction(_ sender: NSToolbarItem) {
        
        tabView.selectTabViewItem(at: sender.tag)
        userDefaults[Self.key_lastDisplayedTab] = sender.tag
    }
    
    @IBAction func savePreferencesAction(_ sender: Any) {
        
        var saveFailed: Bool = false
        
        for (index, view) in subViews.enumerated() {
            
            do {
                
                try view.save()
                
            } catch {
                
                saveFailed = true
                
                // Switch to the tab with the offending view
                tabView.selectTabViewItem(at: index)
                
                return
            }
        }
        
        if !saveFailed {
            
//            preferences.persist()
            userDefaults.synchronize()
            
            modalDialogResponse = .ok
            theWindow.close()
        }
    }
    
    @IBAction func cancelPreferencesAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        theWindow.close()
    }
}

protocol PreferencesViewProtocol {
    
    var preferencesView: NSView {get}
    
    func resetFields()
    
    // Throws an exception if the input provided is invalid
    func save() throws
}
