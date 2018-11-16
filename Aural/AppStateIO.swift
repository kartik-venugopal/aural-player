/*
    A collection of assorted utility functions that perform I/O for app state (settings, playlist)
*/

import Foundation
import AVFoundation

class AppStateIO {
    
    // Saves app state to default user documents directory
    static func save(_ state: AppState) {
        
        let outputStream = OutputStream(url: AppConstants.FilesAndPaths.appStateFile, append: false)
        outputStream?.open()
        
        JSONSerialization.writeJSONObject(Mapper.map(state), to: outputStream!, options: JSONSerialization.WritingOptions.prettyPrinted, error: nil)
        
        outputStream?.close()
    }
    
    // Loads app state from default user documents directory
    static func load() -> AppState? {
        
        let inputStream = InputStream(url: AppConstants.FilesAndPaths.appStateFile)
        inputStream?.open()
        
        do {
            let data = try JSONSerialization.jsonObject(with: inputStream!, options: JSONSerialization.ReadingOptions())
            
            inputStream?.close()
            
            return AppState.deserialize(data as! NSDictionary)
            
        } catch let error as NSError {
            NSLog("Error loading app state config file: %@", error.description)
        }
        
        return nil
    }
}
