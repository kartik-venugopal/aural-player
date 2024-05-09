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
    
    override var windowNibName: NSNib.Name? {"Preferences"}
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        subViews = [playQueuePrefsView, playbackPrefsView, soundPrefsView, viewPrefsView, historyPrefsView, controlsPrefsView, metadataPrefsView]
        
        for (index, viewController) in subViews.enumerated() {
            tabView.tabViewItem(at: index).view?.addSubview(viewController.preferencesView)
        }
    }
    
    override func showWindow(_ sender: Any?) {
        
        toolbar.selectedItemIdentifier = NSToolbarItem.Identifier("PlayQueue")
        super.showWindow(self)
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    func showDialog() -> ModalDialogResponse {
     
        forceLoadingOfWindow()
        resetPreferencesFields()
        
        // Select the play queue prefs tab
        tabView.selectTabViewItem(at: 0)
        
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
    }
    
    @IBAction func previousTabAction(_ sender: Any) {
//        tabView.previousTab()
    }
    
    @IBAction func nextTabAction(_ sender: Any) {
//        tabView.nextTab()
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
