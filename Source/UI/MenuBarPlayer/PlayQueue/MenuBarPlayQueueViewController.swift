//
//  MenuBarPlayQueueViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

///
/// A container for *CompactPlayQueueViewController*.
///
class MenuBarPlayQueueViewController: CompactPlayQueueViewController {
    
    override var nibName: NSNib.Name? {"MenuBarPlayQueue"}
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var btnClose: NSButton!
    
    @IBOutlet weak var sortOptionsBox: NSBox!
    
    @IBOutlet weak var btnSortByName: RadioButton!
    @IBOutlet weak var btnSortByDuration: RadioButton!
//    @IBOutlet weak var btnSortByFileLastModifiedTime: RadioButton!
    
    @IBOutlet weak var btnSortByArtist_andAlbum_andDiscTrack: RadioButton!
    @IBOutlet weak var btnSortByArtist_andAlbum_andName: RadioButton!
    @IBOutlet weak var btnSortByArtist_andName: RadioButton!
    
    @IBOutlet weak var btnSortByAlbum_andDiscTrack: RadioButton!
    @IBOutlet weak var btnSortByAlbum_andName: RadioButton!
    
    @IBOutlet weak var btnSortAscending: RadioButton!
    @IBOutlet weak var btnSortDescending: RadioButton!
    
    @IBAction func closeAction(_ sender: NSButton) {
        
        menuBarPlayerUIState.showPlayQueue = false
        messenger.publish(.MenuBarPlayer.togglePlayQueue)
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        btnClose.colorChanged(systemColorScheme.buttonColor)
    }
    
    override func initTheme() {
        
        super.initTheme()
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        btnClose.colorChanged(systemColorScheme.buttonColor)
    }
    
    @IBAction func showSortOptionsAction(_ sender: Any) {
        
        sortOptionsBox.showIf(sortOptionsBox.isHidden)
        sortOptionsBox.bringToFront()
    }
    
    @IBAction func sortFieldsRadioButtonGroupingAction(_ sender: Any) {}
    
    @IBAction func sortOrderRadioButtonGroupingAction(_ sender: Any) {}
    
    @IBAction func executeSortAction(_ sender: Any) {
        
        let fields: [TrackSortField]
        
        if btnSortByName.isOn {
            fields = [.name]
            
        } else if btnSortByDuration.isOn {
            fields = [.duration]
            
        } else if btnSortByArtist_andAlbum_andDiscTrack.isOn {
            fields = [.artist, .album, .discNumberAndTrackNumber]
            
        } else if btnSortByArtist_andAlbum_andName.isOn {
            fields = [.artist, .album, .name]
            
        } else if btnSortByArtist_andName.isOn {
            fields = [.artist, .name]
            
        } else if btnSortByAlbum_andDiscTrack.isOn {
            fields = [.album, .discNumberAndTrackNumber]
            
//        } else if btnSortByFileLastModifiedTime.isOn {
//            fields = [.fileLastModifiedTime]
//            
        } else {
            
            // Default sort
            fields = [.artist, .album, .discNumberAndTrackNumber]
        }

        sortOptionsBox.hide()
        sort(by: fields, order: btnSortAscending.isOn ? .ascending : .descending)
        updateSummary()
    }
    
    @IBAction func cancelSortAction(_ sender: Any) {
        sortOptionsBox.hide()
    }
}
