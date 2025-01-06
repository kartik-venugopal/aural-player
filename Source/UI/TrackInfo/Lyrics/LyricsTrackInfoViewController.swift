//
//  LyricsTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class LyricsTrackInfoViewController: NSViewController, TrackInfoViewProtocol {
    
    override var nibName: NSNib.Name? {"LyricsTrackInfo"}
    
    private lazy var messenger = Messenger(for: self)
    
    @IBOutlet weak var textView: NSTextView! {
        
        didSet {
            
            textView.font = standardFontSet.mainFont(size: 13)
            textView.alignment = .center
            textView.backgroundColor = .popoverBackgroundColor
            textView.textColor = .boxTextColor
            textView.enclosingScrollView?.contentInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            textView.enclosingScrollView?.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: -9)
        }
    }
    
    private let noLyricsText: String = "< No lyrics available for this track >"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        messenger.subscribe(to: .Lyrics.lyricsUpdated, handler: updateForTrack(_:))
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    private func updateForTrack(_ track: Track) {
        
        if TrackInfoViewContext.displayedTrack == track {
            refresh()
        }
    }
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh() {
        
        if let timedLyrics = TrackInfoViewContext.displayedTrack?.externalOrEmbeddedTimedLyrics {
            
            textView.string = ""
            
            for line in timedLyrics.lines {
                
                appendLine(text: line.content,
                           font: systemFontScheme.normalFont,
                           color: systemColorScheme.primaryTextColor,
                           lineSpacing: 10)
            }
            
        } else {
            
            textView?.string = TrackInfoViewContext.displayedTrack?.lyrics ?? noLyricsText
        }
    }
    
    func appendLine(text: String, font: NSFont, color: NSColor, lineSpacing: CGFloat? = nil) {
        
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
    
    var jsonObject: AnyObject? {
        textView.string as NSString
    }
    
    func writeHTML(to writer: HTMLWriter) {
        
        writer.addHeading("Lyrics:", 3, true)
        
        let lyrics = HTMLText(text: textView.string, underlined: false, bold: false, italic: false, width: nil)
        writer.addParagraph(lyrics)
    }
    
    // MARK: Theming ---------------------------------------------------
    
    func initTheme() {
        
        fontSchemeChanged()
        colorSchemeChanged()
    }
    
    func fontSchemeChanged() {
        refresh()
    }
    
    func colorSchemeChanged() {
        
        backgroundColorChanged(systemColorScheme.backgroundColor)
        refresh()
    }
    
    func backgroundColorChanged(_ newColor: NSColor) {
        textView.setBackgroundColor(newColor)
    }
    
    func primaryTextColorChanged(_ newColor: NSColor) {
        refresh()
    }
    
    func secondaryTextColorChanged(_ newColor: NSColor) {}
}
