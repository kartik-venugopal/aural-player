import Cocoa

class TextSizeMenuController: NSObject, NSMenuDelegate {
    
    @IBAction func changeTextSizeAction(_ sender: NSMenuItem) {
        
        let senderTitle: String = sender.title.lowercased()
        
        if let size = TextSize(rawValue: senderTitle) {
            
            if PlayerViewState.textSize != size {
                
                PlayerViewState.textSize = size
                Messenger.publish(.player_changeTextSize, payload: size)
            }
            
            if PlaylistViewState.textSize != size {
                
                PlaylistViewState.textSize = size
                Messenger.publish(.playlist_changeTextSize, payload: size)
            }
            
            if EffectsViewState.textSize != size {
                
                EffectsViewState.textSize = size
                Messenger.publish(.fx_changeTextSize, payload: size)
            }
        }
    }
}
