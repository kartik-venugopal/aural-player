import Cocoa

// TODO: Figure out where and how this utility can be used for better performance.
class AlbumArtCache {
    
    private static var cache: ConcurrentMap<URL, CoverArt> = ConcurrentMap<URL, CoverArt>("threadSafeAccess-artCache")
    private static var filesWithNoArt: ConcurrentSet<URL> = ConcurrentSet<URL>("threadSafeAccess-filesWithNoArt")
    
    // TODO: Clean out albumArt store (filesystem folder)
    
    static func forFile(_ file: URL) -> (fileHasNoArt: Bool, art: CoverArt?) {
        return (filesWithNoArt.contains(file), cache[file])
    }
    
    static func addEntry(_ file: URL, _ art: CoverArt?) {
        
        if let theArt = art {
            cache[file] = theArt
            
        } else {
            filesWithNoArt.insert(file)
        }
    }
}
