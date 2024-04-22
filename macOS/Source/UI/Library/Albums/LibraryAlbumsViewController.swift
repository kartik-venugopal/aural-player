//
//  LibraryAlbumsViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryAlbumsViewController: TrackListOutlineViewController {
    
    override var nibName: String? {"LibraryAlbums"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var lblAlbumsSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    private lazy var albumsGrouping: AlbumsGrouping = library.albumsGrouping
    override var grouping: Grouping! {albumsGrouping}
    
    override var trackList: GroupedSortedTrackListProtocol! {
        libraryDelegate
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribeAsync(to: .Library.tracksAdded, handler: tracksAdded(_:))
        messenger.subscribeAsync(to: .Library.tracksRemoved, handler: reloadTable)
        
        messenger.subscribeAsync(to: .Library.doneAddingTracks, handler: doneAddingTracks)
        
        messenger.subscribe(to: .Library.reloadTable, handler: reloadTable)
        messenger.subscribe(to: .Library.updateSummary, handler: updateSummary)
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainer)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceivers: [lblAlbumsSummary, lblDurationSummary])
        
        updateSummary()
    }
    
    func doneAddingTracks() {
        
        outlineView.reloadData()
        updateSummary()
    }
    
    override func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        
        if item is AlbumGroup {
            return 90
        }
        
        if item is AlbumDiscGroup {
            return 60
        }
        
        return 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .cid_Name:
            
            if let track = item as? Track,
               let cell = outlineView.makeView(withIdentifier: .cid_TrackName, owner: nil) as? AlbumTrackCellView {
                
                cell.update(forTrack: track)
                cell.rowSelectionStateFunction = {[weak outlineView, weak track] in outlineView?.isItemSelected(track as Any) ?? false}
                
                return cell
            }
            
            if let album = item as? AlbumGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_AlbumName, owner: nil) as? AlbumCellView {
                
                cell.update(forGroup: album)
                cell.rowSelectionStateFunction = {[weak outlineView, weak album] in outlineView?.isItemSelected(album as Any) ?? false}
                
                return cell
            }
            
            if let disc = item as? AlbumDiscGroup {
                
                return TableCellBuilder().withText(text: disc.name,
                                                   inFont: systemFontScheme.prominentFont,
                                                   andColor: systemColorScheme.secondaryTextColor,
                                                   selectedTextColor: systemColorScheme.secondarySelectedTextColor,
                                                   centerYOffset: systemFontScheme.tableYOffset)
                    .buildCell(forOutlineView: outlineView,
                               forColumnWithId: .cid_DiscName, havingItem: disc)
            }
            
        case .cid_Duration:
            
            if let track = item as? Track {
                
                return TableCellBuilder().withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                                   inFont: systemFontScheme.normalFont,
                                                   andColor: systemColorScheme.tertiaryTextColor,
                                                   selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                                   centerYOffset: systemFontScheme.tableYOffset)
                    .buildCell(forOutlineView: outlineView,
                               forColumnWithId: .cid_TrackDuration, havingItem: track)
            }
            
            if let album = item as? AlbumGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_AlbumDuration, owner: nil) as? GroupSummaryCellView {
                
                cell.update(forAlbumGroup: album)
                cell.rowSelectionStateFunction = {[weak outlineView, weak album] in outlineView?.isItemSelected(album as Any) ?? false}
                
                return cell
            }
            
            if let disc = item as? AlbumDiscGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_DiscDuration, owner: nil) as? GroupSummaryCellView {
                
                cell.update(forGroup: disc)
                cell.rowSelectionStateFunction = {[weak outlineView, weak disc] in outlineView?.isItemSelected(disc as Any) ?? false}
                
                return cell
            }
            
        default:
            
            return nil
        }
        
        return nil
    }
    
    override func updateSummary() {
        
        let numGroups = albumsGrouping.numberOfGroups
        let numTracks = library.size
        
        lblAlbumsSummary.stringValue = "\(numGroups) \(numGroups == 1 ? "album" : "albums"), \(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(library.duration)
    }
    
    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        
        lblCaption.font = systemFontScheme.captionFont
        [lblAlbumsSummary, lblDurationSummary].forEach {
            $0.font = systemFontScheme.smallFont
        }
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        rootContainer.fillColor = systemColorScheme.backgroundColor
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        lblAlbumsSummary.textColor = systemColorScheme.secondaryTextColor
        lblDurationSummary.textColor = systemColorScheme.secondaryTextColor
    }
}
