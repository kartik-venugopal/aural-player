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
    
    var titleFont: NSFont {
        FontSchemes.systemScheme.player.infoBoxTitleFont
    }
    
    var titleColor: NSColor {
        Colors.Player.trackInfoTitleTextColor
    }
    
    var artistAlbumFont: NSFont {
        FontSchemes.systemScheme.player.infoBoxArtistAlbumFont
    }
    
    var artistAlbumColor: NSColor {
        Colors.Player.trackInfoArtistAlbumTextColor
    }
    
    var chapterTitleFont: NSFont {
        FontSchemes.systemScheme.player.infoBoxChapterTitleFont
    }
    
    var chapterTitleColor: NSColor {
        Colors.Player.trackInfoChapterTextColor
    }
    
    var shouldShowArtist: Bool {
        PlayerViewState.showArtist
    }
    
    var shouldShowAlbum: Bool {
        PlayerViewState.showAlbum
    }
    
    var shouldShowChapterTitle: Bool {
        PlayerViewState.showCurrentChapter
    }
    
    var lineSpacingBetweenArtistAlbumAndChapterTitle: CGFloat {7}
    
    // The displayed track title
    private var title: String? {
        return trackInfo?.displayName
    }
    
    // The displayed track artist (displayed only if user setting allows it)
    private var artist: String? {
        return shouldShowArtist ? trackInfo?.artist : nil
    }
    
    // The displayed track album (displayed only if user setting allows it)
    private var album: String? {
        return shouldShowAlbum ? trackInfo?.album : nil
    }
    
    private var chapterTitle: String? {
        return shouldShowChapterTitle ? trackInfo?.playingChapterTitle : nil
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
    func update() {
        
        // First, clear the view to remove any old text
        textView.string = ""
        
        // Check if there is any track info
        if let title = self.title {
            
            var truncatedArtistAlbumStr: String? = nil
            var fullLengthArtistAlbumStr: String? = nil
            
            // Construct a formatted and truncated artist/album string
            
            if let theArtist = artist, let theAlbum = album {
                
                fullLengthArtistAlbumStr = String(format: "%@ -- %@", theArtist, theAlbum)
                
                truncatedArtistAlbumStr = truncateCompositeString(artistAlbumFont, lineWidth, fullLengthArtistAlbumStr!, theArtist, theAlbum, " -- ")
                
            } else if let theArtist = artist {
                
                truncatedArtistAlbumStr = StringUtils.truncate(theArtist, artistAlbumFont, lineWidth)
                fullLengthArtistAlbumStr = theArtist
                
            } else if let theAlbum = album {
                
                truncatedArtistAlbumStr = StringUtils.truncate(theAlbum, artistAlbumFont, lineWidth)
                fullLengthArtistAlbumStr = theAlbum
            }
            
            let hasArtistAlbum: Bool = truncatedArtistAlbumStr != nil
            
            let chapterStr = chapterTitle
            let hasChapter: Bool = chapterStr != nil
            
            // Title (truncate only if artist, album, or chapter are displayed)
            let truncatedTitle: String = hasArtistAlbum || hasChapter ? StringUtils.truncate(title, titleFont, lineWidth) : title
            
            textView.textStorage?.append(attributedString(truncatedTitle, titleFont, titleColor, hasArtistAlbum ? 3 : (hasChapter ? 5 : nil)))
            
            // Artist / Album
            if let _truncatedArtistAlbumStr = truncatedArtistAlbumStr {
                textView.textStorage?.append(attributedString(_truncatedArtistAlbumStr, artistAlbumFont, artistAlbumColor, hasChapter ? lineSpacingBetweenArtistAlbumAndChapterTitle : nil))
            }
            
            // Chapter
            if let _chapterStr = chapterStr {
                
                let truncatedChapter: String = StringUtils.truncate(_chapterStr, chapterTitleFont, lineWidth)
                textView.textStorage?.append(attributedString(truncatedChapter, chapterTitleFont, chapterTitleColor))
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

class MenuBarPlayingTrackTextView: PlayingTrackTextView {
    
    override var titleFont: NSFont {
        Fonts.Standard.mainFont_13
    }
    
    override var artistAlbumFont: NSFont {
        Fonts.Standard.mainFont_11
    }
    
    override var chapterTitleFont: NSFont {
        Fonts.Standard.mainFont_10
    }
    
    override var titleColor: NSColor {
        .white
    }
    
    override var artistAlbumColor: NSColor {
        Colors.Constants.white90Percent
    }
    
    override var chapterTitleColor: NSColor {
        Colors.Constants.white80Percent
    }
    
    override var shouldShowArtist: Bool {
        MenuBarPlayerViewState.showArtist
    }
    
    override var shouldShowAlbum: Bool {
        MenuBarPlayerViewState.showAlbum
    }
    
    override var shouldShowChapterTitle: Bool {
        MenuBarPlayerViewState.showCurrentChapter
    }
    
    override var lineSpacingBetweenArtistAlbumAndChapterTitle: CGFloat {4}
}
