import Cocoa

class TextSizeMenuController: NSObject, NSMenuDelegate {
    
    @IBAction func changeTextSizeAction(_ sender: NSMenuItem) {
        
        let senderTitle: String = sender.title.lowercased()
        
        if let size = TextSize(rawValue: senderTitle) {
            
            if PlayerViewState.textSize != size {
                
                PlayerViewState.textSize = size
                SyncMessenger.publishActionMessage(TextSizeActionMessage(.changePlayerTextSize, size))
            }
            
            if PlaylistViewState.textSize != size {
                
                PlaylistViewState.textSize = size
                SyncMessenger.publishActionMessage(TextSizeActionMessage(.changePlaylistTextSize, size))
            }
            
            if EffectsViewState.textSize != size {
                
                EffectsViewState.textSize = size
                SyncMessenger.publishActionMessage(TextSizeActionMessage(.changeEffectsTextSize, size))
            }
        }
    }
}
