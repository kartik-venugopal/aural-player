import Cocoa

/*
     Provides actions for the View menu that alters the layout of the app's windows and views.
     
     NOTE - No actions are directly handled by this class. Command notifications are published to another app component that is responsible for these functions.
 */
class PlaylistViewMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var textSizeNormalMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargerMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargestMenuItem: NSMenuItem!
    private var textSizes: [NSMenuItem] = []
    
    override func awakeFromNib() {
        textSizes = [textSizeNormalMenuItem, textSizeLargerMenuItem, textSizeLargestMenuItem]
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
        textSizes.forEach({
            $0.off()
        })
        
        switch PlaylistViewState.textSize {
            
        case .normal:   textSizeNormalMenuItem.on()
            
        case .larger:   textSizeLargerMenuItem.on()
            
        case .largest:  textSizeLargestMenuItem.on()
            
        }
    }
    
    @IBAction func changeTextSizeAction(_ sender: NSMenuItem) {
        
        if let size = TextSize(rawValue: sender.title.lowercased()), PlaylistViewState.textSize != size {
            
            PlaylistViewState.textSize = size
            Messenger.publish(.playlist_changeTextSize, payload: size)
        }
    }
}

class EffectsViewMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var textSizeNormalMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargerMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargestMenuItem: NSMenuItem!
    private var textSizes: [NSMenuItem] = []
    
    override func awakeFromNib() {
        textSizes = [textSizeNormalMenuItem, textSizeLargerMenuItem, textSizeLargestMenuItem]
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
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
