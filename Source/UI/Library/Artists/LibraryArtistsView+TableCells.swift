//
//  LibraryArtistsView+TableCells.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class ArtistCellView: AuralTableCellView {
    
    func update(forGroup group: ArtistGroup) {
        
        text = group.name
        image = .imgArtistGroup
        image?.isTemplate = true
        imageColor = systemColorScheme.buttonColor
        
        textFont = systemFontScheme.prominentFont
        textColor = systemColorScheme.primaryTextColor
    }
}

class ArtistAlbumCellView: AuralTableCellView {
    
    func update(forGroup group: AlbumGroup) {
        
        var string = group.name.attributed(font: systemFontScheme.prominentFont, color: systemColorScheme.primaryTextColor, lineSpacing: 5)
        
        var hasGenre: Bool = false
        
        if let genres = group.genresString {
            
            string = string + "\n\(genres)".attributed(font: systemFontScheme.normalFont, color: systemColorScheme.tertiaryTextColor)
            hasGenre = true
        }
        
        if let year = group.yearString {
            
            let padding = hasGenre ? "  " : ""
            string = string + "\(padding)[\(year)]".attributed(font: systemFontScheme.normalFont, color: systemColorScheme.tertiaryTextColor, lineSpacing: 3)
        }
        
        textField?.attributedStringValue = string
        image = group.art
    }
}

extension GroupSummaryCellView {
    
    func update(forArtistGroup group: ArtistGroup, showAlbumsCount: Bool = true) {
        
        let trackCount = group.numberOfTracks
        let albumCount = group.numberOfSubGroups
        
        if showAlbumsCount {
            lblTrackCount.stringValue = "\(albumCount) \(albumCount == 1 ? "album" : "albums"), \(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        } else {
            lblTrackCount.stringValue = "\(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        }
        
        lblDuration.stringValue = ValueFormatter.formatSecondsToHMS(group.duration)
        
        lblTrackCount.font = summaryFont
        lblDuration.font = summaryFont
        
        lblTrackCount.textColor = systemColorScheme.secondaryTextColor
        lblDuration.textColor = systemColorScheme.secondaryTextColor
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Outline view column identifiers
    static let cid_ArtistName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_ArtistName")
    static let cid_ArtistDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_ArtistDuration")
}
