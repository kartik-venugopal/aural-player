/*
A collection of assorted utility functions that perform I/O for AuralPlayer state (settings, playlist)
*/

import Foundation
import AVFoundation

class PlayerStateIO {
    
    static let configFileName = "auralPlayer-state.json"
    
    // Saves app config to default user documents directory
    static func save(state: SavedPlayerState) {
        
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(configFileName)
            
            let outputStream = NSOutputStream(URL: path, append: false)
            outputStream?.open()
            
            NSJSONSerialization.writeJSONObject(state.forWritingAsJSON(), toStream: outputStream!, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
            
            outputStream?.close()
        }
    }
    
    // Loads app config from default user documents directory
    static func load() -> SavedPlayerState? {
        
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(configFileName)
            
            let inputStream = NSInputStream(URL: path)
            inputStream?.open()
            
            do {
                let data = try NSJSONSerialization.JSONObjectWithStream(inputStream!, options: NSJSONReadingOptions())
                
                inputStream?.close()
                
                return SavedPlayerState.fromJSON(data as! NSDictionary)
                
            } catch let error as NSError {
                print(error.description)
            }
        }
        
        return nil
    }
}