import Cocoa

/*
    View that gives the user a visual preview of what the UI would look like if a particular color scheme is applied to it.
 */
class FontSchemePreviewView: NSView {
    
    @IBOutlet weak var containerBox: NSBox!
    
    @IBOutlet weak var lblPlayerTrackTitle: NSTextField!
    @IBOutlet weak var lblPlayerArtistAlbum: NSTextField!
    
    @IBOutlet weak var lblPlaylistHeading: NSTextField!
    @IBOutlet weak var lblPlaylistIndex: NSTextField!
    @IBOutlet weak var lblPlaylistTitle: NSTextField!
    @IBOutlet weak var lblPlaylistDuration: NSTextField!
    
    @IBOutlet weak var lblFxCaption: NSTextField!
    @IBOutlet weak var lblPitchCaption: NSTextField!
    @IBOutlet weak var lblPitchValue: NSTextField!
    
    private var playlistLabels: [NSTextField] = []
    
    override func awakeFromNib() {
        playlistLabels = [lblPlaylistIndex, lblPlaylistTitle, lblPlaylistDuration]
    }
    
    // When any of the following fields is set, update the corresponding fields.
    
    var scheme: FontScheme? {
        
        didSet {
            
            if let theScheme = scheme {
               
                playerTitleFont = theScheme.player.infoBoxTitleFont
                playerArtistAlbumFont = theScheme.player.infoBoxArtistAlbumFont
                
                playlistHeadingFont = theScheme.playlist.tabButtonTextFont
                playlistTrackTextFont = theScheme.playlist.trackTextFont
                
                fxCaptionFont = theScheme.effects.unitCaptionFont
                fxFunctionFont = theScheme.effects.unitFunctionFont
                
//                [playlistTabButton, playlistSelectedTabButton].forEach({$0?.redraw()})
                containerBox.show()
            }
        }
    }
    
    var playerTitleFont: NSFont = Fonts.Standard.mainFont_12 {
        
        didSet {
            lblPlayerTrackTitle.font = playerTitleFont
        }
    }
    
    var playerArtistAlbumFont: NSFont = Fonts.Standard.mainFont_12 {
        
        didSet {
            lblPlayerArtistAlbum.font = playerArtistAlbumFont
        }
    }
    
    var playlistHeadingFont: NSFont = Fonts.Standard.mainFont_12 {
        
        didSet {
            lblPlaylistHeading.font = playlistHeadingFont
        }
    }
    
    var playlistTrackTextFont: NSFont = Fonts.Standard.mainFont_12 {
        
        didSet {
            playlistLabels.forEach {$0.font = playlistTrackTextFont}
        }
    }
    
    var fxCaptionFont: NSFont = Fonts.Standard.mainFont_12 {
        
        didSet {
            lblFxCaption.font = fxCaptionFont
        }
    }
    
    var fxFunctionFont: NSFont = Fonts.Standard.mainFont_12 {
        
        didSet {
            lblPitchCaption.font = fxFunctionFont
            lblPitchValue.font = fxFunctionFont
        }
    }
    
    func clear() {
        containerBox.hide()
    }
}
