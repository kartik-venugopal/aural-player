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
    
    @IBOutlet weak var lblSeachByCaption: NSTextField!
    @IBOutlet weak var lblComparisonTypeCaption: NSTextField!
    @IBOutlet weak var lblOptionsCaption: NSTextField!
    
    lazy var captionLabels: [NSTextField] = [lblSeachByCaption, lblComparisonTypeCaption, lblOptionsCaption]
    
    @IBOutlet weak var btnNextSearch: NSButton!
    @IBOutlet weak var btnPreviousSearch: NSButton!
    
    @IBOutlet weak var btnSearchByName: CheckBox!
    @IBOutlet weak var btnSearchByArtist: CheckBox!
    @IBOutlet weak var btnSearchByTitle: CheckBox!
    @IBOutlet weak var btnSearchByAlbum: CheckBox!
    
    @IBOutlet weak var btnComparisonType: NSPopUpButton!
    
    @IBOutlet weak var btnSearchCaseSensitive: CheckBox!
    
    lazy var checkBoxes: [CheckBox] = [btnSearchByName, btnSearchByArtist, btnSearchByTitle, btnSearchByAlbum, btnSearchCaseSensitive]
    
    @IBOutlet weak var lblSummary: NSTextField!
    @IBOutlet weak var resultsTable: NSTableView!
    
    private var searchQuery: SearchQuery = SearchQuery()
    
    // Current search results
    private(set) var searchResults: SearchResults!
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        fontSchemesManager.registerObserver(self)
        colorSchemesManager.registerSchemeObserver(self)
    }

    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        // Don't do anything if no tracks in playlist
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
