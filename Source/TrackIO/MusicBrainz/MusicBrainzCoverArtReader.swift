import Cocoa

class MusicBrainzCoverArtReader: CoverArtReaderProtocol {
    
    private let restAPIClient: MusicBrainzRESTClient
    
    // Cache art for later use (other tracks from the same release / recording).
    let cache: MusicBrainzCache
    
    private let preferences: MusicBrainzPreferences
    
    private var searchedTracks: Set<Track> = Set()
    
    init(_ state: MusicBrainzCacheState, _ preferences: MusicBrainzPreferences) {

        self.restAPIClient = MusicBrainzRESTClient()
        self.cache = MusicBrainzCache(state, preferences)
        self.preferences = preferences
    }
    
    func getCoverArt(forTrack track: Track) -> CoverArt? {
        
        if (!preferences.enableCoverArtSearch) || searchedTracks.contains(track) {return nil}
        
        searchedTracks.insert(track)
        
        guard let artist = track.artist else {return nil}
        let lcArtist = artist.lowerCasedAndTrimmed()
        
        if let album = track.album,
           let coverArt = searchReleases(forArtist: lcArtist, andReleaseTitle: album.lowerCasedAndTrimmed()) {
            
            return coverArt
        }
        
        if let title = track.title,
           let coverArt = searchRecordings(forArtist: lcArtist, andRecordingTitle: title.lowerCasedAndTrimmed()) {
            
            return coverArt
        }
        
        return nil
    }
    
    private func searchReleases(forArtist artist: String, andReleaseTitle releaseTitle: String) -> CoverArt? {
        
        // Look for cover art in the cache first.
        if let coverArt = cache.getForRelease(artist: artist, title: releaseTitle) {
            return coverArt
        }
        
        do {
            
            if let coverArt = try restAPIClient.getCoverArt(forArtist: artist, andReleaseTitle: releaseTitle) {
                
                // Add this entry to the cache.
                cache.putForRelease(artist: artist, title: releaseTitle, coverArt: coverArt)
                return coverArt
            }
            
        } catch {
            
            NSLog("Error querying MusicBrainz for cover art with artist=\(artist), releaseTitle=\(releaseTitle). Error: \(error)")
        }
        
        return nil
    }
    
    private func searchRecordings(forArtist artist: String, andRecordingTitle recordingTitle: String) -> CoverArt? {
        
        // Look for cover art in the cache first.
        if let coverArt = cache.getForRecording(artist: artist, title: recordingTitle) {
            return coverArt
        }
        
        do {
            
            if let coverArt = try restAPIClient.getCoverArt(forArtist: artist, andRecordingTitle: recordingTitle) {
                
                // Add this entry to the cache.
                cache.putForRecording(artist: artist, title: recordingTitle, coverArt: coverArt)
                return coverArt
            }
            
        } catch {
            NSLog("Error querying MusicBrainz for cover art with artist=\(artist), recordingTitle=\(recordingTitle). Error: \(error)")
        }
        
        return nil
    }
}
