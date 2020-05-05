import Cocoa

class PlayingTrackFunctionsView: NSView, ColorSchemeable {

    @IBOutlet weak var btnMoreInfo: TintedImageButton!
    @IBOutlet weak var btnShowPlayingTrackInPlaylist: TintedImageButton!
    @IBOutlet weak var btnFavorite: OnOffImageButton!
    @IBOutlet weak var btnBookmark: TintedImageButton!
    
    private var allButtons: [Tintable] = []
    
    override func awakeFromNib() {
        allButtons = [btnMoreInfo, btnShowPlayingTrackInPlaylist, btnFavorite, btnBookmark]
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        changeFunctionButtonColor(scheme.general.functionButtonColor)
    }
    
    func changeFunctionButtonColor(_ color: NSColor) {
        allButtons.forEach({$0.reTint()})
    }
    
    func changeToggleButtonOffStateColor(_ color: NSColor) {
        btnFavorite.reTint()
    }
}
