//
//  MusicBrainzCoverArtReader.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// An implementation of **CoverArtReaderProtocol** that reads cover art
/// from the **MusicBrainz** online database.
///
/// - SeeAlso: `CoverArtReaderProtocol`
///
class MusicBrainzCoverArtReader: CoverArtReaderProtocol {
    
    private let restAPIClient: MusicBrainzRESTClient
    
    // Cache art for later use (other tracks from the same release / recording).
    let cache: MusicBrainzCache
    
    private var searchedTracks: ConcurrentSet<Track> = ConcurrentSet()
    
    ///
    /// Only one thread should be able to perform a MusicBrainz REST API call at any given time.
    /// This is because MusicBrainz performs rate-limiting (1 request per second).
    ///
    private let apiCallsLock: ExclusiveAccessSemaphore = ExclusiveAccessSemaphore()
    
    init(cache: MusicBrainzCache) {

        self.restAPIClient = MusicBrainzRESTClient()
        self.cache = cache
    }
    
    private var mbPreferences: MusicBrainzPreferences {
        preferences.metadataPreferences.musicBrainz
    }
    
    func getCoverArt(forTrack track: Track) -> CoverArt? {
        
        if (!mbPreferences.enableCoverArtSearch.value) || searchedTracks.contains(track) {return nil}
        
        searchedTracks.insert(track)
        
        guard let artist = track.artist else {return nil}
        let lcArtist = artist.lowerCasedAndTrimmed()
        
        var lcTrackAlbum = track.album?.lowerCasedAndTrimmed()
        if lcTrackAlbum == "album" {lcTrackAlbum = nil} // The word album means that album is unknown and should not be used in the search.
        
        func updatePlayQueueTracks(withCoverArt coverArt: CoverArt) {
            
            DispatchQueue.global(qos: .background).async {
                
                var updatedTracks = [Int]()
                
                for (index, pqTrack) in playQueueDelegate.tracks.enumerated() {
                    
                    if let pqLCArtist = pqTrack.artist?.lowerCasedAndTrimmed(),
                       let pqLCAlbum = pqTrack.album?.lowerCasedAndTrimmed(),
                       lcArtist == pqLCArtist,
                       lcTrackAlbum == pqLCAlbum {
                        
                        if pqTrack.metadata.art == nil {
                            pqTrack.metadata.art = coverArt
                        }
                        
                        updatedTracks.append(index)
                    }
                }
                
                Messenger.publish(.PlayQueue.bulkCoverArtUpdate, payload: updatedTracks)
            }
        }
        
        if let album = lcTrackAlbum,
           let coverArt = searchReleases(forArtist: lcArtist, andReleaseTitle: album) {
            
//            CoverArtCache.addEntry(track.file, coverArt)
            
            updatePlayQueueTracks(withCoverArt: coverArt)
            return coverArt
        }
        
        if let title = track.title,
           let coverArt = searchRecordings(forArtist: lcArtist, andRecordingTitle: title.lowerCasedAndTrimmed(), from: lcTrackAlbum) {
            
//            CoverArtCache.addEntry(track.file, coverArt)
//            updatePlayQueueTracks(withCoverArt: coverArt)
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
        return apiCallsLock.produceValueAfterWait {() -> CoverArt? in
            
            // Look for cover art in the cache again (if we waited, another thread may have
            // added cover art for the same release during the wait time).
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
                
                if let httpError = error as? HTTPError {
                    
                    NSLog("Error querying MusicBrainz for cover art with artist=\(artist), releaseTitle=\(releaseTitle). Error: HTTP error code=\(httpError.code), description='\(httpError.description)'")
                    
                } else {
                    NSLog("Error querying MusicBrainz for cover art with artist=\(artist), releaseTitle=\(releaseTitle). Error: \(error.localizedDescription)")
                }
            }
            
            return nil
        }
    }
    
    private func searchRecordings(forArtist artist: String, andRecordingTitle recordingTitle: String, from album: String?) -> CoverArt? {
        
        // Look for cover art in the cache first.
        if let coverArtResult = cache.getForRecording(artist: artist, title: recordingTitle) {
            return coverArtResult.art
        }
        
        // Acquire the lock for the API call.
        return apiCallsLock.produceValueAfterWait {() -> CoverArt? in
            
            // Look for cover art in the cache again (if we waited, another thread may have
            // added cover art for the same recording during the wait time).
            if let coverArtResult = cache.getForRecording(artist: artist, title: recordingTitle) {
                return coverArtResult.art
            }
            
            do {
                
                if let coverArt = try restAPIClient.getCoverArt(forArtist: artist, andRecordingTitle: recordingTitle, from: album) {
                    
                    // Add this entry to the cache.
                    cache.putForRecording(artist: artist, title: recordingTitle, coverArt: coverArt)
                    return coverArt
                    
                } else {
                    cache.putForRecording(artist: artist, title: recordingTitle, coverArt: nil)
                }
                
            } catch {
                
                if let httpError = error as? HTTPError {
                    
                    NSLog("Error querying MusicBrainz for cover art with artist=\(artist), recordingTitle=\(recordingTitle). Error: HTTP error code=\(httpError.code), description='\(httpError.description)'")
                    
                } else {
                    NSLog("Error querying MusicBrainz for cover art with artist=\(artist), recordingTitle=\(recordingTitle). Error: \(error.localizedDescription)")
                }
            }
            
            return nil
        }
    }
}
