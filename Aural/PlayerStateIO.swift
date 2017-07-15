/*
A collection of assorted utility functions that perform I/O for AuralPlayer state (settings, playlist)
*/

import Foundation
import AVFoundation

class PlayerStateIO {
    
    // Saves app config to default user documents directory
    static func save(_ state: SavedPlayerState) {
        
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            
            let path = URL(fileURLWithPath: dir).appendingPathComponent(AppConstants.stateFileName)
            
            let outputStream = OutputStream(url: path, append: false)
            outputStream?.open()
            
            JSONSerialization.writeJSONObject(state.forWritingAsJSON(), to: outputStream!, options: JSONSerialization.WritingOptions.prettyPrinted, error: nil)
            
            outputStream?.close()
        }
    }
    
    // Loads app config from default user documents directory
    static func load() -> SavedPlayerState? {
        
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            
            let path = URL(fileURLWithPath: dir).appendingPathComponent(AppConstants.stateFileName)
            
            let inputStream = InputStream(url: path)
            inputStream?.open()
            
            do {
                let data = try JSONSerialization.jsonObject(with: inputStream!, options: JSONSerialization.ReadingOptions())
                
                inputStream?.close()
                
                return SavedPlayerState.fromJSON(data as! NSDictionary)
                
            } catch let error as NSError {
                NSLog("Error loading player state config file: %@", error.description)
            }
        }
        
        return nil
    }
}
