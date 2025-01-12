//
//  LibraryAlbumsView+TableCells.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class AlbumCellView: AuralTableCellView {
    
    func update(forGroup group: AlbumGroup) {
        
        var string = group.name.attributed(font: systemFontScheme.prominentFont, color: systemColorScheme.primaryTextColor, lineSpacing: 5)
        
        if let artists = group.artistsString {
            string = string + "\nby \(artists)".attributed(font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor, lineSpacing: 3)
        }
        
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
        
        imageView?.image = group.art
    }
}

class AlbumTrackCellView: AuralTableCellView {
    
    @IBOutlet weak var lblTrackNumber: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    
    lazy var trackNumberConstraintsManager = LayoutConstraintsManager(for: lblTrackNumber!)
    lazy var trackNameConstraintsManager = LayoutConstraintsManager(for: lblTrackName!)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        lblTrackNumber.font = systemFontScheme.normalFont
        lblTrackNumber.textColor = systemColorScheme.tertiaryTextColor
        trackNumberConstraintsManager.removeAll(withAttributes: [.centerY])
        trackNumberConstraintsManager.centerVerticallyInSuperview(offset: systemFontScheme.tableYOffset)
        
        lblTrackName.font = systemFontScheme.normalFont
        lblTrackName.textColor = systemColorScheme.primaryTextColor
        trackNameConstraintsManager.removeAll(withAttributes: [.centerY])
        trackNameConstraintsManager.centerVerticallyInSuperview(offset: systemFontScheme.tableYOffset)
    }
    
    func update(forTrack track: Track) {
        
        if let trackNumber = track.trackNumber {
            lblTrackNumber.stringValue = "\(trackNumber)"
        }
        
        lblTrackName.stringValue = track.titleOrDefaultDisplayName
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            if rowIsSelected {
                
                lblTrackNumber.textColor = systemColorScheme.tertiarySelectedTextColor
                lblTrackName.textColor = systemColorScheme.primarySelectedTextColor
                
            } else {
                
                lblTrackNumber.textColor = systemColorScheme.tertiaryTextColor
                lblTrackName.textColor = systemColorScheme.primaryTextColor
            }
        }
    }
}

class GroupSummaryCellView: AuralTableCellView {
    
    @IBOutlet weak var lblTrackCount: NSTextField!
    @IBOutlet weak var lblDuration: NSTextField!
    
    lazy var summaryFont: NSFont = systemFontScheme.normalFont
    
    func update(forGroup group: Group) {
        
        let trackCount = group.numberOfTracks
        
        lblTrackCount.stringValue = "\(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        lblDuration.stringValue = ValueFormatter.formatSecondsToHMS(group.duration)
        
        lblTrackCount.font = summaryFont
        lblDuration.font = summaryFont
        
        lblTrackCount.textColor = systemColorScheme.secondaryTextColor
        lblDuration.textColor = systemColorScheme.secondaryTextColor
    }
    
    func update(forAlbumGroup group: AlbumGroup) {
        
        let trackCount = group.numberOfTracks
        let hasMoreThanOneDisc = group.hasMoreThanOneTotalDisc
        let totalDiscs = group.totalDiscs
        let discCount = group.discCount
        
        if hasMoreThanOneDisc, let totalDiscs = totalDiscs {
            
            if discCount < totalDiscs {
                lblTrackCount.stringValue = "\(discCount) / \(totalDiscs) discs, \(trackCount) \(trackCount == 1 ? "track" : "tracks")"
            } else {
                lblTrackCount.stringValue = "\(totalDiscs) discs, \(trackCount) \(trackCount == 1 ? "track" : "tracks")"
            }
            
        } else {
            lblTrackCount.stringValue = "\(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        }
        
        lblDuration.stringValue = ValueFormatter.formatSecondsToHMS(group.duration)
        
        lblTrackCount.font = summaryFont
        lblDuration.font = summaryFont
        
        lblTrackCount.textColor = systemColorScheme.secondaryTextColor
        lblDuration.textColor = systemColorScheme.secondaryTextColor
    }
    
    func update(forGenreGroup group: GenreGroup) {
        
        let trackCount = group.numberOfTracks
        let artistsCount = group.numberOfSubGroups
        
        lblTrackCount.stringValue = "\(artistsCount) \(artistsCount == 1 ? "artist" : "artists"), \(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        lblDuration.stringValue = ValueFormatter.formatSecondsToHMS(group.duration)
        
        lblTrackCount.font = summaryFont
        lblDuration.font = summaryFont
        
        lblTrackCount.textColor = systemColorScheme.secondaryTextColor
        lblDuration.textColor = systemColorScheme.secondaryTextColor
    }
    
    func update(forDecadeGroup group: DecadeGroup) {
        
        let trackCount = group.numberOfTracks
        let artistsCount = group.numberOfSubGroups
        
        lblTrackCount.stringValue = "\(artistsCount) \(artistsCount == 1 ? "artist" : "artists"), \(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        lblDuration.stringValue = ValueFormatter.formatSecondsToHMS(group.duration)
        
        lblTrackCount.font = summaryFont
        lblDuration.font = summaryFont
        
        lblTrackCount.textColor = systemColorScheme.secondaryTextColor
        lblDuration.textColor = systemColorScheme.secondaryTextColor
    }
    
    func update(forPlaylistGroup group: ImportedPlaylist) {
        
        let trackCount = group.size
        
        lblTrackCount.stringValue = "\(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        lblDuration.stringValue = ValueFormatter.formatSecondsToHMS(group.duration)
        
        lblTrackCount.font = summaryFont
        lblDuration.font = summaryFont
        
        lblTrackCount.textColor = systemColorScheme.secondaryTextColor
        lblDuration.textColor = systemColorScheme.secondaryTextColor
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Outline view column identifiers
    static let cid_AlbumName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_AlbumName")
    static let cid_DiscName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_DiscName")
    static let cid_TrackName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_TrackName")
    
    static let cid_AlbumDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_AlbumDuration")
    static let cid_DiscDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_DiscDuration")
    static let cid_TrackDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_TrackDuration")
}
