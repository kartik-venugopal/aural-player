//
//  PlayQueueExpandedViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueExpandedViewController: PlayQueueViewController {
    
    override var playQueueView: PlayQueueView {
        .expanded
    }
    
    override var nibName: NSNib.Name? {"PlayQueueExpandedView"}
    
    override var rowHeight: CGFloat {50}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribeAsync(to: .PlayQueue.bulkCoverArtUpdate) {[weak self] (updatedTracks: [Int]) in
            self?.tableView.reloadRows(updatedTracks, columns: [0])
        }
    }
    
    // MARK: Table view delegate / data source --------------------------------------------------------------------------------------------------------
    
    override func moveTracks(from sourceIndices: IndexSet, to destRow: Int) {
        
        super.moveTracks(from: sourceIndices, to: destRow)

        // Tell the other (sibling) table to refresh
        messenger.publish(.PlayQueue.refresh, payload: [PlayQueueView.simple])
    }
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = track(forRow: row), let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .cid_art:
            
           return createArtCell(tableView: tableView, track: track)
            
        case .cid_trackName:
            
            return createTrackNameCell(tableView: tableView, track: track, row: row)
            
        case .cid_duration:
            
            return createDurationCell(tableView: tableView, track: track, row: row)
            
        default:
            
            return nil
        }
    }
    
    private func createArtCell(tableView: NSTableView, track: Track) -> PlayQueueListArtCell? {
        
        guard let cell = tableView.makeView(withIdentifier: .cid_art, owner: nil) as? PlayQueueListArtCell else {return nil}
        cell.updateForTrack(track, isPlayingTrack: playQueueDelegate.currentTrack == track)
        
        return cell
    }
    
    private func createTrackNameCell(tableView: NSTableView, track: Track, row: Int) -> PlayQueueListTrackNameCell? {
        
        guard let cell = tableView.makeView(withIdentifier: .cid_trackName, owner: nil) as? PlayQueueListTrackNameCell else {return nil}
        cell.updateForTrack(track)
        cell.rowSelectionStateFunction = {[weak tableView] in
            tableView?.selectedRowIndexes.contains(row) ?? false
        }
        
        return cell
    }
    
    private func createDurationCell(tableView: NSTableView, track: Track, row: Int) -> AuralTableCellView? {
        
        return TableCellBuilder().withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                           inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                           selectedTextColor: systemColorScheme.tertiarySelectedTextColor)
            .buildCell(forTableView: tableView, forColumnWithId: .cid_duration, inRow: row)
    }
}

class PlayQueueListTrackNameCell: NSTableCellView {
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var lblArtistAlbum: NSTextField!
    @IBOutlet weak var lblDefaultDisplayName: NSTextField!
    
    // Used to determine whether or not this cell is selected.
    var rowSelectionStateFunction: () -> Bool = {false}
    
    func updateForTrack(_ track: Track, needsTooltip: Bool = false) {
        
        [lblTitle, lblArtistAlbum, lblDefaultDisplayName].forEach {
            $0.font = systemFontScheme.normalFont
        }
        
        lblTitle.lineBreakMode = .byTruncatingTail
        lblTitle.usesSingleLineMode = true
        
        lblDefaultDisplayName.lineBreakMode = .byWordWrapping
        lblDefaultDisplayName.usesSingleLineMode = false
        
        lblArtistAlbum.lineBreakMode = .byTruncatingTail
        lblArtistAlbum.usesSingleLineMode = true
        
        backgroundStyleChanged()
        
        toolTip = nil
        
        if let title = track.title {
            
            if let artist = track.artist {
                
                if let album = track.album {
                    showTitleAndArtistAlbum(title: title, artistAlbumString: "\(artist) -- \(album)")
                    
                } else {
                    showTitleAndArtistAlbum(title: title, artistAlbumString: artist)
                }
                
                if needsTooltip, lblTitle.isTruncatingText || lblArtistAlbum.isTruncatingText {
                    
                    toolTip = "\(lblTitle.stringValue)\n\(lblArtistAlbum.stringValue)"
                    
                    if lblTitle.isTruncatingText {
                        print("title truncated, toolTip = \(self.toolTip)")
                    } else {
                        print("artist/album truncated, toolTip = \(self.toolTip)")
                    }
                }
                
            } else {
                
                if let album = track.album {
                    
                    showTitleAndArtistAlbum(title: title, artistAlbumString: album)
                    
                    if needsTooltip, lblTitle.isTruncatingText || lblArtistAlbum.isTruncatingText {
                        toolTip = "\(lblTitle.stringValue)\n\(lblArtistAlbum.stringValue)"
                    }
                    
                } else {
                    
                    showDefaultDisplayName(title)
                    
                    if needsTooltip, lblDefaultDisplayName.isTruncatingText {
                        toolTip = lblDefaultDisplayName.stringValue
                    }
                }
            }
            
        } else {
            
            showDefaultDisplayName(track.defaultDisplayName)
            
            if needsTooltip, lblDefaultDisplayName.isTruncatingText {
                toolTip = lblDefaultDisplayName.stringValue
            }
        }
    }
    
    private func showTitleAndArtistAlbum(title: String, artistAlbumString: String) {
        
        lblTitle.stringValue = title
        lblArtistAlbum.stringValue = artistAlbumString
        
        [lblTitle, lblArtistAlbum].forEach {
            $0?.show()
        }
        
        lblDefaultDisplayName.hide()
    }
    
    private func showDefaultDisplayName(_ displayName: String) {
        
        lblDefaultDisplayName.stringValue = displayName
        lblDefaultDisplayName.show()
        
        [lblTitle, lblArtistAlbum].forEach {
            $0?.hide()
        }
    }
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {backgroundStyleChanged()}
    }

    // Check if this row is selected, change font and color accordingly
    func backgroundStyleChanged() {
        
        if rowIsSelected {
            
            if lblTitle.isShown {
                
                lblTitle.textColor = systemColorScheme.primarySelectedTextColor
                lblArtistAlbum.textColor = systemColorScheme.secondarySelectedTextColor
                
            } else {
                lblDefaultDisplayName.textColor = systemColorScheme.primarySelectedTextColor
            }
            
        } else {
            
            if lblTitle.isShown {
                
                lblTitle.textColor = systemColorScheme.primaryTextColor
                lblArtistAlbum.textColor = systemColorScheme.secondaryTextColor
                
            } else {
                lblDefaultDisplayName.textColor = systemColorScheme.primaryTextColor
            }
        }
    }
}

class PlayQueueListArtCell: NSTableCellView {
    
    @IBOutlet weak var imgArt: NSImageView!
    @IBOutlet weak var imgPlayingTrackIndicator: NSImageView!
    
    func updateForTrack(_ track: Track, isPlayingTrack: Bool) {
        
        if isPlayingTrack {
            
            imgPlayingTrackIndicator.show()
            imgPlayingTrackIndicator.contentTintColor = systemColorScheme.activeControlColor
            
            imgArt.hide()
            
        } else {
            
            imgPlayingTrackIndicator.hide()
            imgArt.show()
            
            if let coverArt = track.art?.downscaledOrOriginalImage {
                imgArt.image = coverArt
                
            } else {
                
                imgArt.image = .imgPlayingArt
                imgArt.contentTintColor = systemColorScheme.secondaryTextColor
            }
        }
    }
}
