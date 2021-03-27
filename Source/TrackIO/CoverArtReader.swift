import Foundation

protocol CoverArtReaderProtocol {
    
    func getCoverArt(forTrack track: Track) -> CoverArt?
}

class CoverArtReader: CoverArtReaderProtocol {
    
    
    
    func getCoverArt(forTrack track: Track) -> CoverArt? {
        return nil
    }
}
