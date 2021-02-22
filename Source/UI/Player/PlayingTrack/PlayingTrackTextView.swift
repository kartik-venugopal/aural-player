import Cocoa

/*
    A rich text field that displays nicely formatted info about the currently playing track in the player window.
    Dynamically updates itself based on view settings to show either a single line or multiple
    lines of information.
 */
class PlayingTrackTextView: NSView, ColorSchemeable {
    
    // The text view that displays all the track info
    @IBOutlet weak var textView: NSTextView!
    
    // The clip view that contains the text view (used to center-align the text view vertically)
    @IBOutlet weak var clipView: NSClipView!
    
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            update()
        }
    }
    
    // The displayed track title
    private var title: String? {
        return trackInfo?.displayName
    }
    
    // The displayed track artist (displayed only if user setting allows it)
    private var artist: String? {
        return PlayerViewState.showArtist ? trackInfo?.artist : nil
    }
    
    // The displayed track album (displayed only if user setting allows it)
    private var album: String? {
        return PlayerViewState.showAlbum ? trackInfo?.album : nil
    }
    
    private var chapterTitle: String? {
        return PlayerViewState.showCurrentChapter ? trackInfo?.playingChapterTitle : nil
    }
    
    // Represents the maximum width allowed for one line of text displayed in the text view
    private var lineWidth: CGFloat = 300
    
    override func awakeFromNib() {

        // Set the line width to assist with truncation of title/artist/album/chapter strings,
        // with some padding to allow for slight discrepancies when truncating
        lineWidth = (textView?.frame.width ?? 300) - 10
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        update()
    }
    
    // Responds to a change in user-defined color scheme
    func applyColorScheme(_ scheme: ColorScheme) {
        update()
    }
    
    func changeTextColor() {
        update()
    }
    
    // Updates the view when the user settings that control display of metadata fields have changed
    func displayedTextChanged() {
        update()
    }
    
    // Constructs the formatted "rich" text to be displayed in the text view
    private func update() {
        
        // First, clear the view to remove any old text
        textView.string = ""
        
        // Check if there is any track info
        if let title = self.title {
            
            var truncatedArtistAlbumStr: String? = nil
            var fullLengthArtistAlbumStr: String? = nil
            
            // Construct a formatted and truncated artist/album string
            
            if let theArtist = artist, let theAlbum = album {
                
                fullLengthArtistAlbumStr = String(format: "%@ -- %@", theArtist, theAlbum)
                
                truncatedArtistAlbumStr = truncateCompositeString(FontSchemes.systemScheme.player.infoBoxArtistAlbumFont, lineWidth, fullLengthArtistAlbumStr!, theArtist, theAlbum, " -- ")
                
            } else if let theArtist = artist {
                
                truncatedArtistAlbumStr = StringUtils.truncate(theArtist, FontSchemes.systemScheme.player.infoBoxArtistAlbumFont, lineWidth)
                fullLengthArtistAlbumStr = theArtist
                
            } else if let theAlbum = album {
                
                truncatedArtistAlbumStr = StringUtils.truncate(theAlbum, FontSchemes.systemScheme.player.infoBoxArtistAlbumFont, lineWidth)
                fullLengthArtistAlbumStr = theAlbum
            }
            
            let hasArtistAlbum: Bool = truncatedArtistAlbumStr != nil
            
            let chapterStr = chapterTitle
            let hasChapter: Bool = chapterStr != nil
            
            // Title (truncate only if artist, album, or chapter are displayed)
            let truncatedTitle: String = hasArtistAlbum || hasChapter ? StringUtils.truncate(title, FontSchemes.systemScheme.player.infoBoxTitleFont, lineWidth) : title
            textView.textStorage?.append(attributedString(truncatedTitle, FontSchemes.systemScheme.player.infoBoxTitleFont, Colors.Player.trackInfoTitleTextColor, hasArtistAlbum ? 3 : (hasChapter ? 5 : nil)))
            
            // Artist / Album
            if let _truncatedArtistAlbumStr = truncatedArtistAlbumStr {
                textView.textStorage?.append(attributedString(_truncatedArtistAlbumStr, FontSchemes.systemScheme.player.infoBoxArtistAlbumFont, Colors.Player.trackInfoArtistAlbumTextColor, hasChapter ? 7 : nil))
            }
            
            // Chapter
            if let _chapterStr = chapterStr {
                
                let truncatedChapter: String = StringUtils.truncate(_chapterStr, FontSchemes.systemScheme.player.infoBoxChapterTitleFont, lineWidth)
                textView.textStorage?.append(attributedString(truncatedChapter, FontSchemes.systemScheme.player.infoBoxChapterTitleFont, Colors.Player.trackInfoChapterTextColor))
            }
            
            // Construct a tool tip with full length text (helpful when displayed fields are truncated because of length)
            textView.toolTip = String(format: "%@%@%@", title, fullLengthArtistAlbumStr != nil ? "\n\n" + fullLengthArtistAlbumStr! : "", chapterStr != nil ? "\n\n" + chapterStr! : "")
            
            // Center-align the text
            centerAlign()
        }
    }
    
    /*
        Takes a formatted artist/album string like "Artist -- Album" and truncates it so that it fits horizontally within the text view.
     */
    private func truncateCompositeString(_ font: NSFont, _ maxWidth: CGFloat, _ fullLengthString: String, _ s1: String, _ s2: String, _ separator: String) -> String {
        
        // Check if the full length string fits. If so, no need to truncate.
        let origWidth = StringUtils.widthOfString(fullLengthString, font)
        
        if origWidth <= maxWidth {
            return fullLengthString
        }
        
        // If fullLengthString doesn't fit, find out which is longer ... s1 or s2 ... truncate the longer one just enough to fit
        let w1 = StringUtils.widthOfString(s1, font)
        let w2 = StringUtils.widthOfString(s2, font)
        
        if w1 > w2 {
            
            // Reconstruct the composite string with the truncated s1
            
            let wRemainder1: CGFloat = origWidth - w1
            
            // Width available for s1 = maximum width - (original width - s1's width)
            let max1: CGFloat = maxWidth - wRemainder1
            
            let t1 = StringUtils.truncate(s1, font, max1)
            return String(format: "%@%@%@", t1, separator, s2)
            
        } else {
            
            // s2 is longer than s1, simply truncate the string as a whole
            return StringUtils.truncate(fullLengthString, font, maxWidth)
        }
    }
    
    // Center-aligns the text within the text view and the text view within the clip view.
    private func centerAlign() {
        
        // Horizontal alignment
        textView.setAlignment(.center, range: .init(location: 0, length: textView.string.count))
        
        // Vertical alignment
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)

        if let txtHeight = textView.layoutManager?.usedRect(for: textView.textContainer!).height {

            // If this isn't done, the text view frame occupies the whole ScrollView, and the text
            // is not vertically aligned on older systems (Sierra / HighSierra)
            textView.setFrameSize(NSSize(width: textView.frame.width, height: txtHeight + 10))
            
            // Move the text view down from the top, by adjusting the top insets of the clip view.
            let heightDifference = self.frame.height - txtHeight
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
        
        var attributes = [ NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color]
        
        var str: String = text
        
        if let spacing = lineSpacing {
            
            // If lineSpacing is specified, add a paragraph style attribute and set its lineSpacing field.
            
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.lineSpacing = spacing
            
            attributes[NSAttributedString.Key.paragraphStyle] = paraStyle
            
            // Add a newline character to the text to create a line break
            str += "\n"
        }
        
        return NSAttributedString(string: str, attributes: attributes)
    }
    
//    func changeBackgroundColor(_ color: NSColor) {
//
//        update()
//    }
}
