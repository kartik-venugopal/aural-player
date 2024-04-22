//
//  LibraryDecadesView+TableCells.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class DecadeCellView: AuralTableCellView {
    
    func update(forGroup group: DecadeGroup) {
        
        let string = group.name.attributed(font: systemFontScheme.prominentFont, color: systemColorScheme.primaryTextColor, lineSpacing: 5)
        textField?.attributedStringValue = string
        
        imageView?.image = .imgDecadeGroup
    }
}

class DecadeTrackCellView: AuralTableCellView {
    
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
    static let cid_Name: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Name")
    static let cid_Duration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Duration")
    
    static let cid_DecadeName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_DecadeName")
    static let cid_DecadeDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_DecadeDuration")
}

