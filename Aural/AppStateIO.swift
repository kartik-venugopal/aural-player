/*
    A collection of assorted utility functions that perform I/O for app state (settings, playlist)
*/

import AVFoundation

class AppStateIO {
    
    // Saves app state to default user documents directory
    static func save(_ state: AppState) {
        
        FileSystemUtils.createDirectory(AppConstants.FilesAndPaths.baseDir)
        
        if let outputStream = OutputStream(url: AppConstants.FilesAndPaths.appStateFile, append: false) {
            
            outputStream.open()
            
            let jsonObject = JSONMapper.map(state)
            if !JSONSerialization.isValidJSONObject(jsonObject) {
                NSLog("Error saving app state config file: Invalid JSON object.")
                outputStream.close()
                return
            }
            
            var ioError: NSError?
            let bytesWritten = JSONSerialization.writeJSONObject(jsonObject, to: outputStream, options: JSONSerialization.WritingOptions.prettyPrinted, error: &ioError)
            
            if let error = ioError {
                NSLog("Error saving app state config file: %@", error.description)
            } else if bytesWritten == 0 {
                NSLog("Error saving app state config file: No bytes written to the stream.")
            }
            
            outputStream.close()
            
        } else {
            NSLog("Error saving app state config file: Unable to create output stream.")
        }
    }
    
    // Loads app state from default user documents directory
    static func load() -> AppState? {
        
        if let inputStream = InputStream(url: AppConstants.FilesAndPaths.appStateFile) {
            
            inputStream.open()
            
            do {
                
                let data = try JSONSerialization.jsonObject(with: inputStream, options: JSONSerialization.ReadingOptions())
                inputStream.close()
                return AppState.deserialize(data as! NSDictionary)
                
            } catch let error as NSError {
                NSLog("Error loading app state config file: %@", error.description)
            }
        }
        
        return nil
    }
}
