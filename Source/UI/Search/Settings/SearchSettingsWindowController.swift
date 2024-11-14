//
// SearchSettingsWindowController.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class SearchSettingsWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"SearchSettings"}
    
    @IBOutlet weak var btnSearchByName: CheckBox!
    @IBOutlet weak var btnSearchByArtist: CheckBox!
    @IBOutlet weak var btnSearchByTitle: CheckBox!
    @IBOutlet weak var btnSearchByAlbum: CheckBox!
    
    @IBOutlet weak var btnComparisonType: NSPopUpButton!
    @IBOutlet weak var btnSearchCaseSensitive: CheckBox!
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        theWindow.delegate = self
        
        let searchFields = playQueueUIState.searchSettings.fields
        
        btnSearchByName.onIf(searchFields.contains(.name))
        btnSearchByArtist.onIf(searchFields.contains(.artist))
        btnSearchByTitle.onIf(searchFields.contains(.title))
        btnSearchByAlbum.onIf(searchFields.contains(.album))
        
        btnComparisonType.selectItem(withTitle: playQueueUIState.searchSettings.type.rawValue)
        btnSearchCaseSensitive.onIf(playQueueUIState.searchSettings.options.contains(.caseSensitive))
    }
    
    @IBAction func searchFieldsChangedAction(_ sender: Any) {
        
        var searchFields: SearchFields = .none
        
        searchFields.include(.name, if: btnSearchByName.isOn)
        searchFields.include(.artist, if: btnSearchByArtist.isOn)
        searchFields.include(.title, if: btnSearchByTitle.isOn)
        searchFields.include(.album, if: btnSearchByAlbum.isOn)

        playQueueUIState.searchSettings.fields = searchFields
    }
    
    @IBAction func searchTypeChangedAction(_ sender: Any) {
        
        if let queryTypeStr = btnComparisonType.titleOfSelectedItem,
           let queryType = SearchType(rawValue: queryTypeStr) {
            
            playQueueUIState.searchSettings.type = queryType
        }
    }
    
    @IBAction func searchOptionsChangedAction(_ sender: Any) {
        playQueueUIState.searchSettings.options.include(.caseSensitive, if: btnSearchCaseSensitive.isOn)
    }
    
    @IBAction func doneAction(_ sender: NSButton) {
        close()
    }
}

extension SearchSettingsWindowController: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        Messenger.publish(.PlayQueue.searchSettingsUpdated)
    }
}
