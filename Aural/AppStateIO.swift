/*
    A collection of assorted utility functions that perform I/O for app state (settings, playlist)
*/

import AVFoundation

class AppStateIO {
    
    // Saves app state to default user documents directory
    static func save(_ state: AppState) {
        
        FileSystemUtils.createDirectory(AppConstants.FilesAndPaths.baseDir)
        
        let jsonObject = JSONMapper.map(state)
        let file = AppConstants.FilesAndPaths.appStateFile
        
        do { try JSONWriter.writeObject(jsonObject, file, true) } catch {}
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
