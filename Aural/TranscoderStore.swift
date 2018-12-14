import Foundation

class TranscoderStore {
    
    var map: [URL: URL] = [:]
    
    var baseDir: URL
    
    init() {
        baseDir = AppConstants.FilesAndPaths.baseDir.appendingPathComponent("transcoderStore", isDirectory: true)
        FileSystemUtils.createDirectory(baseDir)
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
