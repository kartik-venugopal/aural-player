//
//  MusicBrainzRelease.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Represents a "release" entity in the **MusicBrainz** domain model.
/// A release is either an album or a single or a compilation of tracks.
///
class MusicBrainzRelease {
    
    ///
    /// MusicBrainz identifier to uniquely identify this object.
    ///
    var id: String
    
    ///
    /// Title of this release.
    ///
    var title: String
    
    ///
    /// A collection of artists who have been credited for this release.
    ///
    var artistCredits: [MusicBrainzArtistCredit] = []
    
    var artistName: String {artistCredits.first?.artist.name ?? ""}
    
    ///
    /// When this release was released.
    ///
    var date: Date = Date()
    
    var countryType: MusicBrainzReleaseCountryType = .other
    
    var type: MusicBrainzReleaseType = .other
    
    var status: MusicBrainzReleaseStatus = .other
    
    ///
    /// Conditionally initializes this object, given a dictionary containing key-value pairs corresponding to members of this object.
    ///
    /// NOTE - Returns nil if the input dictionary does not contain all the fields required for this object.
    ///
    init?(_ dict: NSDictionary) {
        
        // Validate the dictionary (all fields must be present, and there must be at least one artist credit).
        guard let id = dict["id", String.self],
              let title = dict["title", String.self] else {return nil}
        
        self.id = id
        self.title = title
        
        // Map the NSDictionary array to MusicBrainzArtistCredit objects, eliminating nil values.
        if let artistCredits = dict["artist-credit", [NSDictionary].self] {
            self.artistCredits = artistCredits.compactMap {MusicBrainzArtistCredit($0)}
        }
        
        if let dateStr = dict["date", String.self], let date = parseDateString(dateStr) {
            self.date = date
        }
        
        if let releaseGroupDict = dict["release-group", NSDictionary.self],
           let primaryTypeStr = releaseGroupDict["primary-type", String.self],
           let type = MusicBrainzReleaseType(rawValue: primaryTypeStr.lowercased()) {
        
            self.type = type
        }
        
        if let country = dict["country", String.self] {
            self.countryType = MusicBrainzReleaseCountryType.typeForCountry(country)
        }
        
        if let status = dict["status", String.self], let releaseStatus = MusicBrainzReleaseStatus(rawValue: status.lowercased()) {
            self.status = releaseStatus
        }
    }
    
    private func parseDateString(_ dateStr: String) -> Date? {
        
        if dateStr.isEmptyAfterTrimming {
            return nil
        }
        
        let tokens = dateStr.split(separator: "-")
        
        if tokens.count == 1 {
            
            if let year = Int(tokens[0]) {
                
                var dateComponents = DateComponents()
                dateComponents.year = year
                dateComponents.month = 1
                dateComponents.day = 1
                
                return Calendar(identifier: .gregorian).date(from: dateComponents)
            }
            
        } else if tokens.count == 2 {
            
            if let year = Int(tokens[0]), let month = Int(tokens[1]) {
                
                var dateComponents = DateComponents()
                dateComponents.year = year
                dateComponents.month = month
                dateComponents.day = 1
                
                return Calendar(identifier: .gregorian).date(from: dateComponents)
            }
            
        } else if tokens.count == 3 {
            
            if let year = Int(tokens[0]), let month = Int(tokens[1]), let day = Int(tokens[2]) {
                
                var dateComponents = DateComponents()
                dateComponents.year = year
                dateComponents.month = month
                dateComponents.day = day
                
                return Calendar(identifier: .gregorian).date(from: dateComponents)
            }
        }
        
        return nil
    }
}

fileprivate let ranksForReleaseTypes: [MusicBrainzReleaseType: Int] = [.album: 1, .single: 2, .other: 3]

enum MusicBrainzReleaseType: String {
    
    case album, single, other
    
    var rank: Int {ranksForReleaseTypes[self]!}
}

fileprivate let englishSpeakingCountries: Set<String> = ["US", "CA", "GB", "AU", "NZ"]
fileprivate let ranksForCountryTypes: [MusicBrainzReleaseCountryType: Int] = [.englishSpeaking: 1, .other: 2]

enum MusicBrainzReleaseCountryType {
    
    case englishSpeaking, other
    
    static func typeForCountry(_ country: String) -> MusicBrainzReleaseCountryType {
        return englishSpeakingCountries.contains(country) ? .englishSpeaking : .other
    }
    
    var rank: Int {ranksForCountryTypes[self]!}
}

enum MusicBrainzReleaseStatus: String {
    
    case official, other
}

/// Sort comparator for MusicBrainzRelease objects.
class MusicBrainzReleaseSort {
 
    var queryArtist: String?
    var queryTitle: String?
    var album: String?
    
    init(artist: String? = nil, title: String? = nil, album: String? = nil) {
        
        self.queryArtist = artist
        self.queryTitle = title
        self.album = album
    }
    
    // Used to sort an array of releases such that the most preferred candidate is first in the array.
    func compareAscending(r1: MusicBrainzRelease, r2: MusicBrainzRelease) -> Bool {
        
        if self.queryArtist != nil {
            
            let artistMatchRank1 = artistMatchRank(for: r1)
            let artistMatchRank2 = artistMatchRank(for: r2)
            
            if artistMatchRank1 < artistMatchRank2 {
                return true
            } else if artistMatchRank1 > artistMatchRank2 {
                return false
            }
        }
        
        let r1Title = r1.title.lowerCasedAndTrimmed()
        let r2Title = r2.title.lowerCasedAndTrimmed()
        
        if let album = self.album, let title = self.queryTitle {
            
            // Album match has more weight (better rank) than title match.
            let r1Score = (album.alphaNumericMatch(to: r1Title) ? 0 : 3) + (title.alphaNumericMatch(to: r1Title) ? 1 : 2)
            let r2Score = (album.alphaNumericMatch(to: r2Title) ? 0 : 3) + (title.alphaNumericMatch(to: r2Title) ? 1 : 2)
            
            if r1Score != r2Score {
                return r1Score < r2Score
            }
            
        } else if let title = self.queryTitle {
            
            let titleMatchRank1 = title.similarityToString(other: r1Title)
            let titleMatchRank2 = title.similarityToString(other: r2Title)
            
            if titleMatchRank1 < titleMatchRank2 {
                return true
            } else if titleMatchRank1 > titleMatchRank2 {
                return false
            }
        }
        
        if r1.countryType.rank < r2.countryType.rank {
            
            return true
            
        } else if r1.countryType.rank > r2.countryType.rank {
            
            return false
            
        } else {
            
            if r1.date < r2.date {
                
                return true
                
            } else if r1.date > r2.date {
                
                return false
                
            } else {
                
                return r1.type.rank < r2.type.rank
            }
        }
    }
    
    private func artistMatchRank(for release: MusicBrainzRelease) -> Int {
        
        // Compare the artist of the release with the artist used in the query.
        
        let releaseArtist = release.artistName.lowercased().trim()
        let queryArtist = self.queryArtist ?? ""
        
        // If the artist matches (and artist is non-empty), rank is the highest.
        if releaseArtist == queryArtist && !releaseArtist.isEmpty {
            return 1
        }
        
        // If the artist matches (and artist is empty), rank is the 2nd highest.
        if releaseArtist == queryArtist && releaseArtist.isEmpty {
            return 2
        }
        
        // Artist does not match
        return 3
    }
}
