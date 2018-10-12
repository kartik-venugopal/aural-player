import Cocoa

/*
    Window controller for the playlist search dialog
 */
class PlaylistSearchWindowController: NSWindowController, ModalDialogDelegate, MessageSubscriber {
    
    // Playlist search modal dialog fields
    
    @IBOutlet weak var searchField: ColoredCursorSearchField!
    
    @IBOutlet weak var searchResultsSummaryLabel: NSTextField!
    @IBOutlet weak var searchResultMatchInfo: NSTextField!
    
    @IBOutlet weak var btnNextSearch: NSButton!
    @IBOutlet weak var btnPreviousSearch: NSButton!
    
    @IBOutlet weak var searchByName: NSButton!
    @IBOutlet weak var searchByArtist: NSButton!
    @IBOutlet weak var searchByTitle: NSButton!
    @IBOutlet weak var searchByAlbum: NSButton!
    
    @IBOutlet weak var comparisonTypeContains: NSButton!
    @IBOutlet weak var comparisonTypeEquals: NSButton!
    @IBOutlet weak var comparisonTypeBeginsWith: NSButton!
    @IBOutlet weak var comparisonTypeEndsWith: NSButton!
    
    @IBOutlet weak var searchCaseSensitive: NSButton!
    
    // Delegate that relays search requests to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    private var searchQuery: SearchQuery = SearchQuery()
    
    // Current playlist search results
    private var searchResults: SearchResults?
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {return "PlaylistSearch"}
    
    override func windowDidLoad() {
        
        self.window?.titlebarAppearsTransparent = true
        SyncMessenger.subscribe(messageTypes: [.searchTextChangedNotification], subscriber: self)
    }

    func showDialog() -> ModalDialogResponse {
        
        // Don't do anything if no tracks in playlist
        if (playlist.size() == 0) {
            return .cancel
        }
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        searchField.stringValue = ""
        searchQuery.text = ""
        
        resetSearchFields()
        self.window?.makeFirstResponder(searchField)
        
        UIUtils.showModalDialog(self.window!)
        return modalDialogResponse
    }
    
    // Called when any of the search criteria have changed, performs a new search
    private func updateSearch() {
        
        searchResults = playlist.search(searchQuery, PlaylistViewState.current)
        
        if ((searchResults?.count)! > 0) {
            
            // Show the first result
            nextSearchAction(self)
            
        } else {
            resetSearchFields()
        }
    }
    
    private func resetSearchFields() {
        
        if (searchField.stringValue.isEmpty) {
            searchResultsSummaryLabel.stringValue = "No results"
        } else {
            searchResultsSummaryLabel.stringValue = "No results found"
        }
        searchResultMatchInfo.stringValue = ""
        [btnNextSearch, btnPreviousSearch].forEach({$0.isHidden = true})
    }
    
    // Iterates to the previous search result
    @IBAction func previousSearchAction(_ sender: Any) {
        updateSearchPanelWithResult(searchResult: (searchResults?.previous())!)
    }
    
    // Iterates to the next search result
    @IBAction func nextSearchAction(_ sender: Any) {
        updateSearchPanelWithResult(searchResult: (searchResults?.next())!)
    }
    
    // Updates displayed search results info with the current search result
    private func updateSearchPanelWithResult(searchResult: SearchResult) {
        
        // Select the track in the playlist view, to show the user where the track is
        selectTrack(searchResult)
        
        let numResults = (searchResults?.count)!
        let resultsText = numResults == 1 ? "result found" : "results found"
        searchResultsSummaryLabel.stringValue = String(format: "%d %@. Selected %d / %d", numResults, resultsText, searchResult.resultIndex, numResults)
        
        searchResultMatchInfo.stringValue = String(format: "Matched %@: '%@'", searchResult.match.fieldKey, searchResult.match.fieldValue)
        
        btnNextSearch.isHidden = !searchResult.hasNext
        btnPreviousSearch.isHidden = !searchResult.hasPrevious
    }
    
    // Selects a track within the playlist view, to show the user where the track is located within the playlist
    private func selectTrack(_ result: SearchResult) {
        _ = SyncMessenger.publishRequest(SearchResultSelectionRequest(result))
    }
    
    @IBAction func searchDoneAction(_ sender: Any) {
        modalDialogResponse = .ok
        UIUtils.dismissModalDialog()
    }
    
    private func searchTextChanged() {
        
        let searchText = searchField.stringValue
        searchQuery.text = searchText
        
        // No search text, don't do the search
        if (searchText == "") {
            resetSearchFields()
            return
        }
        
        updateSearch()
    }
    
    @IBAction func searchFieldsChangedAction(_ sender: Any) {
        
        let searchFields = searchQuery.fields
        
        searchFields.name = Bool(searchByName.state.rawValue)
        searchFields.artist = Bool(searchByArtist.state.rawValue)
        searchFields.title = Bool(searchByTitle.state.rawValue)
        searchFields.album = Bool(searchByAlbum.state.rawValue)
        
        // No fields to compare or no search text, don't do the search
        if (searchFields.noFieldsSelected() || searchQuery.text == "") {
            resetSearchFields()
            return
        }
        
        updateSearch()
    }
    
    @IBAction func searchTypeChangedAction(_ sender: Any) {
        
        if (comparisonTypeEquals.state.rawValue == 1) {
            searchQuery.type = .equals
        } else if (comparisonTypeContains.state.rawValue == 1) {
            searchQuery.type = .contains
        } else if (comparisonTypeBeginsWith.state.rawValue == 1) {
            searchQuery.type = .beginsWith
        } else {
            // Ends with
            searchQuery.type = .endsWith
        }
        
        // No fields to compare or no search text, don't do the search
        if (searchQuery.fields.noFieldsSelected() || searchQuery.text == "") {
            resetSearchFields()
            return
        }
        
        updateSearch()
    }
    
    @IBAction func searchOptionsChangedAction(_ sender: Any) {
        
        searchQuery.options.caseSensitive = Bool(searchCaseSensitive.state.rawValue)
        
        // No fields to compare or no search text, don't do the search
        if (searchQuery.fields.noFieldsSelected() || searchQuery.text == "") {
            resetSearchFields()
            return
        }
        
        updateSearch()
    }
    
    func getID() -> String {
        return self.className
    }
    
    // MARK: Message handling
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is SearchTextChangedNotification) {
            searchTextChanged()
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
}
