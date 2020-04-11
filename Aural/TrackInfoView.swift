import Cocoa

class TrackInfoView: NSView {
    
    static let titleFont: NSFont = NSFont(name: "Gill Sans Semibold", size: 16)!
    static let artistAlbumFont: NSFont = NSFont(name: "Gill Sans Semibold", size: 14)!
    static let chapterFont: NSFont = NSFont(name: "Gill Sans Semibold", size: 12)!
    
    @IBOutlet weak var txt: NSTextView!
    
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
        return track?.displayInfo.artist
    }
    
    var album: String? {
        return track?.groupingInfo.album
    }
    
    var chapter: String?
    
    var artistAndAlbum: String? {
        
        if let theArtist = artist, let theAlbum = album {
            
            return String(format: "%@ -- %@", theArtist, theAlbum)
            
        } else if let theArtist = artist {
            
            return theArtist
            
        } else if let theAlbum = album {
            
            return theAlbum
            
        } else {
            
            return nil
        }
    }
    
    func showNowPlayingInfo(_ track: Track, _ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int), _ chapter: String?) {
        self.track = track
        self.chapter = chapter
    }
    
    private func update() {
        
        txt.string = ""
        
        if track != nil {
            
            let artistAlbumStr = artistAndAlbum
            let hasArtistAlbum: Bool = artistAlbumStr != nil
            let hasChapter: Bool = chapter != nil
            
            let titleString = attributedString(title, TextSizes.titleFont, NSColor(white: 0.55, alpha: 1), hasArtistAlbum ? 3 : (hasChapter ? 5 : nil))
            txt.textStorage?.append(titleString)
            
            if let _artistAlbumStr = artistAlbumStr {
                
                let artistAlbumString = attributedString(_artistAlbumStr, TextSizes.artistAlbumFont, NSColor(white: 0.7, alpha: 1), hasChapter ? 7 : nil)
                txt.textStorage?.append(artistAlbumString)
            }
            
            if let chapterStr = chapter {
                
                let chapterString = attributedString(chapterStr, TextSizes.chapterFont, NSColor(white: 0.65, alpha: 1))
                txt.textStorage?.append(chapterString)
            }
            
            txt.setAlignment(.center, range: .init(location: 0, length: txt.string.count))
            
            // Vertically center
            
            txt.layoutManager?.ensureLayout(for: txt.textContainer!)
            print(txt.layoutManager!.usedRect(for: txt.textContainer!).height)
            
            if let txtHeight = txt.layoutManager?.usedRect(for: txt.textContainer!).height {
                
                let htDiff = self.frame.height - txtHeight
                
                var txtFrame = self.frame
                txtFrame.origin.y = 0 - htDiff / 2
                
                self.frame = txtFrame
                print("txt frame now:", self.frame)
            }
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
