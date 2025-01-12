//
//  MusicBrainzRESTClient.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A utility / service that sends web requests to MusicBrainz to retrieve cover art or other music-related information.
///
class MusicBrainzRESTClient {
    
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
    private let httpClient: HTTPClient = .shared
    
    ///
    /// The headers that will be present in every request sent to MusicBrainz.
    ///
    /// User-Agent:
    /// MusicBrainz requires a meaningful "User-Agent" header that identifies the application making the request.
    /// If this header is not present, MusicBrainz may deny the request or blacklist the source IP address.
    /// Example: "User-Agent": "MusicBrainz-Swift/1.0.0 ( aural.student@gmail.com)"
    ///
    /// Accept-Encoding:
    /// We should set this header to "gzip" to inform the server to compress the response payload using gzip.
    /// Compression will reduce the transit time of the payload.
    ///
    private let standardHeaders: [String: String] = ["User-Agent": "Aural Player/\(appVersion) ( \(appContact) )",
                                                             "Accept-Encoding": "gzip"]
    
    ///
    /// An ordered list of all possible thumbnail sizes for cover art images. The list is ordered in terms of preference,
    /// i.e. we prefer 500x500px images, and if that is not found, we can fall back on other sizes. "front" is the default
    /// image in its original size.
    ///
    private let thumbnailSizes: [String] = ["front-500", "front-250", "front", "front-1200"]
    
    private var httpTimeout: Int {
        preferences.metadataPreferences.httpTimeout.value
    }
    
    ///
    /// Tries to retrieve cover art, given the name of an artist and an associated release (album / track title).
    ///
    /// - Returns an NSImage containing cover art, if found. nil if no cover art was found.
    ///
    func getCoverArt(forArtist artist: String, andReleaseTitle releaseTitle: String) throws -> CoverArt? {
        
        do {
            
            // Step 1 - Find all releases matching the given artist and release title.
            //
            // Step 2 - From those candidates, query the cover art archive of each release
            // to find a release that has suitable cover art to retrieve.
            //
            // Step 3 - Query the chosen release's front image to get the actual image data.
            
            if let matchingReleases = try queryReleases(artist: artist, releaseTitle: releaseTitle),
               let releaseWithCoverArt = checkReleasesForCoverArt(matchingReleases) {
                
                return try getFrontCoverImage(release: releaseWithCoverArt)
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
        
        let encodedArtistString = artist.encodedAsURLComponent()
        let encodedReleaseTitleString = releaseTitle.encodedAsURLComponent()
        
        if let url = URL(string: "\(musicBrainzAPIBaseURL)/release?query=release:%22\(encodedReleaseTitleString)%22%20AND%20artistname:%22\(encodedArtistString)%22%20AND%20status:official%20AND%20primarytype:album&fmt=json"),
           let mbDict = try httpClient.performGETForJSON(toURL: url, withHeaders: standardHeaders, timeout: httpTimeout),
           let releasesArr = mbDict["releases", [NSDictionary].self] {
            
            // Map the NSDictionary array (the result of JSON deserialization)
            // to an array of MBRelease objects that we can work with.
            return releasesArr.compactMap {MusicBrainzRelease($0)}
                .sorted(by: MusicBrainzReleaseSort(title: releaseTitle).compareAscending)
        }
        
        // No matching release found.
        return nil
    }
    
    ///
    /// Tries to retrieve cover art, given the name of an artist and an associated recording (track) title.
    ///
    func getCoverArt(forArtist artist: String, andRecordingTitle recordingTitle: String, from album: String?) throws -> CoverArt? {
        
        do {

            if let matchingReleases = try queryRecordings(artist: artist, recordingTitle: recordingTitle, from: album),
               let releaseWithCoverArt = checkReleasesForCoverArt(matchingReleases) {
                
                return try getFrontCoverImage(release: releaseWithCoverArt)
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
    /// Finds all releases matching the given artist and recording title.
    ///
    /// - Returns an optional collection of releases matching the given artist and recording title. nil if no matching releases were found.
    ///
    /// - throws any error that was thrown while making the request.
    ///
    private func queryRecordings(artist: String, recordingTitle: String, from album: String?) throws -> [MusicBrainzRelease]? {
        
        // Make sure to replace spaces and quotes in the query parameters with the appropriate escape characters (i.e. URL encoding).
        
        let encodedArtistString = artist.encodedAsURLComponent()
        let encodedRecordingTitleString = recordingTitle.encodedAsURLComponent()
        
        if let url = URL(string: "\(musicBrainzAPIBaseURL)/recording?query=recording:%22\(encodedRecordingTitleString)%22%20AND%20artistname:%22\(encodedArtistString)%22%20AND%20status:official%20AND%20(primarytype:album%20OR%20primarytype:single)&inc=releases&fmt=json"),
           let mbDict = try httpClient.performGETForJSON(toURL: url, withHeaders: standardHeaders, timeout: httpTimeout),
           let recordingsArr = mbDict["recordings", [NSDictionary].self] {
            
            // Step 1 - Map the NSDictionary array (the result of JSON deserialization)
            // to an array of MBRecording objects that we can work with.
            //
            // Step 2 - For each recording that was found, collect all its associated releases,
            // and consolidate them into a single collection of releases.
            //
            // Step 3 - Only consider releases that have official status.
            //
            // Step 4 - Sort the candidate releases so that the most appropriate release
            // is the most likely one to be used for the cover art query.
            
            let recordings = recordingsArr.compactMap {MusicBrainzRecording($0)}
            let allReleases = recordings.flatMap {$0.releases}
            let candidateReleases = allReleases.filter {$0.status == .official && ($0.type != .single || $0.title.lowercased().trim() == recordingTitle)}
            
            return candidateReleases.sorted(by: MusicBrainzReleaseSort(artist: artist, title: recordingTitle, album: album).compareAscending)
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
                   let mbDict = try httpClient.performGETForJSON(toURL: url, withHeaders: standardHeaders, timeout: httpTimeout),
                   let archiveDict = mbDict["cover-art-archive", NSDictionary.self],
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
        
        for size in thumbnailSizes {
            
            if let url = URL(string: "\(coverArtAPIBaseURL)/release/\(release.id)/\(size)") {
                
                do {
                    
                    let data: Data = try httpClient.performGET(toURL: url, withHeaders: standardHeaders, timeout: httpTimeout)
                    
                    // Construct an NSImage from the raw data.
                    return CoverArt(source: .musicBrainz, originalImageData: data)
                    
                } catch {continue}
            }
        }
        
        // No image data found.
        return nil
    }
}

///
/// Contact info for the developer of this application (used in a request header for all requests sent to MusicBrainz).
/// So that MusicBrainz can contact the app developer if this app misbehaves (sends too many requests) with MusicBrainz.
///
fileprivate let appContact = "aural.student@gmail.com"
