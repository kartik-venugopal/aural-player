import Cocoa

class MusicBrainzCache {
    
    // For a given artist / release title combo, cache art for later use (other tracks from the same album).
    private var cache: [String: [String: CoverArt]] = [:]
    var onDiskCache: [String: [String: URL]] = [:]
    
    private let baseDir: URL = AppConstants.FilesAndPaths.baseDir.appendingPathComponent("musicBrainzCache", isDirectory: true)
    
    init(state: MusicBrainzCacheState) {
        
        DispatchQueue.global(qos: .utility).async {
            
            FileSystemUtils.createDirectory(self.baseDir)
            
            for entry in state.entries {
                
                if FileSystemUtils.fileExists(entry.file), let image = NSImage(contentsOfFile: entry.file.path) {
                    
                    do {
                        
                        let imgData: Data = try Data(contentsOf: entry.file)
                        let metadata = ParserUtils.getImageMetadata(imgData as NSData)
                        
                        if self.cache[entry.artist] == nil {
                            self.cache[entry.artist] = [:]
                        }
                        
                        if self.onDiskCache[entry.artist] == nil {
                            self.onDiskCache[entry.artist] = [:]
                        }
                        
                        self.cache[entry.artist]?[entry.releaseTitle] = CoverArt(image, metadata)
                        self.onDiskCache[entry.artist]?[entry.releaseTitle] = entry.file
                        
                    } catch {}
                }
            }
        }
    }
    
    func getFor(artist: String, releaseTitle: String) -> CoverArt? {
        return cache[artist]?[releaseTitle]
    }
    
    func putFor(artist: String, releaseTitle: String, coverArt: CoverArt) {
        
        if cache[artist] == nil {
            cache[artist] = [:]
        }
        
        cache[artist]?[releaseTitle] = coverArt
        
        // TODO: When the app exits, make sure this is not still running.
        // Perhaps use an opQueue, and waitTillAllTasksCompleted() ???
        // Write the file to disk
        DispatchQueue.global(qos: .utility).async {
            
            let nowString = Date().serializableString_hms()
            let randomNum = Int.random(in: 0..<10000)
            
            let outputFileName = String(format: "%@-%@-%@-%d.jpg", artist, releaseTitle, nowString, randomNum)
            let file = self.baseDir.appendingPathComponent(outputFileName)
            
            do {
                
                try coverArt.image.writeToFile(fileType: .jpeg, file: file)
                
                if self.onDiskCache[artist] == nil {
                    self.onDiskCache[artist] = [:]
                }
                
                self.onDiskCache[artist]?[releaseTitle] = file
                
            } catch {
                NSLog("Error writing image file to the MusicBrainz on-disk cache: \(error)")
            }
        }
    }
}
