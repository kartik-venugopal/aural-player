import Cocoa

class AlbumArtManager {
    
    private static let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    private static var cache: [URL: NSImage] = [:]
    
    static func getArtForFile(_ file: URL) -> NSImage? {
        
        if let img = cache[file] {
            return img
        }
        
        if let track = playlist.findFile(file) {
            cache[file] = track.track.displayInfo.art
            return track.track.displayInfo.art
        }
        
//        if let img = MetadataUtils.loadArtworkForFile(file) {
//            cache[file] = img
//            return img
//        }
        
        return nil
    }
}
