import Cocoa

class AlbumArtManager {
    
    private static let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    private static var cache: [URL: NSImage] = [:]
    private static var filesWithNoArt: Set<URL> = Set<URL>()
    
    static func getArtForFile(_ file: URL) -> NSImage? {
        
        if let img = cache[file] {
            return img
        }
        
        if let track = playlist.findFile(file) {
            
            cache[file] = track.track.displayInfo.art
            return track.track.displayInfo.art
        }
        
        // This file is known to have no embedded art
        if filesWithNoArt.contains(file) {
            return nil
        }
        
        
        if let img = MetadataUtils.artForFile(file) {
        
            // Read from file
            cache[file] = img
            return img
            
        } else {

            // No art in file. Remember this for the future.
            filesWithNoArt.insert(file)
            return nil
        }
    }
}
