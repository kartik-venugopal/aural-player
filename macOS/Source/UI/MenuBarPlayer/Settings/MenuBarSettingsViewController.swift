//
//  MenuBarSettingsViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class MenuBarSettingsViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"MenuBarSettings"}
    
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var btnShowArt: CheckBox!
    @IBOutlet weak var btnShowArtist: CheckBox!
    @IBOutlet weak var btnShowAlbum: CheckBox!
    @IBOutlet weak var btnShowChapterTitle: CheckBox!
    
    @IBOutlet weak var btnTimeElapsed: RadioButton!
    @IBOutlet weak var btnTimeRemaining: RadioButton!
    @IBOutlet weak var btnDuration: RadioButton!
    
    @IBOutlet weak var btnShowPlayQueue: CheckBox!
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Update check box state if/when the PQ close button is clicked.
        messenger.subscribe(to: .MenuBarPlayer.togglePlayQueue, handler: {[weak self] in
            self?.btnShowPlayQueue.onIf(menuBarPlayerUIState.showPlayQueue)
        })
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        tabView.selectTabViewItem(at: 0)
        
        btnShowArt.onIf(menuBarPlayerUIState.showAlbumArt)
        btnShowAlbum.onIf(menuBarPlayerUIState.showAlbum)
        btnShowArtist.onIf(menuBarPlayerUIState.showArtist)
        btnShowChapterTitle.onIf(menuBarPlayerUIState.showCurrentChapter)
        
        switch playerUIState.trackTimeDisplayType {
            
        case .elapsed:
            btnTimeElapsed.on()
            
        case .remaining:
            btnTimeRemaining.on()
            
        case .duration:
            btnDuration.on()
        }
        
        btnShowPlayQueue.onIf(menuBarPlayerUIState.showPlayQueue)
    }
    
    @IBAction func showOrHideAlbumArtAction(_ sender: CheckBox) {
        
        menuBarPlayerUIState.showAlbumArt.toggle()
        messenger.publish(.Player.showOrHideAlbumArt)
    }
    
    @IBAction func showOrHideArtistAction(_ sender: CheckBox) {
        
        menuBarPlayerUIState.showArtist.toggle()
        messenger.publish(.Player.showOrHideArtist)
    }
    
    @IBAction func showOrHideAlbumAction(_ sender: CheckBox) {
        
        menuBarPlayerUIState.showAlbum.toggle()
        messenger.publish(.Player.showOrHideAlbum)
    }
    
    @IBAction func showOrHideChapterTitleAction(_ sender: CheckBox) {
        
        menuBarPlayerUIState.showCurrentChapter.toggle()
        messenger.publish(.Player.showOrHideCurrentChapter)
    }
    
    // Shows/hides the Play Queue view
    @IBAction func showPlayQueueAction(_ sender: CheckBox) {
        
        menuBarPlayerUIState.showPlayQueue = sender.isOn
        messenger.publish(.MenuBarPlayer.togglePlayQueue)
    }
    
    @IBAction func trackTimeDisplayTypeAction(_ sender: RadioButton) {
        
        let displayType: TrackTimeDisplayType
        
        switch sender.tag {
            
        case 0:
            displayType = .elapsed
            
        case 1:
            displayType = .remaining
            
        case 2:
            displayType = .duration
            
        default:
            return
        }
        
        playerUIState.trackTimeDisplayType = displayType
        messenger.publish(.Player.setTrackTimeDisplayType, payload: displayType)
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        messenger.publish(.MenuBarPlayer.toggleSettingsMenu)
    }
}
