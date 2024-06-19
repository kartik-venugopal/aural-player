//
//  TrackInfoKVListViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class TrackInfoKVListViewController: NSViewController, TrackInfoViewProtocol {
    
    override var nibName: NSNib.Name? {"TrackInfoKVList"}
    
    var trackInfoSource: TrackInfoSource {
        MetadataTrackInfoSource.instance
    }
    
    // The table view that displays the track info
    @IBOutlet weak var textView: NSTextView!
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh() {
        
        guard let track = TrackInfoViewContext.displayedTrack else {return}
        trackInfoSource.loadTrackInfo(for: track)
        update()
    }
    
    // Constructs the formatted "rich" text to be displayed in the text view
    func update() {
        
        // First, clear the view to remove any old text
        textView.string = ""
        
        for (key, value) in trackInfoSource.trackInfo {
            
            appendString(text: key, font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor, lineSpacing: 20)
            appendString(text: value, font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor, lineSpacing: 5)
        }
    }
    
    /*
        Helper factory function to construct an NSAttributedString (i.e. "rich text"), given all its attributes.
     
        @param lineSpacing (optional)
                Amout of spacing between this line of text and the next line. Nil value indicates no spacing.
                Non-nil value will result in a line break being added to the text (to separate lines).
     */
    private func appendString(text: String, font: NSFont, color: NSColor, lineSpacing: CGFloat? = nil) {
        
        var attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let style = NSMutableParagraphStyle()
        var str: String = text
        
        style.alignment = .left
        
        if let spacing = lineSpacing {
            
            // If lineSpacing is specified, add a paragraph style attribute and set its lineSpacing field.
            style.lineSpacing = spacing
            
            // Add a newline character to the text to create a line break
            str += "\n"
        }
        
        attributes[.paragraphStyle] = style
        
        textView.textStorage?.append(NSAttributedString(string: str, attributes: attributes))
    }
    
    // MARK: Export ---------------------------------------------------
    
    var jsonObject: AnyObject? {
        
        var dict: [NSString: AnyObject] = [:]
        
        for (key, value) in trackInfoSource.trackInfo {
            dict[key as NSString] = value as AnyObject
        }
        
        return dict as NSDictionary
    }
    
    var htmlTableName: String {""}
    
    func writeHTML(to writer: HTMLWriter) {
        
        let grid: [[HTMLText]] = trackInfoSource.trackInfo.map {kvPair in
            
            [HTMLText(text: kvPair.key, underlined: true, bold: false, italic: false, width: 300),
             HTMLText(text: kvPair.value, underlined: false, bold: false, italic: false, width: nil)]
        }
        
        writer.addTable("\(htmlTableName):", 3, nil, grid)
    }
    
    // MARK: Theming ---------------------------------------------------
    
    func initTheme() {
        
        textView.setBackgroundColor(systemColorScheme.backgroundColor)
        update()
    }
    
    func fontSchemeChanged() {
        update()
    }
    
    func colorSchemeChanged() {
        
        textView.setBackgroundColor(systemColorScheme.backgroundColor)
        update()
    }
    
    func backgroundColorChanged(_ newColor: PlatformColor) {
        textView.setBackgroundColor(systemColorScheme.backgroundColor)
    }
    
    func primaryTextColorChanged(_ newColor: PlatformColor) {
        update()
    }
    
    func secondaryTextColorChanged(_ newColor: PlatformColor) {
        update()
    }
}
