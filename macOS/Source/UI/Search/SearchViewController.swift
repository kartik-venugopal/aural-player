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
    
    override var nibName: String? {"Search"}
    
    @IBOutlet weak var searchField: NSSearchField!
    
    //    @IBOutlet weak var lblMatchFieldName: NSTextField!
    //    @IBOutlet weak var lblMatchFieldValue: NSTextField!
    
    @IBOutlet weak var btnNextSearch: NSButton!
    @IBOutlet weak var btnPreviousSearch: NSButton!
    
    @IBOutlet weak var btnSearchByName: NSButton!
    @IBOutlet weak var btnSearchByArtist: NSButton!
    @IBOutlet weak var btnSearchByTitle: NSButton!
    @IBOutlet weak var btnSearchByAlbum: NSButton!
    
    @IBOutlet weak var btnComparisonType: NSPopUpButton!
    
    @IBOutlet weak var btnSearchCaseSensitive: NSButton!
    
    @IBOutlet weak var lblSummary: NSTextField!
    @IBOutlet weak var resultsTable: NSTableView!
    
    private var searchQuery: SearchQuery = SearchQuery()
    
    // Current search results
    private(set) var searchResults: SearchResults!
    
    //    private var modalDialogResponse: ModalDialogResponse = .ok
    //
    //    override var windowNibName: String? {"PlaylistSearch"}
    
    private lazy var messenger = Messenger(for: self)
    //
    //    private lazy var uiState: PlaylistUIState = objectGraph.playlistUIState
    //
    //    var isModal: Bool {self.window?.isVisible ?? false}
    //
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        // Don't do anything if no tracks in playlist
        //            guard playlist.size > 0 else {return .cancel}
        
        searchField.stringValue = ""
        searchQuery.text = ""
        noResultsFound()
        view.window?.makeFirstResponder(searchField)
    }
    
    // Called when any of the search criteria have changed, performs a new search
    private func updateSearch() {
        
        switch searchQuery.scope {
            
        case .playQueue:
            
            searchResults = playQueueDelegate.search(searchQuery)
            
            if !searchResults.hasResults {
                
                lblSummary.stringValue = "0 results"
                print("No Results for Query: '\(searchQuery.text)'")
                return
            }
            
            NSView.showViews(btnPreviousSearch, btnNextSearch)
            
            print("Results for Query: '\(searchQuery.text)' ...")
            lblSummary.stringValue = "\(searchResults.count) \(searchResults.count == 1 ? "result" : "results") found in Play Queue"
            
            for (index, res) in searchResults.results.enumerated() {
                print("\t\(index + 1): '\(res.location.track.displayName)' at: \((res.location as! PlayQueueSearchResultLocation).index)")
            }
            
        default:
            
            return
        }
        
        //        searchResults = playlist.search(searchQuery, uiState.currentView)
        
        // Show the first result
        //        searchResults.hasResults ? nextSearchAction(self) : noResultsFound()
    }
    
    private func noResultsFound() {
        
        //        lblSummary.stringValue = "No results"
        //        lblMatchFieldName.stringValue = ""
        //        lblMatchFieldValue.stringValue = ""
        //
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
    
    @IBAction func searchFieldsChangedAction(_ sender: Any) {
        
        var searchFields: SearchFields = .none
        
        searchFields.include(.name, if: btnSearchByName.isOn)
        searchFields.include(.artist, if: btnSearchByArtist.isOn)
        searchFields.include(.title, if: btnSearchByTitle.isOn)
        searchFields.include(.album, if: btnSearchByAlbum.isOn)
        
        searchQuery.fields = searchFields
        
        redoSearchIfPossible()
    }
    
    @IBAction func searchTypeChangedAction(_ sender: Any) {
        
        guard let queryTypeStr = btnComparisonType.titleOfSelectedItem,
              let queryType = SearchType(rawValue: queryTypeStr) else {return}
            
        searchQuery.type = queryType
        redoSearchIfPossible()
    }
    
    @IBAction func searchOptionsChangedAction(_ sender: Any) {
        
        searchQuery.options.include(.caseSensitive, if: btnSearchCaseSensitive.isOn)
        redoSearchIfPossible()
    }
    
    //
    //    // Iterates to the previous search result
    //    @IBAction func previousSearchAction(_ sender: Any) {
    //
    //        if let result = searchResults.previous() {
    //            updateSearchPanelWithResult(result)
    //        }
    //    }
    //
    //    // Iterates to the next search result
    //    @IBAction func nextSearchAction(_ sender: Any) {
    //
    //        if let result = searchResults.next() {
    //            updateSearchPanelWithResult(result)
    //        }
    //    }
    //
    //    // Updates displayed search results info with the current search result
    //    private func updateSearchPanelWithResult(_ searchResult: SearchResult) {
    //
    //        lblSummary.stringValue = String(format: "Selected result:   %d / %d",
    //                                        searchResults.currentIndex + 1, searchResults.count)
    //
    //        lblMatchFieldName.stringValue = "Matched field:   \(searchResult.match.fieldKey.capitalizingFirstLetter())"
    //        lblMatchFieldValue.stringValue = "Matched value:   '\(searchResult.match.fieldValue)'"
    //
    //        btnNextSearch.showIf(searchResults.hasNext)
    //        btnPreviousSearch.showIf(searchResults.hasPrevious)
    //
    //        // Selects a track within the playlist view, to show the user where the track is located within the playlist
    //        messenger.publish(SelectSearchResultCommandNotification(searchResult: searchResult,
    //                                                                viewSelector: uiState.currentViewSelector))
    //    }
    
    @IBAction func playSearchResultAction(_ sender: Any) {
        
        if resultsTable.selectedRow >= 0, let results = self.searchResults,
            let pqLocation = results.results[resultsTable.selectedRow].location as? PlayQueueSearchResultLocation {
            
            messenger.publish(TrackPlaybackCommandNotification(index: pqLocation.index))
        }
    }
    
    @IBAction func searchDoneAction(_ sender: Any) {
        view.window?.close()
    }
}
