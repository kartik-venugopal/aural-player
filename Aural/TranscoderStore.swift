import Foundation

class TranscoderStore {
    
    let baseDir: URL
    var map: [URL: URL] = [:]
    
    let preferences: TranscodingPreferences

    init(_ state: TranscoderState, _ preferences: TranscodingPreferences) {
        
        self.preferences = preferences
        
        baseDir = AppConstants.FilesAndPaths.baseDir.appendingPathComponent("transcoderStore", isDirectory: true)
        FileSystemUtils.createDirectory(baseDir)
        
        if preferences.persistenceOption == .save {
            
            state.entries.forEach({
                map[$0.key] = $0.value
            })
        }
    }
    
    func addEntry(_ track: Track, _ outputFileName: String) -> URL {
  
        let outputFile = baseDir.appendingPathComponent(outputFileName, isDirectory: false)
        map[track.file] = outputFile
        return outputFile
    }

    func getForTrack(_ track: Track) -> URL? {
        
        if let outFile = map[track.file] {
            if FileSystemUtils.fileExists(outFile) {
                return outFile
            }
            
            map.removeValue(forKey: track.file)
        }
        
        return nil
    }

    func hasForTrack(_ track: Track) -> Bool {
        return getForTrack(track) != nil
    }
    
    func deleteEntry(_ track: Track) {
        map.removeValue(forKey: track.file)
    }
}
