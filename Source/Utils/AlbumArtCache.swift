import Cocoa

class AlbumArtCache {
    
    private static var cache: ConcurrentMap<URL, CoverArt> = ConcurrentMap<URL, CoverArt>("threadSafeAccess-artCache")
    private static var filesWithNoArt: ConcurrentSet<URL> = ConcurrentSet<URL>("threadSafeAccess-filesWithNoArt")
    
    static func forFile(_ file: URL) -> (fileHasNoArt: Bool, art: CoverArt?) {
        return (filesWithNoArt.contains(file), cache.getForKey(file))
    }
    
    static func addEntry(_ file: URL, _ art: CoverArt?) {
        
        if let art = art {
            cache.put(file, art)
        } else {
            filesWithNoArt.insert(file)
        }
    }
}
