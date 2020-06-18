import Cocoa

class EffectsViewPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var textSizeNormalMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargerMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargestMenuItem: NSMenuItem!
    
    private var textSizes: [NSMenuItem] = []
    
    override func awakeFromNib() {
        textSizes = [textSizeNormalMenuItem, textSizeLargerMenuItem, textSizeLargestMenuItem]
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        textSizes.forEach({
            $0.off()
        })
        
        switch EffectsViewState.textSize {
            
        case .normal:   textSizeNormalMenuItem.on()
            
        case .larger:   textSizeLargerMenuItem.on()
            
        case .largest:  textSizeLargestMenuItem.on()
            
        }
    }
    
    @IBAction func changeTextSizeAction(_ sender: NSMenuItem) {
        
        if let size = TextSize(rawValue: sender.title.lowercased()), EffectsViewState.textSize != size {
            
            EffectsViewState.textSize = size
            Messenger.publish(.fx_changeTextSize, payload: size)
        }
    }
}
