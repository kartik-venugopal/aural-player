////
////  PlaylistNamesTableViewController.swift
////  Aural
////
////  Copyright © 2024 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////  
//
//import Foundation
//import AppKit
//
//class PlaylistNamesTableViewController: NSViewController {
//    
//    @IBOutlet weak var tableView: NSTableView!
////    @IBOutlet weak var playlistViewController: PlaylistContainerViewController!
//    
//    var tableViewController: PlaylistTracksViewController!
//    var controlsContainer: PlaylistControlsContainer!
//    
//    var selectedRows: IndexSet {tableView.selectedRowIndexes}
//    
//    var selectedRowCount: Int {tableView.numberOfSelectedRows}
//    
//    var rowCount: Int {tableView.numberOfRows}
//    
//    var lastRow: Int {tableView.numberOfRows - 1}
//    
//    var atLeastTwoRowsAndNotAllSelected: Bool {
//        
//        let rowCount = self.rowCount
//        return rowCount > 1 && (1..<rowCount).contains(selectedRowCount)
//    }
//    
//    lazy var messenger: Messenger = Messenger(for: self)
//    
//    private lazy var fileOpenDialog = DialogsAndAlerts.openFilesAndFoldersDialog
//    
//    override func viewDidLoad() {
//        
//        super.viewDidLoad()
//        
//        tableView.enableDragDrop()
//        
////        playlistViewController.playlist = nil
//        
//        messenger.subscribe(to: .playlists_createPlaylistFromTracks, handler: createPlaylistFromTracks(_:))
////        colorSchemesManager.registerObserver(tableView, forProperty: \.backgroundColor)
////        colorSchemesManager.registerObserver(self, forProperties: [\.primaryTextColor, \.primarySelectedTextColor, \.textSelectionColor])
//    }
//    
//    // MARK: Actions
//    
//    @IBAction func createEmptyPlaylistAction(_ sender: NSMenuItem) {
//        
//        _ = playlistsManager.createNewPlaylist(named: uniquePlaylistName)
//        tableView.noteNumberOfRowsChanged()
//        
//        let rowIndex = lastRow
//        tableView.selectRow(rowIndex)
//        editTextField(inRow: rowIndex)
//    }
//    
//    @IBAction func createPlaylistFromFilesAndFoldersAction(_ sender: NSMenuItem) {
//        
//        guard fileOpenDialog.runModal() == .OK else {return}
//        
//        _ = playlistsManager.createNewPlaylist(named: uniquePlaylistName)
//        tableView.noteNumberOfRowsChanged()
//        
//        let rowIndex = lastRow
//        tableView.selectRow(rowIndex)
//        
//        messenger.publish(.playlist_addChosenFiles, payload: fileOpenDialog.urls)
//        
//        editTextField(inRow: rowIndex)
//    }
//    
//    private var uniquePlaylistName: String {
//        
//        var newPlaylistName: String = "New Playlist"
//        var ctr: Int = 1
//        
//        while playlistsManager.userDefinedObjectExists(named: newPlaylistName) {
//            
//            ctr.increment()
//            newPlaylistName = "New Playlist \(ctr)"
//        }
//        
//        return newPlaylistName
//    }
//    
//    private func editTextField(inRow row: Int) {
//        
//        let rowView = tableView.rowView(atRow: row, makeIfNecessary: true)
//        
//        if let editedTextField = (rowView?.view(atColumn: 0) as? NSTableCellView)?.textField {
//            view.window?.makeFirstResponder(editedTextField)
//        }
//    }
//    
//    @IBAction func deleteSelectedPlaylistsAction(_ sender: NSButton) {
//        
//        let selectedRows = self.selectedRows
//        guard !selectedRows.isEmpty else {return}
//        
//        for row in selectedRows.sortedDescending() {
//            playlistsManager.deleteObject(atIndex: row)
//        }
//        
////        playlistViewController.playlist = nil
//        tableView.reloadData()
//    }
//    
//    @IBAction func renameSelectedPlaylistAction(_ sender: NSButton) {
//        
//        let selectedRows = self.selectedRows
//        guard selectedRows.count == 1, let selectedRow = selectedRows.first else {return}
//        
//        editTextField(inRow: selectedRow)
//    }
//    
//    @IBAction func duplicateSelectedPlaylistAction(_ sender: NSButton) {
//        
//        let selectedRows = self.selectedRows
//        guard selectedRows.count == 1, let selectedRow = selectedRows.first else {return}
//        
//        let selectedPlaylist = playlistsManager.userDefinedObjects[selectedRow]
//        var newPlaylistName: String = "\(selectedPlaylist.name) Copy"
//        var ctr: Int = 1
//        
//        while playlistsManager.userDefinedObjectExists(named: newPlaylistName) {
//            newPlaylistName = "\(selectedPlaylist.name) Copy \(ctr.incrementAndGet())"
//        }
//        
//        playlistsManager.duplicatePlaylist(selectedPlaylist, withName: newPlaylistName)
//        tableView.noteNumberOfRowsChanged()
//        tableView.selectRow(lastRow)
//    }
//    
//    @IBAction func sortByNameAscendingAction(_ sender: Any) {
//        
//        playlistsManager.sortUserDefinedObjects(by: {$0.name < $1.name})
//        tableView.reloadData()
//    }
//    
//    @IBAction func sortByNameDescendingAction(_ sender: Any) {
//        
//        playlistsManager.sortUserDefinedObjects(by: {$0.name > $1.name})
//        tableView.reloadData()
//    }
//    
//    @IBAction func sortByDateCreatedAscendingAction(_ sender: Any) {
//        
//        playlistsManager.sortUserDefinedObjects(by: {$0.dateCreated < $1.dateCreated})
//        tableView.reloadData()
//    }
//    
//    @IBAction func sortByDateCreatedDescendingAction(_ sender: Any) {
//        
//        playlistsManager.sortUserDefinedObjects(by: {$0.dateCreated > $1.dateCreated})
//        tableView.reloadData()
//    }
//    
//    // -------------------- Responding to notifications -------------------------------------------
//    
//    // Selects (and shows) a certain track within the playlist view
//    func selectPlaylist(at index: Int) {
//        
//        if index >= 0 && index < rowCount {
//            
//            tableView.selectRow(index)
//            tableView.scrollRowToVisible(index)
//        }
//    }
//    
//    func playlistsRemoved(from indices: IndexSet) {
//        
//        guard !indices.isEmpty else {return}
//        
//        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
//        tableView.noteNumberOfRowsChanged()
//        
//        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the playlist
//        guard let firstRemovedRow = indices.min() else {return}
//        
//        let lastRowAfterRemove = numberOfPlaylists - 1
//        
//        // This will be true unless a contiguous block of tracks was removed from the bottom of the playlist.
//        if firstRemovedRow <= lastRowAfterRemove {
//            tableView.reloadRows(firstRemovedRow...lastRowAfterRemove)
//        }
//    }
//    
//    private func createPlaylistFromTracks(_ tracks: [Track]) {
//        
//        let newPlaylistName = uniquePlaylistName
//        _ = playlistsManager.createNewPlaylist(named: newPlaylistName)
//        tableView.noteNumberOfRowsChanged()
//        
//        let rowIndex = lastRow
//        tableView.selectRow(rowIndex)
//        
//        messenger.publish(.playlist_copyTracks, payload: CopyTracksToPlaylistCommand(tracks: tracks, destinationPlaylistName: newPlaylistName))
//        
//        editTextField(inRow: rowIndex)
//        view.window?.makeKeyAndOrderFront(self)
//    }
//}
//
//extension PlaylistNamesTableViewController: ColorSchemePropertyObserver {
//    
//    func colorChanged(to newColor: PlatformColor, forProperty property: ColorSchemeProperty) {
//        
//        switch property {
//            
//        case \.primaryTextColor, \.primarySelectedTextColor:
//            
//            tableView.reloadDataMaintainingSelection()
//            
//        case \.textSelectionColor:
//            
//            tableView.redoRowSelection()
//            
//        default:
//            
//            return
//        }
//    }
//}
//
//extension NSUserInterfaceItemIdentifier {
//    
//    static let cid_playlistName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_PlaylistName")
//}
