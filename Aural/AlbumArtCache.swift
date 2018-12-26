import Cocoa

class AlbumArtCache {
    
    private static var cache: ConcurrentMap<URL, NSImage> = ConcurrentMap<URL, NSImage>("threadSafeAccess-artCache")
    private static var filesWithNoArt: ConcurrentSet<URL> = ConcurrentSet<URL>("threadSafeAccess-filesWithNoArt")
    
    static func forFile(_ file: URL) -> (fileHasNoArt: Bool, art: NSImage?) {
        return (filesWithNoArt.contains(file), cache.getForKey(file))
    }
    
    static func addEntry(_ file: URL, _ image: NSImage?) {
        
        if let img = image {
            cache.put(file, img)
        } else {
            filesWithNoArt.insert(file)
        }
    }
}
