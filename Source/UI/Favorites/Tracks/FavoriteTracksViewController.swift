//
//  FavoriteTracksViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteTracksViewController: FavoritesTableViewController {
    
    override var nibName: NSNib.Name? {"FavoriteTracks"}
    
    // Override this !!!
    @objc override var numberOfFavorites: Int {
        favoritesDelegate.numberOfFavoriteTracks
    }
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let columnId = tableColumn?.identifier,
              columnId == .cid_favoriteColumn,
              let track = favoritesDelegate.favoriteTrack(atChronologicalIndex: row)?.track else {return nil}
        
        let titleAndArtist = track.titleAndArtist
        let builder = TableCellBuilder()
        
        if let artist = titleAndArtist.artist {
            
            builder.withAttributedText(strings: [(text: artist + "  ", font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor),
                                                        (text: titleAndArtist.title, font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor)],
                                              selectedTextColors: [systemColorScheme.secondarySelectedTextColor, systemColorScheme.primarySelectedTextColor],
                                              bottomYOffset: systemFontScheme.tableYOffset)
            
        } else {
            
            builder.withAttributedText(strings: [(text: titleAndArtist.title,
                                                         font: systemFontScheme.normalFont,
                                                         color: systemColorScheme.primaryTextColor)], selectedTextColors: [systemColorScheme.primarySelectedTextColor],
                                              bottomYOffset: systemFontScheme.tableYOffset)
        }
        
        builder.withImage(image: track.art?.image ?? .imgPlayingArt)
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: columnId, inRow: row)
    }
}
