/*
    Handles persistence to/from disk for application state.
*/
import AVFoundation

class AppStateIO {
    
    static let persistentStateFile: URL = AppConstants.FilesAndPaths.persistentStateFile
    
    // Saves app state to default user documents directory
    static func save(_ state: PersistentAppState) {
        
        FileSystemUtils.createDirectory(AppConstants.FilesAndPaths.baseDir)
        
        let jsonObject = JSONMapper.map(state)
        
        do {
            
            try JSONWriter.writeObject(jsonObject, persistentStateFile, true)
            
        } catch let error as NSError {
           NSLog("Error saving app state config file: %@", error.description)
        }
    }
    
    // Loads app state from default user documents directory
    static func load() -> PersistentAppState? {
        
        if let inputStream = InputStream(url: persistentStateFile) {
            
            inputStream.open()
            
            do {
                
                let data = try JSONSerialization.jsonObject(with: inputStream, options: JSONSerialization.ReadingOptions())
                inputStream.close()
                
                if let dictionary = data as? NSDictionary {
                    return PersistentAppState(dictionary)
                }
                
            } catch let error as NSError {
                NSLog("Error loading app state config file: %@", error.description)
            }
        }
        
        return nil
    }
}
