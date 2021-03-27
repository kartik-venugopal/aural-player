import Foundation

class FileCoverArtReader: CoverArtReaderProtocol {
    
    private var fileReader: FileReaderProtocol
    
    private var searchedTracks: Set<Track> = Set()
    
    init(_ fileReader: FileReaderProtocol) {
        self.fileReader = fileReader
    }
 
    func getCoverArt(forTrack track: Track) -> CoverArt? {
        searchedTracks.contains(track) ? nil : fileReader.getArt(for: track.file)
    }
}
