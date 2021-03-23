import Cocoa

///
/// A utility / service that sends web requests to MusicBrainz to retrieve cover art or other music-related information.
///
class MusicBrainzRESTClient {
    
    // TODO: Add caching !!!
    // For a given artist / release title combo, cache art for later use (other tracks from the same album).
    private let cache: MusicBrainzCache
    
    ///
    /// The base URL for accessing the MusicBrainz REST API.
    ///
    private let musicBrainzAPIBaseURL = "https://musicbrainz.org/ws/2"

    ///
    /// The base URL for accessing the MusicBrainz CoverArt archive's REST API.
    ///
    private let coverArtAPIBaseURL = "https://coverartarchive.org"
    
    ///
    /// A helper client object that performs HTTP requests and deals with the specifics of the HTTP protocol.
    /// All MusicBrainz requests will be delegated to this object.
    ///
    private let httpClient: HTTPClient = HTTPClient()
    
    ///
    /// The headers that will be present in every request sent to MusicBrainz.
    /// MusicBrainz requires a meaningful "User-Agent" header that identifies the application making the request.
    /// If this header is not present, MusicBrainz may deny the request or blacklist the source IP address.
    ///
    /// Example: "User-Agent": "MusicBrainz-Swift/1.0.0 ( aural.student@gmail.com)"
    ///
    private let standardHeaders: [String: String] = ["User-Agent": "Aural Player/\(appVersion) ( \(appContact) )"]
    
    ///
    /// Limits the number of simultaneous requests made to MusicBrainz, in order to prevent blacklisting.
    ///
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    init(_ cache: MusicBrainzCache) {
        self.cache = cache
    }
    
    ///
    /// Tries to retrieve cover art, given the name of an artist and an associated release (album / track title).
    ///
    /// - Returns an NSImage containing cover art, if found. nil if no cover art was found.
    ///
    func getCoverArt(forArtist artist: String, andReleaseTitle releaseTitle: String) throws -> CoverArt? {
        
        semaphore.wait()
        defer {semaphore.signal()}
        
        let lcArtist = artist.lowercased().trim()
        let lcReleaseTitle = releaseTitle.lowercased().trim()
        
        // Look for cover art in the cache first.
        if let coverArt = cache.getFor(artist: lcArtist, releaseTitle: lcReleaseTitle) {
            print("Cache HIT for \(artist) - \(releaseTitle) !!!")
            return coverArt
        }
        
        do {
            
            // Step 1 - Find all releases matching the given artist and release title.
            //
            // Step 2 - From those candidates, query the cover art archive of each release
            // to find a release that has suitable cover art to retrieve.
            //
            // Step 3 - Query the chosen release's front image to get the actual image data.
            
            if let matchingReleases = try queryReleases(artist: artist, releaseTitle: releaseTitle),
               let releaseWithCoverArt = checkReleasesForCoverArt(matchingReleases) {
                
                if let coverArt = try getFrontCoverImage(release: releaseWithCoverArt) {
                    
                    // Add this entry to the cache.
                    cache.putFor(artist: lcArtist, releaseTitle: lcReleaseTitle, coverArt: coverArt)
                    return coverArt
                }
            }
            
        } catch let httpError as HTTPError {
            
            // This is a special case. If we got a 404 not found error, we simply return nil. It's not an error.
            if httpError.code != HTTPError.error_notFound {
                throw httpError
            }
        }
        
        // No cover art found.
        return nil
    }
    
    ///
    /// Tries to retrieve cover art, given the name of an artist and an associated recording (track) title.
    ///
    func getCoverArt(forArtist artist: String, andRecordingTitle recordingTitle: String) throws -> CoverArt? {
        
        semaphore.wait()
        defer {semaphore.signal()}
        
        let lcArtist = artist.lowercased().trim()
        let lcRecordingTitle = recordingTitle.lowercased().trim()
        
        // Look for cover art in the cache first.
        if let coverArt = cache.getFor(artist: lcArtist, releaseTitle: lcRecordingTitle) {
            return coverArt
        }
        
        do {

            if let matchingReleases = try queryRecordings(artist: artist, recordingTitle: recordingTitle),
               let releaseWithCoverArt = checkReleasesForCoverArt(matchingReleases) {

                if let coverArt = try getFrontCoverImage(release: releaseWithCoverArt) {
                    
                    // Add this entry to the cache.
                    cache.putFor(artist: lcArtist, releaseTitle: lcRecordingTitle, coverArt: coverArt)
                    return coverArt
                }
            }

        } catch let httpError as HTTPError {
            
            // This is a special case. If we got a 404 not found error, we simply return nil. It's not an error.
            if httpError.code != HTTPError.error_notFound {
                throw httpError
            }
        }
        
        // No cover art found.
        return nil
    }
    
    ///
    /// Finds all releases matching the given artist and release title.
    ///
    /// - Returns an optional collection of releases matching the given artist and release title. nil if no matching releases were found.
    ///
    /// - throws any error that was thrown while making the request.
    ///
    private func queryReleases(artist: String, releaseTitle: String) throws -> [MusicBrainzRelease]? {
        
        // Make sure to replace spaces and quotes in the query parameters with the appropriate escape characters (i.e. URL encoding).
        
        let escapedArtistString = artist.contains(" ") ? "%22\(artist.replacingOccurrences(of: " ", with: "%20"))%22" : artist
        let escapedReleaseTitleString = releaseTitle.contains(" ") ? "%22\(releaseTitle.replacingOccurrences(of: " ", with: "%20"))%22" : releaseTitle
        
        if let url = URL(string: "\(musicBrainzAPIBaseURL)/release?query=release:\(escapedReleaseTitleString)%20AND%20artistname:\(escapedArtistString)&fmt=json"),
           let mbDict = try httpClient.performGETForJSON(toURL: url, withHeaders: standardHeaders),
           let releasesArr = mbDict["releases"] as? [NSDictionary] {
            
            // Map the NSDictionary array (the result of JSON deserialization)
            // to an array of MusicBrainzRelease objects that we can work with.
            return releasesArr.compactMap {MusicBrainzRelease($0)}
        }
        
        // No matching release found.
        return nil
    }
    
    ///
    /// Finds all releases matching the given artist and recording title.
    ///
    /// - Returns an optional collection of releases matching the given artist and recording title. nil if no matching releases were found.
    ///
    /// - throws any error that was thrown while making the request.
    ///
    private func queryRecordings(artist: String, recordingTitle: String) throws -> [MusicBrainzRelease]? {
        
        // Make sure to replace spaces and quotes in the query parameters with the appropriate escape characters (i.e. URL encoding).
        
        let escapedArtistString = artist.contains(" ") ? "%22\(artist.replacingOccurrences(of: " ", with: "%20"))%22" : artist
        let escapedRecordingTitleString = recordingTitle.contains(" ") ? "%22\(recordingTitle.replacingOccurrences(of: " ", with: "%20"))%22" : recordingTitle
        
        if let url = URL(string: "\(musicBrainzAPIBaseURL)/recording?query=recording:\(escapedRecordingTitleString)%20AND%20artistname:\(escapedArtistString)&fmt=json"),
           let mbDict = try httpClient.performGETForJSON(toURL: url, withHeaders: standardHeaders),
           let recordingsArr = mbDict["recordings"] as? [NSDictionary] {
            
            // Step 1 - Map the NSDictionary array (the result of JSON deserialization)
            // to an array of MBRecording objects that we can work with.
            //
            // Step 2 - For each recording that was found, collect all its associated releases,
            // and consolidate them into a single collection of releases.
            return recordingsArr.compactMap {MusicBrainzRecording($0)}.flatMap {$0.releases}
        }
        
        // No matching release found.
        return nil
    }
    
    ///
    /// Given a collection of candidate releases, checks each of them for cover art by querying their cover art archives.
    ///
    /// - Returns an optional release containing cover art. nil if no matching release was found.
    ///
    private func checkReleasesForCoverArt(_ releases: [MusicBrainzRelease]) -> MusicBrainzRelease? {
        
        // Iterate through all the releases.
        for release in releases {
            
            do {
                
                // Step 1 - Query the release to obtain its cover art archive.
                //
                // Step 2 - Check if the cover art archive contains any suitable cover art.
                //          We will only use "front cover" art.
                
                if let url = URL(string: "\(musicBrainzAPIBaseURL)/release/\(release.id)?fmt=json"),
                   let mbDict = try httpClient.performGETForJSON(toURL: url, withHeaders: standardHeaders),
                   let archiveDict = mbDict["cover-art-archive"] as? NSDictionary,
                   let archive = MusicBrainzCoverArtArchive(archiveDict),
                   archive.hasArt && archive.front {
                    
                    // Return the release because it matched all our cover art criteria.
                    return release
                }
                
            } catch {
                
                // When an error is encountered, skip this release, and continue querying other releases.
                NSLog("MBRESTClient.checkReleasesForCoverArt(): Exception occurred: \(error)")
                continue
            }
        }
        
        // No matching release found.
        return nil
    }
    
    ///
    /// Given a release, queries its "front cover" art image to obtain image data.
    ///
    /// - Returns an optional NSImage, if image data was found. nil if no image data was found.
    ///
    /// - throws any error that was thrown while making the request.
    ///
    private func getFrontCoverImage(release: MusicBrainzRelease) throws -> CoverArt? {
        
        if let url = URL(string: "\(coverArtAPIBaseURL)/release/\(release.id)/front") {

            let data = try httpClient.performGET(toURL: url, withHeaders: standardHeaders)

            // Construct an NSImage from the raw data.
            if let image = NSImage(data: data) {
                
                let metadata = ParserUtils.getImageMetadata(data as NSData)
                return CoverArt(image, metadata)
            }
        }
        
        // No image data found.
        return nil
    }
}

///
/// The version number of this application (used in a request header for all requests sent to MusicBrainz). Used to idenfity this app to MusicBrainz.
///
fileprivate let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.9.0"

///
/// Contact info for the developer of this application (used in a request header for all requests sent to MusicBrainz).
/// So that MusicBrainz can contact the app developer if this app misbehaves (sends too many requests) with MusicBrainz.
///
fileprivate let appContact = "aural.student@gmail.com"
