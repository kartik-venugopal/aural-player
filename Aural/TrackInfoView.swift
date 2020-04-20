import Cocoa

/*
    A view that displays info about the currently playing track in the player window.
 */
class TrackInfoView: NSView {
    
    // The text view that displays all the track info
    @IBOutlet weak var textView: NSTextView!
    
    // The clip view that contains the text view (used to center-align the text view vertically)
    @IBOutlet weak var clipView: NSClipView!
    
    // Stores the track for which info is currently displayed
    private var track: Track? = nil {
        
        didSet {
            // When track is set, update the text view
            update()
        }
    }
    
    // The displayed track title
    private var title: String {
        
        // Title from metadata
        if let _title = track!.displayInfo.title {
            return _title
        }
        
        // Filename
        return track!.conciseDisplayName
    }
    
    // The displayed track artist (displayed only if user setting allows it)
    private var artist: String? {
        return PlayerViewState.showArtist ? track?.displayInfo.artist : nil
    }
    
    // The displayed track album (displayed only if user setting allows it)
    private var album: String? {
        return PlayerViewState.showAlbum ? track?.groupingInfo.album : nil
    }
    
    // The currently playing chapter's title (displayed only if user setting allows it)
    private var chapterTitle: String?
    
    private var chapter: String? {
        return PlayerViewState.showCurrentChapter ? chapterTitle : nil
    }
    
    // Represents the maximum width allowed for one line of text displayed in the text view
    private var lineWidth: CGFloat = 300
    
    override func awakeFromNib() {

        // Set the line width to assist with truncation of title/artist/album/chapter strings,
        // with some padding to allow for slight discrepancies when truncating
        lineWidth = (textView?.frame.width ?? 300) - 15
    }
    
    // Update the text view when the current chapter changes
    func chapterChanged(_ chapterTitle: String?) {
        
        self.chapterTitle = chapterTitle
        update()
    }
    
    // Update the text view when the current track changes
    func showNowPlayingInfo(_ track: Track, _ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int), _ chapterTitle: String?) {
        
        self.chapterTitle = chapterTitle
        self.track = track
    }
    
    // Clear the text view when no track is being played
    func clearNowPlayingInfo() {
        
        self.chapterTitle = nil
        self.track = nil
    }
    
    // Responds to a change in user-preferred text size
    func changeTextSize() {
        update()
    }
    
    // Responds to a change in user-defined color scheme
    func changeTextColor() {
        update()
    }
    
    // Hands off track info to another TrackInfoView object
    func handOff(_ otherView: TrackInfoView) {
        
        otherView.chapterTitle = self.chapterTitle
        otherView.track = self.track
    }
    
    // Updates the view when the user settings that control display of metadata fields have changed
    func metadataDisplaySettingsChanged() {
        update()
    }
    
    // Constructs the formatted "rich" text to be displayed in the text view
    private func update() {
        
        // First, clear the view to remove any old text
        textView.string = ""
        
        if track != nil {
            
            var truncatedArtistAlbumStr: String? = nil
            var fullLengthArtistAlbumStr: String? = nil
            
            // Construct a formatted and truncated artist/album string
            
            if let theArtist = artist, let theAlbum = album {
                
                fullLengthArtistAlbumStr = String(format: "%@ -- %@", theArtist, theAlbum)
                truncatedArtistAlbumStr = truncateCompositeString(Fonts.Player.infoBoxArtistAlbumFont, lineWidth, fullLengthArtistAlbumStr!, theArtist, theAlbum, " -- ")
                
            } else if let theArtist = artist {
                
                truncatedArtistAlbumStr = StringUtils.truncate(theArtist, Fonts.Player.infoBoxArtistAlbumFont, lineWidth)
                fullLengthArtistAlbumStr = theArtist
                
            } else if let theAlbum = album {
                
                truncatedArtistAlbumStr = StringUtils.truncate(theAlbum, Fonts.Player.infoBoxArtistAlbumFont, lineWidth)
                fullLengthArtistAlbumStr = theAlbum
            }
            
            let hasArtistAlbum: Bool = truncatedArtistAlbumStr != nil
            
            let chapterStr = chapter
            let hasChapter: Bool = chapterStr != nil
            
            // Title (truncate only if artist, album, or chapter are displayed)
            let truncatedTitle: String = hasArtistAlbum || hasChapter ? StringUtils.truncate(title, Fonts.Player.infoBoxTitleFont, lineWidth) : title
            textView.textStorage?.append(attributedString(truncatedTitle, Fonts.Player.infoBoxTitleFont, Colors.Player.trackInfoTitleTextColor, hasArtistAlbum ? 3 : (hasChapter ? 5 : nil)))
            
            // Artist / Album
            if let _truncatedArtistAlbumStr = truncatedArtistAlbumStr {
                textView.textStorage?.append(attributedString(_truncatedArtistAlbumStr, Fonts.Player.infoBoxArtistAlbumFont, Colors.Player.trackInfoArtistAlbumTextColor, hasChapter ? 7 : nil))
            }
            
            // Chapter
            if let _chapterStr = chapterStr {
                
                let truncatedChapter: String = StringUtils.truncate(_chapterStr, Fonts.Player.infoBoxChapterFont, lineWidth)
                textView.textStorage?.append(attributedString(truncatedChapter, Fonts.Player.infoBoxChapterFont, Colors.Player.trackInfoChapterTextColor))
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
        
        var attributes = [ NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color ]
        
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
}
