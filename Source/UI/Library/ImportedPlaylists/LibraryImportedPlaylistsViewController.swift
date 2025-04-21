//
//  LibraryImportedPlaylistsViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryImportedPlaylistsViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    override var nibName: NSNib.Name? {"LibraryImportedPlaylists"}
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var lblPlaylistsSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    private var selectedRows: IndexSet {outlineView.selectedRowIndexes}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribeAsync(to: .Library.doneAddingTracks, handler: doneAddingTracks)
//        messenger.subscribe(to: .Library.reloadTable, handler: reloadTable)
        messenger.subscribe(to: .Library.updateSummary, handler: updateSummary)
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceivers: [rootContainer, outlineView])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceivers: [lblPlaylistsSummary, lblDurationSummary])
        
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor], handler: textColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor], handler: selectedTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.textSelectionColor, handler: textSelectionColorChanged(_:))
        
        updateSummary()
    }
    
    func doneAddingTracks() {
        
        outlineView.reloadData()
        updateSummary()
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    // TODO: Implement the controls bar !!! Double-click action, sorting, etc
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        ((item as? ImportedPlaylist)?.size ?? -1) > 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        ((item as? ImportedPlaylist)?.size ?? -1) > 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return library.numberOfPlaylists
        }
        
        if let playlist = item as? ImportedPlaylist {
            return playlist.size
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil, let playlist = library.playlist(atIndex: index) {
            return playlist
        }
        
        if let playlist = item as? ImportedPlaylist, let track = playlist[index] {
            return IndexedTrack(track: track, index: index)
        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is ImportedPlaylist ? 60 : 30
    }
    
    // Returns a view for a single row
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .cid_Name:
            
            if let track = item as? IndexedTrack,
               let cell = outlineView.makeView(withIdentifier: .cid_TrackName, owner: nil) as? ImportedPlaylistTrackCellView {
                
                cell.update(forTrack: track.track, atIndex: track.index)
                cell.rowSelectionStateFunction = {[weak outlineView, weak track] in outlineView?.isItemSelected(track as Any) ?? false}
                
                return cell
            }
            
            if let playlist = item as? ImportedPlaylist,
               let cell = outlineView.makeView(withIdentifier: .cid_ImportedPlaylistName, owner: nil) as? ImportedPlaylistCellView {
                
                cell.update(forPlaylist: playlist)
                cell.rowSelectionStateFunction = {[weak outlineView, weak playlist] in outlineView?.isItemSelected(playlist as Any) ?? false}
                
                return cell
            }
            
        case .cid_Duration:
            
            if let track = item as? IndexedTrack {
                
                return TableCellBuilder().withText(text: ValueFormatter.formatSecondsToHMS(track.track.duration),
                                                   inFont: systemFontScheme.normalFont,
                                                   andColor: systemColorScheme.tertiaryTextColor,
                                                   selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                                   centerYOffset: systemFontScheme.tableYOffset)
                    .buildCell(forOutlineView: outlineView,
                               forColumnWithId: .cid_TrackDuration, havingItem: track)
            }
            
            if let playlist = item as? ImportedPlaylist,
               let cell = outlineView.makeView(withIdentifier: .cid_ImportedPlaylistDuration, owner: nil) as? GroupSummaryCellView {
                
                cell.update(forPlaylistGroup: playlist)
                cell.rowSelectionStateFunction = {[weak outlineView, weak playlist] in outlineView?.isItemSelected(playlist as Any) ?? false}
                
                return cell
            }
            
        default:
            return nil
        }
        
        return nil
    }
    
    func updateSummary() {
        
        let numGroups = library.numberOfPlaylists
        let numTracks = library.numberOfTracksInPlaylists
        
        lblPlaylistsSummary.stringValue = "\(numGroups) \(numGroups == 1 ? "playlist file" : "playlist files"), \(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(library.durationOfTracksInPlaylists)
    }
    
    @IBAction func doubleClickAction(_ sender: NSOutlineView) {
        
        let selectedItem = outlineView.selectedItem
        
        if let clickedPlaylist = selectedItem as? ImportedPlaylist {
            playQueue.enqueueToPlayNow(playlistFile: clickedPlaylist, clearQueue: false)
            
        } else if let clickedTrack = selectedItem as? IndexedTrack {
            playQueue.enqueueToPlayNow(tracks: [clickedTrack.track], clearQueue: false)
        }
    }
}

extension LibraryImportedPlaylistsViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        outlineView.reloadDataMaintainingSelection()
        lblCaption.font = systemFontScheme.captionFont
        [lblPlaylistsSummary, lblDurationSummary].forEach {
            $0.font = systemFontScheme.smallFont
        }
    }
}

extension LibraryImportedPlaylistsViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        outlineView.colorSchemeChanged()
        lblCaption.textColor = systemColorScheme.captionTextColor
        [lblPlaylistsSummary, lblDurationSummary].forEach {
            $0?.textColor = systemColorScheme.secondaryTextColor
        }
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
