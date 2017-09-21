/*
    A collection of assorted utility functions that perform I/O for app state (settings, playlist)
*/

import Foundation
import AVFoundation

class AppStateIO {
    
    // Saves app state to default user documents directory
    static func save(_ state: AppState) {
        
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            
            let path = URL(fileURLWithPath: dir).appendingPathComponent(AppConstants.stateFileName)
            
            let outputStream = OutputStream(url: path, append: false)
            outputStream?.open()
            
            JSONSerialization.writeJSONObject(state.forWritingAsJSON(), to: outputStream!, options: JSONSerialization.WritingOptions.prettyPrinted, error: nil)
            
            outputStream?.close()
        }
    }
    
    // Loads app state from default user documents directory
    static func load() -> AppState? {
        
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            
            let path = URL(fileURLWithPath: dir).appendingPathComponent(AppConstants.stateFileName)
            
            let inputStream = InputStream(url: path)
            inputStream?.open()
            
            do {
                let data = try JSONSerialization.jsonObject(with: inputStream!, options: JSONSerialization.ReadingOptions())
                
                inputStream?.close()
                
                return AppState.fromJSON(data as! NSDictionary)
                
            } catch let error as NSError {
                NSLog("Error loading player state config file: %@", error.description)
            }
        }
        
        return nil
    }
}
