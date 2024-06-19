//
//  LibraryOutlineViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryOutlineViewController: NSViewController, NSOutlineViewDelegate, FontSchemeObserver, ColorSchemeObserver {
    
    @IBOutlet weak var outlineView: NSOutlineView!

    @IBOutlet weak var sortMenu: NSMenu!
    @IBOutlet weak var sortView: LibrarySortView!
    
    /// Override this !
    var trackList: GroupedSortedTrackListProtocol! {nil}
    
    /// Override this !
    var grouping: Grouping! {nil}
    
    var selectedRows: IndexSet {outlineView.selectedRowIndexes}
    
    var invertedSelection: IndexSet {outlineView.invertedSelection}
    
    var selectedRowCount: Int {outlineView.numberOfSelectedRows}
    
    var selectedRowView: NSView? {
        return outlineView.rowView(atRow: outlineView.selectedRow, makeIfNecessary: false)
    }
    
    var rowCount: Int {outlineView.numberOfRows}
    
    var lastRow: Int {outlineView.numberOfRows - 1}
    
    var atLeastTwoRowsAndNotAllSelected: Bool {
        
        let rowCount = self.rowCount
        return rowCount > 1 && (1..<rowCount).contains(selectedRowCount)
    }
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    lazy var fileOpenDialog = DialogsAndAlerts.openFilesAndFoldersDialog
    lazy var saveDialog = DialogsAndAlerts.savePlaylistDialog
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        outlineView.enableDragDrop()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: outlineView)
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor], handler: textColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor], handler: selectedTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.textSelectionColor, handler: textSelectionColorChanged(_:))
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    func colorChanged(to newColor: NSColor, forProperty property: ColorSchemeProperty) {
        
        if property == \.backgroundColor {
            outlineView.setBackgroundColor(newColor)
        }
    }
    
    // MARK: NSOutlineViewDelegate
    
    // Returns a view for a single row
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    // Determines the height of a single row
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is Group ? 100 : 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        !(item is AlbumDiscGroup)
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is Group
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {
        
        guard let group = notification.userInfo?.values.first as? Group,
              group.hasSubGroups else {return}
        
        outlineView.expandItem(group, expandChildren: true)
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func outlineView(_ outlineView: NSOutlineView, typeSelectStringFor tableColumn: NSTableColumn?, item: Any) -> String? {
        
        // Only the track name column is used for type selection
        guard tableColumn?.identifier == .cid_trackName, let displayName = (item as? Track)?.displayName ?? (item as? Group)?.name else {return nil}
        
        if !(displayName.starts(with: "<") || displayName.starts(with: ">")) {
            return displayName
        }
        
        return nil
    }
    
    @IBAction func removeSelectedItemsAction(_ sender: AnyObject) {
        removeSelectedItems()
    }
    
    func removeSelectedItems() {
        
        let selectedItems = outlineView.selectedItems
        var groups: Set<Group> = Set()
        var groupedTracks: [GroupedTrack] = []
        
        for item in selectedItems {
            
            if let group = item as? Group {
                groups.insert(group)
                
            } else if let track = item as? Track {
                
                guard let parentGroup = outlineView.parent(forItem: track) as? Group else {continue}
                
                // If the parent group is already going to be deleted, no need to remove the track.
                if !groups.contains(parentGroup) {
                    groupedTracks.append(GroupedTrack(track: track, group: parentGroup, trackIndex: -1, groupIndex: -1))    // Indices not important.
                }
            }
        }
        
        _ = trackList.remove(tracks: groupedTracks, andGroups: Array(groups), from: grouping)
    }
    
    func notifyReloadTable() {
        messenger.publish(.Library.reloadTable)
    }
    
    @IBAction func removeAllTracksAction(_ sender: NSButton) {
        removeAllTracks()
    }
    
    func removeAllTracks() {
        
        trackList.removeAllTracks()
        notifyReloadTable()
    }
    
    @IBAction func cropTracksAction(_ sender: NSButton) {
        cropTracks()
    }
    
    func cropTracks() {
        
        let selectedItems = outlineView.selectedItems
        
        if selectedItems.isEmpty {return}
        
        // NOTE - We don't have to worry about duplicate tracks. The track list / groupings will eliminate duplicates.
        var selTracks: [Track] = []

        for item in selectedItems {
            
            if let group = item as? Group {
                selTracks.append(contentsOf: group.tracks)
                
            } else if let track = item as? Track {
                selTracks.append(track)
            }
        }
        
        trackList.cropTracks(selTracks)
        notifyReloadTable()
    }
    
    @inlinable
    @inline(__always)
    func reloadTable() {
        
        outlineView.reloadData()
        updateSummary()
    }
    
    /// Override this !
    func updateSummary() {}
    
    @IBAction func playNowAction(_ sender: AnyObject) {
        
        guard let item = outlineView.selectedItem else {return}
        
        if let track = item as? Track {
            playQueueDelegate.enqueueToPlayNow(tracks: [track], clearQueue: false)
            
        } else if let group = item as? Group {
            playQueueDelegate.enqueueToPlayNow(group: group, clearQueue: false)
        }
    }
    
    @IBAction func expandAllGroupsAction(_ sender: AnyObject) {
        outlineView.expandItem(nil, expandChildren: true)
    }
    
    @IBAction func collapseAllGroupsAction(_ sender: AnyObject) {
        outlineView.collapseItem(nil, collapseChildren: true)
    }
    
    @IBAction func importFilesAndFoldersAction(_ sender: NSButton) {
        importFilesAndFolders()
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    func importFilesAndFolders() {
        
        if !trackList.isBeingModified, fileOpenDialog.runModal() == .OK {
            trackList.loadTracks(from: fileOpenDialog.urls)
        }
    }
    
    // Refreshes the playlist view in response to a new track being added to the playlist
    func tracksAdded(_ notification: LibraryTracksAddedNotification) {
        
        let selectedItems = outlineView.selectedItems
        
        //        guard let results = notification.groupingResults[artistsGrouping] else {return}
        //
        //        var groupsToReload: Set<Group> = Set()
        //
        //        for result in results {
        //
        //            if result.groupCreated {
        //
        //                // Insert the new group
        //                outlineView.insertItems(at: IndexSet(integer: result.track.groupIndex), inParent: nil, withAnimation: .effectFade)
        //
        //            } else {
        //
        //                // Insert the new track under its parent group, and reload the parent group
        //                let group = result.track.group
        //                groupsToReload.insert(group)
        //
        //                outlineView.insertItems(at: IndexSet(integer: result.track.trackIndex), inParent: group, withAnimation: .effectGap)
        //            }
        //        }
        //
        //        for group in groupsToReload {
        //            outlineView.reloadItem(group, reloadChildren: true)
        //        }
        
        outlineView.reloadData()
        outlineView.selectItems(selectedItems)
        
        updateSummary()
    }
    
    // MARK: Table view selection manipulation
    
    @IBAction func clearSelectionAction(_ sender: NSButton) {
        clearSelection()
    }
    
    @inlinable
    @inline(__always)
    func clearSelection() {
        outlineView.clearSelection()
    }
    
    @IBAction func invertSelectionAction(_ sender: NSButton) {
        invertSelection()
    }
    
    @inlinable
    @inline(__always)
    func invertSelection() {
        outlineView.invertSelection()
    }
    
    @IBAction func sortAction(_ sender: NSButton) {
        sort(by: sortView.sort)
    }
    
    func sort(by sort: GroupedTrackListSort) {
        
        guard sort.groupSort != nil || sort.trackSort != nil else {return}
        
        library.sort(grouping: grouping, by: sort)
        outlineView.reloadData()
        
        DispatchQueue.main.async {
            self.sortMenu.cancelTracking()
        }
    }
    
    @IBAction func cancelSortAction(_ sender: NSButton) {
        sortMenu.cancelTracking()
    }
    
    @IBAction func exportToPlaylistAction(_ sender: NSButton) {
        exportTrackList()
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
    
    @IBAction func pageUpAction(_ sender: NSButton) {
        pageUp()
    }
    
    @IBAction func pageDownAction(_ sender: NSButton) {
        pageDown()
    }
    
    @IBAction func scrollToTopAction(_ sender: NSButton) {
        scrollToTop()
    }
    
    @IBAction func scrollToBottomAction(_ sender: NSButton) {
        scrollToBottom()
    }
    
    func pageUp() {
        outlineView.pageUp()
    }
    
    func pageDown() {
        outlineView.pageDown()
    }
    
    func scrollToTop() {
        outlineView.scrollToTop()
    }
    
    func scrollToBottom() {
        outlineView.scrollToBottom()
    }
    
    // MARK: Theming --------------------------------------------------------------------------------
    
    func fontSchemeChanged() {
        outlineView.reloadDataMaintainingSelection()
    }
    
    func colorSchemeChanged() {
        outlineView.colorSchemeChanged()
    }
    
    func textColorChanged(_ newColor: NSColor) {
        outlineView.reloadDataMaintainingSelection()
    }
    
    func selectedTextColorChanged(_ newColor: NSColor) {
        outlineView.reloadRows(selectedRows)
    }
    
    func textSelectionColorChanged(_ newColor: NSColor) {
        outlineView.redoRowSelection()
    }
}
