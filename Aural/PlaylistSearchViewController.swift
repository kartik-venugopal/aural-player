/*
    View controller for the playlist search modal dialog
 */

import Cocoa

class PlaylistSearchViewController: NSViewController, MessageSubscriber {
    
    // Playlist search modal dialog fields
    
    @IBOutlet weak var searchPanel: NSPanel!
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
    
    @IBOutlet weak var playlistView: NSTableView!
    
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    private var searchQuery: SearchQuery = SearchQuery(text: "")
    
    // Current playlist search results
    private var searchResults: SearchResults?
    
    override func viewDidLoad() {
        searchPanel.titlebarAppearsTransparent = true
        SyncMessenger.subscribe(.searchTextChangedNotification, subscriber: self)
    }
    
    @IBAction func searchPlaylistAction(_ sender: Any) {
        
        // Don't do anything if no tracks in playlist
        if (playlistView.numberOfRows == 0) {
            return
        }
        
        searchField.stringValue = ""
        resetSearchFields()
        searchPanel.makeFirstResponder(searchField)
        
        UIUtils.showModalDialog(searchPanel)
    }
    
    // Called when any of the search criteria have changed, performs a new search
    private func updateSearch() {
        
        searchResults = playlist.search(searchQuery)
        
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
        selectTrack(searchResult.trackIndex)
        
        let numResults = (searchResults?.count)!
        let resultsText = numResults == 1 ? "result found" : "results found"
        searchResultsSummaryLabel.stringValue = String(format: "%d %@. Selected %d / %d", numResults, resultsText, searchResult.resultIndex, numResults)
        
        searchResultMatchInfo.stringValue = String(format: "Matched %@: '%@'", searchResult.match.fieldKey, searchResult.match.fieldValue)
        
        btnNextSearch.isHidden = !searchResult.hasNext
        btnPreviousSearch.isHidden = !searchResult.hasPrevious
    }
    
    // Selects a track within the playlist view, to show the user where the track is located within the playlist
    private func selectTrack(_ index: Int) {
        
        playlistView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        playlistView.scrollRowToVisible(playlistView.selectedRow)
    }
    
    @IBAction func searchDoneAction(_ sender: Any) {
        UIUtils.dismissModalDialog()
        // FIXME: TODO: Clear the search query variable (bug)
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
        
        searchFields.name = Bool(searchByName.state)
        searchFields.artist = Bool(searchByArtist.state)
        searchFields.title = Bool(searchByTitle.state)
        searchFields.album = Bool(searchByAlbum.state)
        
        // No fields to compare, don't do the search
        if (searchFields.noFieldsSelected()) {
            resetSearchFields()
            return
        }
        
        updateSearch()
    }
    
    @IBAction func searchTypeChangedAction(_ sender: Any) {
        
        if (comparisonTypeEquals.state == 1) {
            searchQuery.type = .equals
        } else if (comparisonTypeContains.state == 1) {
            searchQuery.type = .contains
        } else if (comparisonTypeBeginsWith.state == 1) {
            searchQuery.type = .beginsWith
        } else {
            // Ends with
            searchQuery.type = .endsWith
        }
        
        updateSearch()
    }
    
    @IBAction func searchOptionsChangedAction(_ sender: Any) {
        
        searchQuery.options.caseSensitive = Bool(searchCaseSensitive.state)
        updateSearch()
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is SearchTextChangedNotification) {
            searchTextChanged()
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
}
