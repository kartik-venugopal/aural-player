import Cocoa

/*
    Window controller for the playlist search dialog
 */
class PlaylistSearchWindowController: NSWindowController, ModalDialogDelegate, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var searchField: ColoredCursorSearchField!
    
    @IBOutlet weak var searchResultsSummaryLabel: NSTextField!
    @IBOutlet weak var searchResultMatchInfo: NSTextField!
    
    @IBOutlet weak var btnNextSearch: NSButton!
    @IBOutlet weak var btnPreviousSearch: NSButton!
    
    @IBOutlet weak var searchByName: NSButton!
    @IBOutlet weak var searchByArtist: NSButton!
    @IBOutlet weak var searchByTitle: NSButton!
    @IBOutlet weak var searchByAlbum: NSButton!
    
    @IBOutlet weak var comparisonType_contains: NSButton!
    @IBOutlet weak var comparisonType_equals: NSButton!
    @IBOutlet weak var comparisonType_beginsWith: NSButton!
    @IBOutlet weak var comparisonType_endsWith: NSButton!
    
    @IBOutlet weak var searchCaseSensitive: NSButton!
    
    // Delegate that relays search requests to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    private var searchQuery: SearchQuery = SearchQuery()
    
    // Current playlist search results
    private var searchResults: SearchResults!
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {"PlaylistSearch"}
    
    private var theWindow: NSWindow {self.window!}
    
    override func windowDidLoad() {
        
        Messenger.subscribe(self, .playlist_searchTextChanged, self.searchTextChanged(_:))
        WindowManager.instance.registerModalComponent(self)
    }
    
    func destroy() {
        Messenger.unsubscribeAll(for: self)
    }
    
    var isModal: Bool {self.window?.isVisible ?? false}

    func showDialog() -> ModalDialogResponse {
        
        // Don't do anything if no tracks in playlist
        guard playlist.size > 0 else {return .cancel}
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {_ = theWindow}
        
        searchField.stringValue = ""
        searchQuery.text = ""
        noResultsFound()
        theWindow.makeFirstResponder(searchField)
        
        UIUtils.showDialog(theWindow)
        return modalDialogResponse
    }
    
    // Called when any of the search criteria have changed, performs a new search
    private func updateSearch() {
        
        searchResults = playlist.search(searchQuery, PlaylistViewState.currentView)
        
        // Show the first result
        searchResults.hasResults ? nextSearchAction(self) : noResultsFound()
    }
    
    private func noResultsFound() {
        
        searchResultsSummaryLabel.stringValue = "No results"
        searchResultMatchInfo.stringValue = ""
        NSView.hideViews(btnNextSearch, btnPreviousSearch)
    }
    
    // Iterates to the previous search result
    @IBAction func previousSearchAction(_ sender: Any) {
        
        if let result = searchResults.previous() {
            updateSearchPanelWithResult(result)
        }
    }
    
    // Iterates to the next search result
    @IBAction func nextSearchAction(_ sender: Any) {
        
        if let result = searchResults.next() {
            updateSearchPanelWithResult(result)
        }
    }
    
    // Updates displayed search results info with the current search result
    private func updateSearchPanelWithResult(_ searchResult: SearchResult) {
        
        let numResults = searchResults.count
        let resultsSingularOrPluralText = numResults > 1 ? "results" : "result"
        
        searchResultsSummaryLabel.stringValue = String(format: "%d %@ found. Selected %d / %d", numResults, resultsSingularOrPluralText, searchResults.currentIndex + 1, numResults)
        searchResultMatchInfo.stringValue = String(format: "Matched %@: '%@'", searchResult.match.fieldKey, searchResult.match.fieldValue)
        
        btnNextSearch.showIf(searchResults.hasNext)
        btnPreviousSearch.showIf(searchResults.hasPrevious)
        
        // Selects a track within the playlist view, to show the user where the track is located within the playlist
        Messenger.publish(SelectSearchResultCommandNotification(searchResult: searchResult,
                                                                viewSelector: PlaylistViewSelector.forView(PlaylistViewState.currentView)))
    }
    
    @IBAction func searchDoneAction(_ sender: Any) {
        
        modalDialogResponse = .ok
        UIUtils.dismissDialog(theWindow)
    }
    
    // If no fields to compare or no search text, don't do the search
    private func redoSearchIfPossible() {
        searchQuery.queryPossible ? updateSearch() : noResultsFound()
    }
    
    func searchTextChanged(_ searchText: String) {
        
        searchQuery.text = searchText
        redoSearchIfPossible()
    }
    
    @IBAction func searchFieldsChangedAction(_ sender: Any) {
        
        let searchFields = searchQuery.fields
        
        searchFields.name = searchByName.isOn
        searchFields.artist = searchByArtist.isOn
        searchFields.title = searchByTitle.isOn
        searchFields.album = searchByAlbum.isOn
        
        redoSearchIfPossible()
    }
    
    @IBAction func searchTypeChangedAction(_ sender: Any) {
        
        if comparisonType_equals.isOn {
            searchQuery.type = .equals
            
        } else if comparisonType_contains.isOn {
            searchQuery.type = .contains
            
        } else if comparisonType_beginsWith.isOn {
            searchQuery.type = .beginsWith
            
        } else {
            // Ends with
            searchQuery.type = .endsWith
        }
        
        redoSearchIfPossible()
    }
    
    @IBAction func searchOptionsChangedAction(_ sender: Any) {
        
        searchQuery.options.caseSensitive = searchCaseSensitive.isOn
        redoSearchIfPossible()
    }
}
