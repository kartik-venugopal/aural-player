//
//  PlayQueueTabularViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueTabularViewController: PlayQueueViewController {
    
    override var nibName: NSNib.Name? {"PlayQueueTabularView"}
    
    override var playQueueView: PlayQueueView {
        .tabular
    }
    
    override var rowHeight: CGFloat {30}
    
    // MARK: Table view delegate / data source --------------------------------------------------------------------------------------------------------
    
    override func moveTracks(from sourceIndices: IndexSet, to destRow: Int) {
        
        super.moveTracks(from: sourceIndices, to: destRow)
        
        // Tell the other (sibling) table to refresh
        messenger.publish(.PlayQueue.refresh, payload: [PlayQueueView.expanded])
    }
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = trackList[row], let column = tableColumn?.identifier else {return nil}
        
        switch column {
            
        case .cid_index:
            
            let builder = TableCellBuilder()
            
            if track == playQueueDelegate.currentTrack {
                builder.withImage(image: .imgPlayFilled, inColor: systemColorScheme.activeControlColor)
                
            } else {
                builder.withText(text: "\(row + 1)",
                                        inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                        selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                        bottomYOffset: systemFontScheme.tableYOffset)
            }
            
            return builder.buildCell(forTableView: tableView, forColumnWithId: column, inRow: row)
            
        case .cid_trackName:
            
            let titleAndArtist = track.titleAndArtist
            guard let cell = tableView.makeView(withIdentifier: .cid_trackName, owner: nil) as? AttrCellView else {return nil}
            
            if let artist = titleAndArtist.artist {
                cell.update(artist: artist, title: titleAndArtist.title)
                
            } else {
                cell.update(title: titleAndArtist.title)
            }
            
            cell.realignTextBottom(yOffset: systemFontScheme.tableYOffset)
            
            cell.row = row
            cell.rowSelectionStateFunction = {[weak tableView] in
                tableView?.selectedRowIndexes.contains(row) ?? false
            }
            
            return cell
            
        case .cid_duration:
            
            let builder = TableCellBuilder()
            
            builder.withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                    inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                    selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                    bottomYOffset: systemFontScheme.tableYOffset)
            
            return builder.buildCell(forTableView: tableView, forColumnWithId: column, inRow: row)
            
        default:
            
            return nil
        }
    }
}
