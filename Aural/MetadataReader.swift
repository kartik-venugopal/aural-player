import Cocoa

protocol MetadataReader {
    
    func getPrimaryMetadata(_ track: Track) -> PrimaryMetadata
    
    func getSecondaryMetadata(_ track: Track) -> SecondaryMetadata
    
    func getArt(_ track: Track) -> NSImage?
    
    func getArt(_ file: URL) -> NSImage?
    
    func getAllMetadata() -> [String: String]
    
    func getPlaybackInfo() -> PlaybackInfo
}

class PrimaryMetadata {
    
    let title: String?
    let artist: String?
    let album: String?
    let genre: String?
    
    let duration: Double
    
    init(_ title: String?, _ artist: String?, _ album: String?, _ genre: String?, _ duration: Double) {
        
        self.title = title
        self.artist = artist
        self.album = album
        self.genre = genre
        
        self.duration = duration
    }
}

class SecondaryMetadata {
    
    let discNum: Int?
    let trackNum: Int?
    let art: NSImage?
    
    init(_ art: NSImage?, _ discNum: Int?, _ trackNum: Int?) {
        
        self.art = art
        self.discNum = discNum
        self.trackNum = trackNum
    }
}
