//  PlayingTrackTextView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A rich text field that displays nicely formatted info about the currently playing track in the player window.
    Dynamically updates itself based on view settings to show either a single line or multiple
    lines of information.
 */
class MultilineTrackTextView: NSView {
    
    // The text view that displays all the track info
    @IBOutlet weak var textView: NSTextView!
    
    // The clip view that contains the text view (used to center-align the text view vertically)
    @IBOutlet weak var clipView: NSClipView!
    
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            update()
        }
    }
    
    var backgroundColor: NSColor {
        
        get {
            clipView.backgroundColor
        }
        
        set(newColor) {
            
            clipView.backgroundColor = newColor
            clipView.enclosingScrollView?.backgroundColor = newColor
            textView.backgroundColor = newColor
        }
    }
    
    var titleFont: NSFont = systemFontScheme.prominentFont
    var titleColor: NSColor = systemColorScheme.primaryTextColor
    
    var artistAlbumFont: NSFont = systemFontScheme.normalFont
    var artistAlbumColor: NSColor = systemColorScheme.secondaryTextColor
    
    var chapterTitleFont: NSFont = systemFontScheme.smallFont
    var chapterTitleColor: NSColor = systemColorScheme.tertiaryTextColor
    
    var shouldShowArtist: Bool {
        playerUIState.showArtist
    }
    
    var shouldShowAlbum: Bool {
        playerUIState.showAlbum
    }
    
    var shouldShowChapterTitle: Bool {
        playerUIState.showCurrentChapter
    }
    
    var lineSpacingBetweenArtistAlbumAndChapterTitle: CGFloat {7}
    
    var horizontalAlignment: NSTextAlignment? {
        nil
    }
    
    // The displayed track title
    private var title: String? {
        trackInfo?.title
    }
    
    // The displayed track artist (displayed only if user setting allows it)
    private var artist: String? {
        shouldShowArtist ? trackInfo?.artist : nil
    }
    
    // The displayed track album (displayed only if user setting allows it)
    private var album: String? {
        shouldShowAlbum ? trackInfo?.album : nil
    }
    
    private var chapterTitle: String? {
        shouldShowChapterTitle ? trackInfo?.playingChapterTitle : nil
    }
    
    func resized() {
        update()
    }
    
    // Constructs the formatted "rich" text to be displayed in the text view
    func update() {
        
        // Set the line width to assist with truncation of title/artist/album/chapter strings,
        // with some padding to allow for slight discrepancies when truncating
        let lineWidth = (textView?.width ?? 300) - 10
        
        // First, clear the view to remove any old text
        textView.string = ""
        
        // Check if there is any track info
        guard let title = self.title else {return}
            
        var truncatedArtistAlbumStr: String? = nil
        var fullLengthArtistAlbumStr: String? = nil
        
        // Construct a formatted and truncated artist/album string
        
        if let theArtist = artist, let theAlbum = album {
            
            fullLengthArtistAlbumStr = String(format: "%@ -- %@", theArtist, theAlbum)
            truncatedArtistAlbumStr = String.truncateCompositeString(artistAlbumFont, lineWidth, fullLengthArtistAlbumStr!, theArtist, theAlbum, " -- ")
            
        } else if let theArtist = artist {
            
            truncatedArtistAlbumStr = theArtist.truncate(font: artistAlbumFont, maxWidth: lineWidth)
            fullLengthArtistAlbumStr = theArtist
            
        } else if let theAlbum = album {
            
            truncatedArtistAlbumStr = theAlbum.truncate(font: artistAlbumFont, maxWidth: lineWidth)
            fullLengthArtistAlbumStr = theAlbum
        }
        
        let hasArtistAlbum: Bool = truncatedArtistAlbumStr != nil
        
        let chapterStr = chapterTitle
        let hasChapter: Bool = chapterStr != nil
        
        // Title (truncate only if artist, album, or chapter are displayed)
        let truncatedTitle: String = hasArtistAlbum || hasChapter ? title.truncate(font: titleFont, maxWidth: lineWidth) : title
        
        textView.textStorage?.append(attributedString(truncatedTitle, titleFont, titleColor, hasArtistAlbum ? (hasChapter ? 5 : 8) : (hasChapter ? 5 : nil)))
        
        // Artist / Album
        if let _truncatedArtistAlbumStr = truncatedArtistAlbumStr {
//            textView.textStorage?.append(attributedString(_truncatedArtistAlbumStr, artistAlbumFont, artistAlbumColor, hasChapter ? lineSpacingBetweenArtistAlbumAndChapterTitle : nil))
            textView.textStorage?.append(attributedString(_truncatedArtistAlbumStr, artistAlbumFont, artistAlbumColor, hasChapter ? 5 : nil))
        }
        
        // Chapter
        if let _chapterStr = chapterStr {
            
            let truncatedChapter: String = _chapterStr.truncate(font: chapterTitleFont, maxWidth: lineWidth)
            textView.textStorage?.append(attributedString(truncatedChapter, chapterTitleFont, chapterTitleColor))
        }
        
        // Construct a tool tip with full length text (helpful when displayed fields are truncated because of length)
        textView.toolTip = String(format: "%@%@%@", title, fullLengthArtistAlbumStr != nil ? "\n\n" + fullLengthArtistAlbumStr! : "", chapterStr != nil ? "\n\n" + chapterStr! : "")
        
        // Center-align the text
        centerAlign()
    }
    
    // Center-aligns the text within the text view and the text view within the clip view.
    private func centerAlign() {
        
        // Horizontal alignment
//        textView.setAlignment(.center, range: .init(location: 0, length: textView.string.count))
        
        // Vertical alignment
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)

        if let txtHeight = textView.layoutManager?.usedRect(for: textView.textContainer!).height {

            // If this isn't done, the text view frame occupies the whole ScrollView, and the text
            // is not vertically aligned on older systems (Sierra / HighSierra)
            textView.resize(textView.width, txtHeight + 10)
            
            // Move the text view down from the top, by adjusting the top insets of the clip view.
            let heightDifference = self.height - txtHeight
            clipView.contentInsets.top = heightDifference / 2
        }
    }
    
    /*
        Helper factory function to construct an NSAttributedString (i.e. "rich text"), given all its attributes.
     
        @param lineSpacing (optional)
                Amout of spacing between this line of text and the next line. Nil value indicates no spacing.
                Non-nil value will result in a line break being added to the text (to separate lines).
     */
    private func attributedString(_ text: String, _ font: NSFont, _ color: NSColor, _ lineSpacing: CGFloat? = nil) -> NSAttributedString {
        
        // TODO: Figure out how to do this flexibly and optimally
        
//        let shadow: NSShadow = NSShadow()
//        shadow.shadowColor = shadowColor
//        shadow.shadowOffset = NSSize(width: -0.5, height: -0.5)
//        shadow.shadowBlurRadius = 3
//        var attributes = [ NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.shadow: shadow ]
        
        var attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let style = NSMutableParagraphStyle()
        var str: String = text
        
        if let textAlignment = self.horizontalAlignment {
            style.alignment = textAlignment
        }
        
        if let spacing = lineSpacing {
            
            // If lineSpacing is specified, add a paragraph style attribute and set its lineSpacing field.
            style.lineSpacing = spacing
            
            // Add a newline character to the text to create a line break
            str += "\n"
        }
        
        attributes[.paragraphStyle] = style
        
        return NSAttributedString(string: str, attributes: attributes)
    }
}

class MenuBarPlayingTrackTextView: MultilineTrackTextView {
    
    override var shouldShowArtist: Bool {
        menuBarPlayerUIState.showArtist
    }
    
    override var shouldShowAlbum: Bool {
        menuBarPlayerUIState.showAlbum
    }
    
    override var shouldShowChapterTitle: Bool {
        menuBarPlayerUIState.showCurrentChapter
    }
    
    override var lineSpacingBetweenArtistAlbumAndChapterTitle: CGFloat {4}
}

extension MultilineTrackTextView: ColorSchemePropertyChangeReceiver {
    
    func backgroundColorChanged(_ newColor: NSColor) {
        self.backgroundColor = systemColorScheme.backgroundColor
    }
    
    func colorChanged(_ newColor: NSColor) {
        update()
    }
}
