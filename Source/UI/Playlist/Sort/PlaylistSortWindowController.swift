//
//  PlaylistSortWindowController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Window controller for the playlist sort dialog
 */
class PlaylistSortWindowController: NSWindowController, ModalDialogDelegate, Destroyable {
    
    @IBOutlet weak var container: NSBox!
    
    private var tracksPlaylistSortView: SortViewProtocol = TracksPlaylistSortViewController()
    private var artistsPlaylistSortView: SortViewProtocol = ArtistsPlaylistSortViewController()
    private var albumsPlaylistSortView: SortViewProtocol = AlbumsPlaylistSortViewController()
    private var genresPlaylistSortView: SortViewProtocol = GenresPlaylistSortViewController()
    
    // Delegate that relays sort requests to the playlist
    private let playlist: PlaylistDelegateProtocol = objectGraph.playlistDelegate
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {"PlaylistSortDialog"}
    
    private var displayedSortView: SortViewProtocol!
    
    private lazy var messenger = Messenger(for: self)
    
    private lazy var uiState: PlaylistUIState = objectGraph.playlistUIState
    
    override func windowDidLoad() {
        
        container.addSubviews(tracksPlaylistSortView.sortView, artistsPlaylistSortView.sortView, albumsPlaylistSortView.sortView, genresPlaylistSortView.sortView)
        
        [tracksPlaylistSortView, artistsPlaylistSortView, albumsPlaylistSortView, genresPlaylistSortView].forEach {$0.resetFields()}
    }
    
    var isModal: Bool {window?.isVisible ?? false}
    
    func showDialog() -> ModalDialogResponse {
        
        // Don't do anything if either no tracks or only 1 track in playlist
        guard playlist.size >= 2 else {return .cancel}
        
        forceLoadingOfWindow()
        
        // Choose sort view based on current playlist view
        NSView.hideViews(tracksPlaylistSortView.sortView, artistsPlaylistSortView.sortView, albumsPlaylistSortView.sortView, genresPlaylistSortView.sortView)
        
        switch uiState.currentView {

        case .tracks:       displayedSortView = tracksPlaylistSortView
            
        case .artists:      displayedSortView = artistsPlaylistSortView
            
        case .albums:       displayedSortView = albumsPlaylistSortView
            
        case .genres:       displayedSortView = genresPlaylistSortView

        }
        
        displayedSortView.sortView.show()
        
        theWindow.showCenteredOnScreen()
        return modalDialogResponse
    }
    
    @IBAction func sortBtnAction(_ sender: Any) {
        
        let playlistType = displayedSortView.playlistType

        // Perform the sort
        playlist.sort(displayedSortView.sortOptions, playlistType)
        
        // Notify playlist views
        messenger.publish(.playlist_refresh,
                          payload: PlaylistViewSelector.selector(forView: playlistType))
        
        modalDialogResponse = .ok
        theWindow.close()
    }
    
    @IBAction func sortCancelBtnAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        theWindow.close()
    }
}

// Contract for a constituent view of the playlist sort dialog.
protocol SortViewProtocol {
    
    // The actual displayed view
    var sortView: NSView {get}
    
    // The set of sort options selected within this view
    var sortOptions: Sort {get}
    
    // The playlist type associated with this view.
    var playlistType: PlaylistType {get}
    
    // Resets fields each time this view is about to be displayed.
    func resetFields()
}
