import Cocoa

///
/// A utility that serves as an in-memory cache for cover art retrieved from tracks. This is useful because multiple lookups
/// for the same cover art may occur (different parts of the UI require the same image), and this cache avoids redundant
/// disk reads for cover art that has already been loaded from disk once.
///
class AlbumArtCache {
    
    private static var cache: ConcurrentMap<URL, CoverArt> = ConcurrentMap<URL, CoverArt>()
    private static var filesWithNoArt: ConcurrentSet<URL> = ConcurrentSet<URL>()
    
    // TODO: Clean out albumArt store (filesystem folder) in aural directory for newer app version users.
    
    static func forFile(_ file: URL) -> (fileHasNoArt: Bool, art: CoverArt?)? {
        
        if filesWithNoArt.contains(file) || cache.hasForKey(file) {
            return (filesWithNoArt.contains(file), cache[file])
        }
        
        return nil
    }
    
    static func addEntry(_ file: URL, _ art: CoverArt?) {
        
        if let theArt = art {
            cache[file] = theArt
            
        } else {
            filesWithNoArt.insert(file)
        }
    }
}
