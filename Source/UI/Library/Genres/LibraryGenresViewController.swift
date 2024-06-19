//
//  LibraryGenresViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryGenresViewController: TrackListOutlineViewController {
    
    override var nibName: NSNib.Name? {"LibraryGenres"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var lblGenresSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    private lazy var genresGrouping: GenresGrouping = library.genresGrouping
    override var grouping: Grouping! {genresGrouping}
    
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
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceivers: [lblGenresSummary, lblDurationSummary])
        
        updateSummary()
    }
    
    func doneAddingTracks() {
        
        outlineView.reloadData()
        updateSummary()
    }
    
    override func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is Group ? 60 : 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .cid_Name:
            
            if let track = item as? Track,
               let cell = outlineView.makeView(withIdentifier: .cid_TrackName, owner: nil) as? GenreTrackCellView {
                
                cell.update(forTrack: track)
                cell.rowSelectionStateFunction = {[weak outlineView, weak track] in outlineView?.isItemSelected(track as Any) ?? false}
                
                return cell
            }
            
            if let artist = item as? ArtistGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_ArtistName, owner: nil) as? ArtistCellView {
                
                cell.update(forGroup: artist)
                cell.rowSelectionStateFunction = {[weak outlineView, weak artist] in outlineView?.isItemSelected(artist as Any) ?? false}
                
                return cell
            }
            
            if let genre = item as? GenreGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_GenreName, owner: nil) as? GenreCellView {
                
                cell.update(forGroup: genre)
                cell.rowSelectionStateFunction = {[weak outlineView, weak genre] in outlineView?.isItemSelected(genre as Any) ?? false}
                
                return cell
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
            
            if let artist = item as? ArtistGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_ArtistDuration, owner: nil) as? GroupSummaryCellView {
                
                cell.update(forArtistGroup: artist, showAlbumsCount: false)
                cell.rowSelectionStateFunction = {[weak outlineView, weak artist] in outlineView?.isItemSelected(artist as Any) ?? false}
                
                return cell
            }
            
            if let genre = item as? GenreGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_GenreDuration, owner: nil) as? GroupSummaryCellView {
                
                cell.update(forGenreGroup: genre)
                cell.rowSelectionStateFunction = {[weak outlineView, weak genre] in outlineView?.isItemSelected(genre as Any) ?? false}
                
                return cell
            }
            
        default:
            
            return nil
        }
        
        return nil
    }
    
    override func updateSummary() {
        
        let numGroups = genresGrouping.numberOfGroups
        let numTracks = library.size
        
        lblGenresSummary.stringValue = "\(numGroups) \(numGroups == 1 ? "genre" : "genres"), \(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(library.duration)
    }
    
    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        
        lblCaption.font = systemFontScheme.captionFont
        [lblGenresSummary, lblDurationSummary].forEach {
            $0.font = systemFontScheme.smallFont
        }
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        rootContainer.fillColor = systemColorScheme.backgroundColor
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        lblGenresSummary.textColor = systemColorScheme.secondaryTextColor
        lblDurationSummary.textColor = systemColorScheme.secondaryTextColor
    }
}
