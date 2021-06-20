/*
    Handles persistence to/from disk for application state.
*/
import AVFoundation

class AppStateIO {
    
    // Saves app state to default user documents directory
    static func save(_ state: PersistentAppState) {
        
        FileSystemUtils.createDirectory(AppConstants.FilesAndPaths.baseDir)
        
        let jsonObject = JSONMapper.map(state)
        let file = AppConstants.FilesAndPaths.persistentStateFile
        
        do {
            
            try JSONWriter.writeObject(jsonObject, file, true)
            
        } catch let error as NSError {
           NSLog("Error saving app state config file: %@", error.description)
        }
    }
    
    // Loads app state from default user documents directory
    static func load() -> PersistentAppState? {
        
        if let inputStream = InputStream(url: AppConstants.FilesAndPaths.persistentStateFile) {
            
            inputStream.open()
            
            do {
                
                let data = try JSONSerialization.jsonObject(with: inputStream, options: JSONSerialization.ReadingOptions())
                inputStream.close()
                
                return PersistentAppState.deserialize(data as! NSDictionary)
                
            } catch let error as NSError {
                NSLog("Error loading app state config file: %@", error.description)
            }
        }
        
        return nil
    }
}
