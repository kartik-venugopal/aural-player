//
//  SearchViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Cocoa

class SearchViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"Search"}
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var searchField: NSSearchField!
    
    @IBOutlet weak var lblSummary: NSTextField!
    @IBOutlet weak var resultsTable: CompactPlayQueueSearchResultsTableView!
    
    var searchQuery: SearchQuery = SearchQuery()
    
    // Current search results
    private(set) var searchResults: SearchResults!
    
    private lazy var messenger = Messenger(for: self)
    
    private lazy var settingsWindowController: SearchSettingsWindowController = .init()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribe(to: .PlayQueue.searchSettingsUpdated, handler: searchSettingsUpdated)
        
        fontSchemesManager.registerObserver(self)
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        
        // Offset the caption label a bit to the right.
        if appModeManager.currentMode == .modular,
            let lblCaptionLeadingConstraint = lblCaption.superview?.constraints.first(where: {$0.firstAttribute == .leading}) {
            
            lblCaptionLeadingConstraint.constant = 23
        }
    }

    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        // Don't do anything if no tracks in playlist
        searchField.stringValue = ""
        searchQuery.text = ""
        noResultsFound()
        
        view.window?.makeKey()
        view.window?.makeFirstResponder(searchField)
    }
    
    // Called when any of the search criteria have changed, performs a new search
    private func updateSearch() {
        
        defer {resultsTable.startTracking()}
        
        switch searchQuery.scope {
            
        case .playQueue:
            updateSearchResultsForPlayQueue()
            
        default:
            return
        }
        
        if !searchResults.hasResults {
            
            lblSummary.stringValue = "0 results"
            return
        }
        
        lblSummary.stringValue = "\(searchResults.count) \(searchResults.count == 1 ? "result" : "results")"
    }
    
    private func updateSearchResultsForPlayQueue() {
        searchResults = playQueueDelegate.search(searchQuery)
    }
    
    private func noResultsFound() {
        
        lblSummary.stringValue = "0 results"
        searchResults = .noPlayQueueResults
        resultsTable.reset()
    }
    
    // If no fields to compare or no search text, don't do the search
    private func redoSearchIfPossible() {
        
        searchQuery.queryPossible ? updateSearch() : noResultsFound()
        resultsTable.reloadData()
    }
    
    private func searchSettingsUpdated() {
        
        searchQuery.fields = playQueueUIState.searchSettings.fields
        searchQuery.type = playQueueUIState.searchSettings.type
        searchQuery.options = playQueueUIState.searchSettings.options
        
        redoSearchIfPossible()
    }
    
    @IBAction func searchTextChangeAction(_ sender: Any) {
        
        searchQuery.text = searchField.stringValue
        searchField.recentSearches.append(searchField.stringValue)
        redoSearchIfPossible()
    }
    
    @IBAction func showSettingsAction(_ sender: Any) {
        settingsWindowController.showWindow(self)
    }
    
    @IBAction func playSearchResultAction(_ sender: Any) {
        
        if resultsTable.selectedRow >= 0, let results = self.searchResults,
            let pqLocation = results.results[resultsTable.selectedRow].location as? PlayQueueSearchResultLocation {
            
            messenger.publish(TrackPlaybackCommandNotification(index: pqLocation.index))
        }
    }
    
    @IBAction func searchDoneAction(_ sender: Any) {
        messenger.publish(.Search.done)
    }
}
