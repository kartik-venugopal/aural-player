import Cocoa

protocol MetadataReader {
    
    func getPrimaryMetadata(_ track: Track) -> PrimaryMetadata
    
    func getSecondaryMetadata(_ track: Track) -> SecondaryMetadata
    
    func getDurationForFile(_ file: URL) -> Double
    
    func getArt(_ track: Track) -> CoverArt?
    
    func getArt(_ file: URL) -> CoverArt?
    
    func getAllMetadata(_ track: Track) -> [String: MetadataEntry]
}

class PrimaryMetadata {
    
    let title: String?
    let artist: String?
    let album: String?
    let genre: String?
    
    let chapters: [Chapter]
    
    let duration: Double
    
    init(_ title: String?, _ artist: String?, _ album: String?, _ genre: String?, _ duration: Double, _ chapters: [Chapter]) {
        
        self.title = title
        self.artist = artist
        self.album = album
        self.genre = genre
        
        self.duration = duration
        self.chapters = chapters
    }
}

class Chapter {
    
    let title: String
    let startTime: Double
    let endTime: Double
    let duration: Double
    
    init(_ title: String, _ startTime: Double, _ endTime: Double) {
        
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        
        self.duration = max(endTime - startTime, 0)
    }
}

class SecondaryMetadata {
    
    let discNum: Int?
    let totalDiscs: Int?
    
    let trackNum: Int?
    let totalTracks: Int?
    
    let lyrics: String?
    
    init(_ discNum: Int?, _ totalDiscs: Int?, _ trackNum: Int?, _ totalTracks: Int?, _ lyrics: String?) {
        
        self.discNum = discNum
        self.totalDiscs = totalDiscs
        
        self.trackNum = trackNum
        self.totalTracks = totalTracks
        
        self.lyrics = lyrics
    }
}
