//
//  LibraryImportedPlaylistsView+TableCells.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class ImportedPlaylistCellView: AuralTableCellView {
    
    func update(forPlaylist playlist: ImportedPlaylist) {
        
        let string = playlist.name.attributed(font: systemFontScheme.prominentFont, color: systemColorScheme.primaryTextColor, lineSpacing: 5)
        textField?.attributedStringValue = string
        
        imageView?.image = .imgPlaylist
    }
}

class ImportedPlaylistTrackCellView: AuralTableCellView {
    
    @IBOutlet weak var lblTrackNumber: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    
    lazy var trackNumberConstraintsManager = LayoutConstraintsManager(for: lblTrackNumber!)
    lazy var trackNameConstraintsManager = LayoutConstraintsManager(for: lblTrackName!)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        lblTrackNumber.font = systemFontScheme.normalFont
        lblTrackNumber.textColor = systemColorScheme.tertiaryTextColor
        
        lblTrackName.font = systemFontScheme.normalFont
        lblTrackName.textColor = systemColorScheme.primaryTextColor
        
        trackNameConstraintsManager.removeAll(withAttributes: [.centerY])
        trackNameConstraintsManager.centerVerticallyInSuperview(offset: systemFontScheme.tableYOffset)
    }
    
    func update(forTrack track: Track, atIndex index: Int) {
        
        lblTrackNumber.stringValue = "\(index + 1)"
        
        if let artist = track.artist, let title = track.title {
            
            lblTrackName.attributedStringValue = "\(artist)  ".attributed(font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor) +
            title.attributed(font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor)
            
        } else {
            lblTrackName.stringValue = track.displayName
        }
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

extension NSUserInterfaceItemIdentifier {
    
    // Outline view column identifiers
    static let cid_ImportedPlaylistName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_ImportedPlaylistName")
    static let cid_ImportedPlaylistDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_ImportedPlaylistDuration")
}

class IndexedTrack {
    
    let track: Track
    let index: Int
    
    init(track: Track, index: Int) {
        self.track = track
        self.index = index
    }
}
