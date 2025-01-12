//
//  TrackListTableViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class TrackListTableViewController: NSViewController, NSTableViewDelegate, FontSchemeObserver, ColorSchemeObserver {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var sortOrderMenuItemView: SortOrderMenuItemView!
    
    // Override this !
    var trackList: TrackListProtocol! {nil}
    
    lazy var hasIndexColumn: Bool = {
        tableView.tableColumns[0].identifier == .cid_index
    }()
    
    var selectedRows: IndexSet {tableView.selectedRowIndexes}
    
    var invertedSelection: IndexSet {tableView.invertedSelection}
    
    var selectedTracks: [Track] {trackList[tableView.selectedRowIndexes]}
    
    var selectedRowCount: Int {tableView.numberOfSelectedRows}
    
    var selectedRowView: NSView? {
        return tableView.rowView(atRow: tableView.selectedRow, makeIfNecessary: false)
    }
    
    var rowCount: Int {tableView.numberOfRows}
    
    var lastRow: Int {tableView.numberOfRows - 1}
    
    var atLeastTwoRowsAndNotAllSelected: Bool {
        
        let rowCount = self.rowCount
        return rowCount > 1 && (1..<rowCount).contains(selectedRowCount)
    }
    
    lazy var fileOpenDialog = DialogsAndAlerts.openFilesAndFoldersDialog
    lazy var saveDialog = DialogsAndAlerts.savePlaylistDialog
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.enableDragDrop()
        
        tableView.enclosingScrollView?.scrollerStyle = .legacy
        tableView.enclosingScrollView?.autohidesScrollers = false
        tableView.enclosingScrollView?.hasVerticalScroller = true
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: tableView)
        
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor],
                                                     handler: textColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor],
                                                     handler: selectedTextColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.textSelectionColor,
                                                     handler: textSelectionColorChanged(_:))
    }
    
    // ---------------- NSTableViewDataSource --------------------
    
    func importTracks(_ sourceTracks: [Track], to destRow: Int) {
        _ = trackList.insertTracks(sourceTracks, at: destRow)
    }
    
//    func importPlaylists(_ sourcePlaylists: [Playlist], to destRow: Int) {
//        importTracks(sourcePlaylists.flatMap {$0.tracks}, to: destRow)
//    }
    
    // ---------------- NSTableViewDelegate --------------------
    
    var rowHeight: CGFloat {25}
    
    var numberOfTracks: Int {
        trackList?.size ?? 0
    }
    
    var isTrackListBeingModified: Bool {false}
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {rowHeight}
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    func track(forRow row: Int) -> Track? {
        trackList[row]
    }
    
    // Returns a view for a single column
    @objc dynamic func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = track(forRow: row), let columnId = tableColumn?.identifier else {return nil}
        
        let cell = view(forColumn: columnId, row: row, track: track)
            .buildCell(forTableView: tableView, forColumnWithId: columnId, inRow: row)
        
        cell?.textField?.lineBreakMode = .byTruncatingTail
        cell?.textField?.usesSingleLineMode = true
        cell?.textField?.cell?.truncatesLastVisibleLine = true
        
        cell?.rowSelectionStateFunction = {[weak tableView] in
            tableView?.selectedRowIndexes.contains(row) ?? false
        }
        
        return cell
    }
    
    // Returns a view for a single column
    func view(forColumn column: NSUserInterfaceItemIdentifier, row: Int, track: Track) -> TableCellBuilder {
        TableCellBuilder()
    }
    
    // --------------------- Responding to commands ------------------------------------------------
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    func importFilesAndFolders() {
        
        if fileOpenDialog.runModal() == .OK {
            trackList.loadTracks(from: fileOpenDialog.urls)
        }
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    func addChosenTracks(_ files: [URL]) {
        trackList.loadTracks(from: files)
    }
    
    func removeTracks() {
        
        _ = trackList.removeTracks(at: selectedRows)
        clearSelection()
        // TODO: Publish a notif with the removed track indices so that sibling TrackList Table VCs can refresh (and self).
        updateSummary()
    }
    
    /// Override this !
    func updateSummary() {}
    
    func noteNumberOfRowsChanged() {
        tableView.noteNumberOfRowsChanged()
    }
    
    func reloadTableRows(_ rows: ClosedRange<Int>) {
        tableView.reloadRows(rows)
    }
    
    func cropSelection() {
        
        guard selectedRows.isNonEmpty else {return}
        
        trackList.cropTracks(at: selectedRows)
        notifyReloadTable()
        updateSummary()
    }
    
    @objc func notifyReloadTable() {}
    
    func removeAllTracks() {
        
        trackList.removeAllTracks()
        notifyReloadTable()
        updateSummary()
    }
    
    @inlinable
    @inline(__always)
    func reloadTable() {
        
        tableView.reloadData()
        updateSummary()
    }
    
    // MARK: Table view selection manipulation
    
    @inlinable
    @inline(__always)
    func selectAll() {
        tableView.selectAllItems()
    }
    
    @inlinable
    @inline(__always)
    func clearSelection() {
        tableView.clearSelection()
    }
    
    @inlinable
    @inline(__always)
    func invertSelection() {
        tableView.invertSelection()
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    func exportTrackList() {
        
        // Make sure there is at least one track to save.
        guard trackList.size > 0, !checkIfTrackListIsBeingModified() else {return}

        if saveDialog.runModal() == .OK, let playlistFile = saveDialog.url {
            trackList.exportToFile(playlistFile)
        }
    }
    
    private func checkIfTrackListIsBeingModified() -> Bool {
        
        let trackListBeingModified = trackList.isBeingModified

        if trackListBeingModified {

            NSAlert.showError(withTitle: "\(trackList.displayName) was not modified",
                              andText: "\(trackList.displayName) cannot be modified while tracks are being added. Please wait ...")
        }

        return trackListBeingModified
    }
    
    func doSort(by fields: [TrackSortField]) {
        
        trackList.sort(TrackListSort(fields: fields, order: sortOrderMenuItemView.sortOrder))
        notifyReloadTable()
    }
    
    func sort(by fields: [TrackSortField], order: SortOrder) {
        
        trackList.sort(TrackListSort(fields: fields, order: order))
        notifyReloadTable()
    }
    
    // -------------------- Responding to notifications -------------------------------------------
    
    // Selects (and shows) a certain track within the playlist view
    func selectTrack(at index: Int) {
        
        guard index >= 0 && index < rowCount else {return}
        
        tableView.selectRow(index)
        tableView.scrollRowToVisible(index)
    }
    
    func selectRows(_ rows: Range<Int>) {
        tableView.selectRows(rows)
    }
    
    func selectRows(_ rows: ClosedRange<Int>) {
        tableView.selectRows(rows)
    }
    
    func selectRows(_ rows: [Int]) {
        tableView.selectRows(rows)
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksUp() {

        if atLeastTwoRowsAndNotAllSelected {
            doMoveTracksUp()
        }
    }
    
    func doMoveTracksUp() {
        
        let results = trackList.moveTracksUp(from: selectedRows)
        
        moveAndReloadItems(results.sorted(by: <))
        
        if let minRow = selectedRows.min() {
            tableView.scrollRowToVisible(minRow)
        }
    }

    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksDown() {
        
        if atLeastTwoRowsAndNotAllSelected {
            doMoveTracksDown()
        }
    }
    
    func doMoveTracksDown() {

        let results = trackList.moveTracksDown(from: selectedRows)
        
        moveAndReloadItems(results.sorted(by: >))
        
        if let maxRow = selectedRows.max() {
            tableView.scrollRowToVisible(maxRow)
        }
    }

    // Rearranges tracks within the view that have been reordered
    func moveAndReloadItems(_ results: [TrackMoveResult]) {

        for result in results {

            tableView.moveRow(at: result.sourceIndex, to: result.destinationIndex)
            tableView.reloadRows([result.sourceIndex, result.destinationIndex])
        }
    }

    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksToTop() {
        
        if atLeastTwoRowsAndNotAllSelected {
            doMoveTracksToTop()
        }
    }
    
    func doMoveTracksToTop() {
        
        let selectedRows = self.selectedRows
        let results = trackList.moveTracksToTop(from: selectedRows)
        
        // Move the rows
        removeAndInsertItems(results.sorted(by: <))
        
        // Refresh the relevant rows
        guard let maxSelectedRow = selectedRows.max() else {return}
        
        tableView.reloadRows(0...maxSelectedRow)
        
        // Select all the same rows but now at the top
        tableView.scrollToTop()
        tableView.selectRows(0..<selectedRows.count)
    }

    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksToBottom() {
        
        if atLeastTwoRowsAndNotAllSelected {
            doMoveTracksToBottom()
        }
    }
    
    func doMoveTracksToBottom() {
        
        let selectedRows = self.selectedRows
        let results = trackList.moveTracksToBottom(from: selectedRows)
        
        // Move the rows
        removeAndInsertItems(results.sorted(by: >))
        
        guard let minSelectedRow = selectedRows.min() else {return}
        
        let lastRow = self.lastRow
        
        // Refresh the relevant rows
        tableView.reloadRows(minSelectedRow...lastRow)
        
        // Select all the same items but now at the bottom
        let firstSelectedRow = lastRow - selectedRows.count + 1
        tableView.selectRows(firstSelectedRow...lastRow)
        tableView.scrollToBottom()
    }
    
    func scrollRowToVisible(_ row: Int) {
        tableView.scrollRowToVisible(row)
    }
    
    func pageUp() {
        tableView.pageUp()
    }
    
    func pageDown() {
        tableView.pageDown()
    }
    
    func scrollToTop() {
        tableView.scrollToTop()
    }
    
    func scrollToBottom() {
        tableView.scrollToBottom()
    }

    // Refreshes the playlist view by rearranging the items that were moved
    func removeAndInsertItems(_ results: [TrackMoveResult]) {

        for result in results {

            tableView.removeRows(at: IndexSet(integer: result.sourceIndex), withAnimation: result.movedUp ? .slideUp : .slideDown)
            tableView.insertRows(at: IndexSet(integer: result.destinationIndex), withAnimation: result.movedUp ? .slideDown : .slideUp)
        }
    }
    
    func tracksAdded(at indices: IndexSet) {
        
        guard indices.isNonEmpty else {return}
        
        tableView.noteNumberOfRowsChanged()
        tableView.reloadRows(indices.min()!..<numberOfTracks)
    }
    
    func tracksAppended() {
        tableView.noteNumberOfRowsChanged()
    }
    
    func fontSchemeChanged() {
        
        tableView.reloadDataMaintainingSelection()
        updateSummary()
    }
    
    func colorSchemeChanged() {
        
        tableView.colorSchemeChanged()
        updateSummary()
    }
    
    func textColorChanged(_ newColor: NSColor) {
        tableView.reloadDataMaintainingSelection()
    }
    
    func selectedTextColorChanged(_ newColor: NSColor) {
        tableView.reloadRows(selectedRows)
    }
    
    func textSelectionColorChanged(_ newColor: NSColor) {
        tableView.redoRowSelection()
    }
}

extension TrackListTableViewController: ThemeInitialization {
    
    @objc func initTheme() {
        
        tableView.colorSchemeChanged()
        updateSummary()
    }
}
