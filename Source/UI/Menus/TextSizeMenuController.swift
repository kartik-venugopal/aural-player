import Cocoa

class TextSizeMenuController: NSObject, NSMenuDelegate {
    
    @IBAction func changeTextSizeAction(_ sender: NSMenuItem) {
        
        let senderTitle: String = sender.title.lowercased()
        
        if let size = TextSize(rawValue: senderTitle) {
            
            if PlayerViewState.textSize != size {
                
                PlayerViewState.textSize = size
                Messenger.publish(.changePlayerTextSize, payload: size)
            }
            
            if PlaylistViewState.textSize != size {
                
                PlaylistViewState.textSize = size
                Messenger.publish(.changePlaylistTextSize, payload: size)
            }
            
            if EffectsViewState.textSize != size {
                
                EffectsViewState.textSize = size
                Messenger.publish(.changeFXTextSize, payload: size)
            }
        }
    }
}
