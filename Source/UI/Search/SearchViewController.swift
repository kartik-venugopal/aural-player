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
        
//        NSView.showViews(btnPreviousSearch, btnNextSearch)
//        lblSummary.stringValue = "\(searchResults.count) \(searchResults.count == 1 ? "result" : "results") found in \(searchQuery.scope.description)"
        lblSummary.stringValue = "\(searchResults.count) \(searchResults.count == 1 ? "result" : "results")"
    }
    
    private func updateSearchResultsForPlayQueue() {
        
        searchResults = playQueueDelegate.search(searchQuery)
        
        for (index, res) in searchResults.results.enumerated() {
            print("\t\(index + 1): '\(res.location.track.displayName)' at: \((res.location as! PlayQueueSearchResultLocation).index)")
        }
    }
    
    private func noResultsFound() {
        
        //        lblSummary.stringValue = "No results"
        //        NSView.hideViews(btnNextSearch, btnPreviousSearch)
    }
    
    // If no fields to compare or no search text, don't do the search
    private func redoSearchIfPossible() {
        
        searchQuery.queryPossible ? updateSearch() : noResultsFound()
        resultsTable.reloadData()
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
//        view.window?.close()
        messenger.publish(.Search.done)
    }
}
