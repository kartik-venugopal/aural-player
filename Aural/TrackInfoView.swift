import Cocoa

class TrackInfoView: NSView {
    
    @IBOutlet weak var txt: NSTextView!
    @IBOutlet weak var clipView: NSClipView!
    
    private var track: Track? = nil {
        
        didSet {
            update()
        }
    }
    
    private var title: String {
        
        // Title from metadata
        if let _title = track!.displayInfo.title {
            return _title
        }
        
        // Filename
        return track!.conciseDisplayName
    }
    
    var artist: String? {
        return PlayerViewState.showArtist ? track?.displayInfo.artist : nil
    }
    
    var album: String? {
        return PlayerViewState.showAlbum ? track?.groupingInfo.album : nil
    }
    
    var chapter: String?
    
    // Set some default value
    var lineWidth: CGFloat = 300
    
    override func awakeFromNib() {
        lineWidth = (txt?.frame.width ?? 300) - 15
    }
    
    func chapterChanged(_ chapterTitle: String?) {
        
        self.chapter = chapterTitle
        update()
    }
    
    func showNowPlayingInfo(_ track: Track, _ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int), _ chapter: String?) {
        
        self.chapter = chapter
        self.track = track
    }
    
    func clearNowPlayingInfo() {
        
        self.chapter = nil
        self.track = nil
    }
    
    func changeTextSize(_ textSize: TextSizeScheme) {
        update()
    }
    
    func handOff(_ otherView: TrackInfoView) {
        
        otherView.chapter = self.chapter
        otherView.track = self.track
    }
    
    func metadataDisplaySettingsChanged() {
        update()
    }
    
    private func update() {
        
        txt.string = ""
        
        if track != nil {
            
            var truncatedArtistAlbumStr: String? = nil
            var fullLengthArtistAlbumStr: String? = nil
            
            if let theArtist = artist, let theAlbum = album {
                
                fullLengthArtistAlbumStr = String(format: "%@ -- %@", theArtist, theAlbum)
                truncatedArtistAlbumStr = truncateCompositeString(TextSizes.artistAlbumFont, lineWidth, fullLengthArtistAlbumStr!, theArtist, theAlbum, " -- ")
                
            } else if let theArtist = artist {
                
                truncatedArtistAlbumStr = StringUtils.truncate(theArtist, TextSizes.artistAlbumFont, lineWidth)
                fullLengthArtistAlbumStr = theArtist
                
            } else if let theAlbum = album {
                
                truncatedArtistAlbumStr = StringUtils.truncate(theAlbum, TextSizes.artistAlbumFont, lineWidth)
                fullLengthArtistAlbumStr = theAlbum
            }
            
            let hasArtistAlbum: Bool = truncatedArtistAlbumStr != nil
            let hasChapter: Bool = PlayerViewState.showCurrentChapter && chapter != nil
            
            // TODO: Line spacing is also dependent on TextSize. Add TextSizes.titleArtistLineSpacing, etc.
            
            // Title
            let truncatedTitle: String = hasArtistAlbum || hasChapter ? StringUtils.truncate(title, TextSizes.titleFont, lineWidth) : title
            txt.textStorage?.append(attributedString(truncatedTitle, TextSizes.titleFont, Colors.trackInfoTitleTextColor, hasArtistAlbum ? 3 : (hasChapter ? 5 : nil)))
            
            // Artist / Album
            if let _truncatedArtistAlbumStr = truncatedArtistAlbumStr {
                txt.textStorage?.append(attributedString(_truncatedArtistAlbumStr, TextSizes.artistAlbumFont, Colors.trackInfoArtistAlbumTextColor, hasChapter ? 7 : nil))
            }
            
            // Chapter
            if hasChapter, let chapterStr = chapter {
                
                let truncatedChapter: String = StringUtils.truncate(chapterStr, TextSizes.chapterFont, lineWidth)
                txt.textStorage?.append(attributedString(truncatedChapter, TextSizes.chapterFont, Colors.trackInfoChapterTextColor))
            }
            
            txt.toolTip = String(format: "%@%@%@", title, fullLengthArtistAlbumStr != nil ? "\n\n" + fullLengthArtistAlbumStr! : "", chapter != nil ? "\n\n" + chapter! : "")
            
            centerAlign()
        }
    }
    
    private func truncateCompositeString(_ font: NSFont, _ maxWidth: CGFloat, _ str: String, _ s1: String, _ s2: String, _ separator: String) -> String {
        
        // Check if str fits. If so, no need to truncate
        let origWidth = StringUtils.widthOfString(str, font)
        
        if origWidth <= maxWidth {
            return str
        }
        
        // If str doesn't fit, find out which is longer ... s1 or s2 ... truncate the longer one just enough to fit
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
            return StringUtils.truncate(str, font, maxWidth)
        }
    }
    
    private func centerAlign() {
        
        // Horizontal alignment
        txt.setAlignment(.center, range: .init(location: 0, length: txt.string.count))
        
        // Vertical alignment
        txt.layoutManager?.ensureLayout(for: txt.textContainer!)

        if let txtHeight = txt.layoutManager?.usedRect(for: txt.textContainer!).height {

            let htDiff = self.frame.height - txtHeight
            clipView.contentInsets.top = htDiff / 2
        }
    }
    
    private func attributedString(_ text: String, _ font: NSFont, _ color: NSColor, _ lineSpacing: CGFloat? = nil) -> NSAttributedString {
        
        var attributes = [ NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color ]
        
        var str: String = text
        
        if let spacing = lineSpacing {
            
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.lineSpacing = spacing
            
            attributes[NSAttributedString.Key.paragraphStyle] = paraStyle
            
            str += "\n"
        }
        
        return NSAttributedString(string: str, attributes: attributes)
    }
}
