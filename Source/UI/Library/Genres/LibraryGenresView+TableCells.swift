//
//  LibraryGenresView+TableCells.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class GenreCellView: AuralTableCellView {
    
    func update(forGroup group: GenreGroup) {
        
        let string = group.name.attributed(font: systemFontScheme.prominentFont, color: systemColorScheme.primaryTextColor, lineSpacing: 5)
        textField?.attributedStringValue = string
        
        imageView?.image = .imgGenreGroup
    }
}

class GenreTrackCellView: AuralTableCellView {
    
    @IBOutlet weak var lblTrackNumber: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    
    lazy var trackNumberConstraintsManager = LayoutConstraintsManager(for: lblTrackNumber!)
    lazy var trackNameConstraintsManager = LayoutConstraintsManager(for: lblTrackName!)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
//        lblTrackNumber.font = systemFontScheme.normalFont
//        lblTrackNumber.textColor = systemColorScheme.tertiaryTextColor
//        trackNumberConstraintsManager.removeAll(withAttributes: [.centerY])
//        trackNumberConstraintsManager.centerVerticallyInSuperview(offset: systemFontScheme.tableYOffset)
        
        lblTrackName.font = systemFontScheme.normalFont
        lblTrackName.textColor = systemColorScheme.primaryTextColor
        trackNameConstraintsManager.removeAll(withAttributes: [.centerY])
        trackNameConstraintsManager.centerVerticallyInSuperview(offset: systemFontScheme.tableYOffset)
    }
    
    func update(forTrack track: Track) {
        
//        if let trackNumber = track.trackNumber {
//            lblTrackNumber.stringValue = "\(trackNumber)"
//        }
        
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

extension NSUserInterfaceItemIdentifier {
    
    // Outline view column identifiers
    static let cid_GenreName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_GenreName")
    static let cid_GenreDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_GenreDuration")
}
