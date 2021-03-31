import Cocoa

class MusicBrainzCoverArtReader: CoverArtReaderProtocol {
    
    private let restAPIClient: MusicBrainzRESTClient
    
    // Cache art for later use (other tracks from the same release / recording).
    let cache: MusicBrainzCache
    
    private let preferences: MusicBrainzPreferences
    
    private var searchedTracks: ConcurrentSet<Track> = ConcurrentSet()
    
    ///
    /// Only one thread should be able to perform a MusicBrainz REST API call at any given time.
    /// This is because MusicBrainz performs rate-limiting (1 request per second).
    ///
    private let apiCallsLock: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    init(state: MusicBrainzCacheState, preferences: MusicBrainzPreferences, cache: MusicBrainzCache) {

        self.restAPIClient = MusicBrainzRESTClient()
        self.cache = cache
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
        if let coverArtResult = cache.getForRelease(artist: artist, title: releaseTitle) {
            return coverArtResult.art
        }
        
        // Acquire the lock for the API call.
        apiCallsLock.wait()
        defer {apiCallsLock.signal()}
        
        // Look for cover art in the cache again (if we waited, another thread may have added cover art for the same release during the wait time).
        if let coverArtResult = cache.getForRelease(artist: artist, title: releaseTitle) {
            return coverArtResult.art
        }
        
        do {
            
            if let coverArt = try restAPIClient.getCoverArt(forArtist: artist, andReleaseTitle: releaseTitle) {
                
                // Add this entry to the cache.
                cache.putForRelease(artist: artist, title: releaseTitle, coverArt: coverArt)
                return coverArt
                
            } else {
                cache.putForRelease(artist: artist, title: releaseTitle, coverArt: nil)
            }
            
        } catch {
            NSLog("Error querying MusicBrainz for cover art with artist=\(artist), releaseTitle=\(releaseTitle). Error: \(error)")
        }
        
        return nil
    }
    
    private func searchRecordings(forArtist artist: String, andRecordingTitle recordingTitle: String) -> CoverArt? {
        
        // Look for cover art in the cache first.
        if let coverArtResult = cache.getForRecording(artist: artist, title: recordingTitle) {
            return coverArtResult.art
        }
        
        // Acquire the lock for the API call.
        apiCallsLock.wait()
        defer {apiCallsLock.signal()}
        
        // Look for cover art in the cache again (if we waited, another thread may have added cover art for the same recording during the wait time).
        if let coverArtResult = cache.getForRecording(artist: artist, title: recordingTitle) {
            return coverArtResult.art
        }
        
        do {
            
            if let coverArt = try restAPIClient.getCoverArt(forArtist: artist, andRecordingTitle: recordingTitle) {
                
                // Add this entry to the cache.
                cache.putForRecording(artist: artist, title: recordingTitle, coverArt: coverArt)
                return coverArt
                
            } else {
                cache.putForRecording(artist: artist, title: recordingTitle, coverArt: nil)
            }
            
        } catch {
            NSLog("Error querying MusicBrainz for cover art with artist=\(artist), recordingTitle=\(recordingTitle). Error: \(error)")
        }
        
        return nil
    }
}
