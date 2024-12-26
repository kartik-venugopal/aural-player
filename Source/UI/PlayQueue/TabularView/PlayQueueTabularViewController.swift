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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.customizeHeader(heightIncrease: 0, customCellType: PlayQueueTabularViewTableHeaderCell.self)
    }
    
    // MARK: Table view delegate / data source --------------------------------------------------------------------------------------------------------
    
    override func moveTracks(from sourceIndices: IndexSet, to destRow: Int) {
        
        super.moveTracks(from: sourceIndices, to: destRow)
        
        // Tell the other (sibling) table to refresh
        messenger.publish(.PlayQueue.refresh, payload: [PlayQueueView.expanded])
    }
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = trackList[row], let column = tableColumn?.identifier else {return nil}
        
        let builder = TableCellBuilder()
        
        switch column {
            
        case .cid_index:
            
            if track == playQueueDelegate.currentTrack {
                builder.withImage(image: .imgPlayFilled, inColor: systemColorScheme.activeControlColor)
                
            } else {
                builder.withText(text: "\(row + 1)",
                                        inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                        selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                        bottomYOffset: systemFontScheme.tableYOffset)
            }
            
        case .cid_title:
            
            let title = track.titleOrDefaultDisplayName
            
            builder.withText(text: title,
                             inFont: systemFontScheme.normalFont, andColor: systemColorScheme.primaryTextColor,
                             selectedTextColor: systemColorScheme.primarySelectedTextColor,
                             bottomYOffset: systemFontScheme.tableYOffset)
            
        case .cid_artist:
            
            guard let artist = track.artist else {return nil}
            
            builder.withText(text: artist,
                             inFont: systemFontScheme.normalFont, andColor: systemColorScheme.primaryTextColor,
                             selectedTextColor: systemColorScheme.primarySelectedTextColor,
                             bottomYOffset: systemFontScheme.tableYOffset)
            
        case .cid_duration:
            
            builder.withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                    inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                    selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                    bottomYOffset: systemFontScheme.tableYOffset)
            
        default:
            
            return nil
        }
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: column, inRow: row)
    }
}
