import Foundation

class FileCoverArtReader: CoverArtReaderProtocol {
    
    private var fileReader: FileReaderProtocol
    
    private var searchedTracks: ConcurrentSet<Track> = ConcurrentSet()
    
    init(_ fileReader: FileReaderProtocol) {
        self.fileReader = fileReader
    }
 
    func getCoverArt(forTrack track: Track) -> CoverArt? {
        
        if searchedTracks.contains(track) {return nil}
        
        searchedTracks.insert(track)
        return fileReader.getArt(for: track.file)
    }
}
