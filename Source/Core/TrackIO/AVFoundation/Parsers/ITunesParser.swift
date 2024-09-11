//
//  ITunesParser.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import AVFoundation

///
/// Parses metadata in the iTunes format / key space from natively supported tracks (supported by **AVFoundation**).
///
class ITunesParser: AVFMetadataParser {
    
    let keySpace: AVMetadataKeySpace = .iTunes
        
    private let essentialFieldKeys: Set<String> = [ITunesSpec.key_title, ITunesSpec.key_artist, ITunesSpec.key_originalArtist, ITunesSpec.key_originalArtist2, ITunesSpec.key_performer, ITunesSpec.key_album, ITunesSpec.key_originalAlbum, ITunesSpec.key_composer, ITunesSpec.key_conductor, ITunesSpec.key_conductor2, ITunesSpec.key_genre, ITunesSpec.key_predefGenre, ITunesSpec.key_genreID, ITunesSpec.key_discNumber, ITunesSpec.key_discNumber2, ITunesSpec.key_trackNumber, ITunesSpec.key_releaseDate, ITunesSpec.key_releaseYear, ITunesSpec.key_lyrics, ITunesSpec.key_art]
        
    private let keys_artist: Set<String> = [ITunesSpec.key_artist, ITunesSpec.key_originalArtist, ITunesSpec.key_originalArtist2, ITunesSpec.key_albumArtist, ITunesSpec.key_performer]
    private let keys_album: Set<String> = [ITunesSpec.key_album, ITunesSpec.key_originalAlbum]
    private let keys_conductor: Set<String> = [ITunesSpec.key_conductor, ITunesSpec.key_conductor2]
    private let keys_lyricist: Set<String> = [ITunesSpec.key_lyricist, ITunesSpec.key_originalLyricist]
    private let keys_genre: Set<String> = [ITunesSpec.key_genre, ITunesSpec.key_predefGenre]
    
    private let keys_discNum: Set<String> = [ITunesSpec.key_discNumber, ITunesSpec.key_discNumber2]
    
    private let keys_year: Set<String> = [ITunesSpec.key_releaseDate, ITunesSpec.key_releaseYear]
    
    // BUG TODO: Find out why ITunesNormalization tag is not being ignored in MP3 files
    // Is some other parser including it ??? ID3Parser ???
    private let ignoredKeys: Set<String> = [ITunesSpec.key_normalization, ITunesSpec.key_soundCheck]
    
    func getDuration(_ metadataMap: AVFMappedMetadata) -> Double? {
        
        if let item = metadataMap.iTunes[ITunesSpec.key_duration], let durationStr = item.stringValue {
            return ParserUtils.parseDuration(durationStr)
        }
        
        return nil
    }
    
    func getTitle(_ metadataMap: AVFMappedMetadata) -> String? {
        metadataMap.iTunes[ITunesSpec.key_title]?.stringValue
    }
    
    func getArtist(_ metadataMap: AVFMappedMetadata) -> String? {
        (keys_artist.firstNonNilMappedValue {metadataMap.iTunes[$0]})?.stringValue
    }
    
    func getAlbumArtist(_ metadataMap: AVFMappedMetadata) -> String? {
        metadataMap.iTunes[ITunesSpec.key_albumArtist]?.stringValue
    }
    
    func getAlbum(_ metadataMap: AVFMappedMetadata) -> String? {
        (keys_album.firstNonNilMappedValue {metadataMap.iTunes[$0]})?.stringValue
    }
    
    func getComposer(_ metadataMap: AVFMappedMetadata) -> String? {
        metadataMap.iTunes[ITunesSpec.key_composer]?.stringValue
    }
    
    func getConductor(_ metadataMap: AVFMappedMetadata) -> String? {
        (keys_conductor.firstNonNilMappedValue {metadataMap.iTunes[$0]})?.stringValue
    }
    
    func getPerformer(_ metadataMap: AVFMappedMetadata) -> String? {
        metadataMap.iTunes[ITunesSpec.key_performer]?.stringValue
    }
    
    func getLyricist(_ metadataMap: AVFMappedMetadata) -> String? {
        (keys_lyricist.firstNonNilMappedValue {metadataMap.iTunes[$0]})?.stringValue
    }
    
    func getGenre(_ metadataMap: AVFMappedMetadata) -> String? {
        
        if let genreItem = keys_genre.firstNonNilMappedValue({metadataMap.iTunes[$0]}) {
            return ParserUtils.getID3Genre(genreItem, -1)
        }
        
        if let genreItem = metadataMap.iTunes[ITunesSpec.key_genreID] {
            return getITunesGenre(genreItem)
        }
        
        return nil
    }
    
    private func getITunesGenre(_ genreItem: AVMetadataItem) -> String? {
        
        if let num = genreItem.numberValue {
            return GenreMap.forITunesCode(num.intValue)
        }
        
        if let str = genreItem.stringValue {
            return parseITunesGenreString(str)
            
        } else if let data = genreItem.dataValue, let code = Int(data.hexEncodedString(), radix: 16) { // Parse as hex string
            return GenreMap.forITunesCode(code)
        }
        
        return nil
    }
    
    // A genre string consisting of a number (ITunes genre code) in parenthesis,
    // followed by the genre name. eg. "(9)Opera"
    private let hybridGenreStringRegex = "\\([0-9]+\\)(.+)"
    
    private func parseITunesGenreString(_ string: String) -> String {

        // Look up genreId in ID3 table
        if let genreCode = ParserUtils.parseNumericString(string) {
            return GenreMap.forITunesCode(genreCode) ?? string
        }
        
        // Sometimes, genre strings look like "(9)Metal".
        if let firstMatch = string.match(regex: hybridGenreStringRegex).first,
           firstMatch.count >= 2 {
            
            // The second capture group within the first match is our genre string.
            return firstMatch[1].trim()
        }
        
        return string
    }
    
    func getTrackNumber(_ metadataMap: AVFMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = metadataMap.iTunes[ITunesSpec.key_trackNumber] {
            return ParserUtils.parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    func getDiscNumber(_ metadataMap: AVFMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = keys_discNum.firstNonNilMappedValue({metadataMap.iTunes[$0]}) {
            return ParserUtils.parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    func getArt(_ metadataMap: AVFMappedMetadata) -> CoverArt? {
        
        if let imgData = metadataMap.iTunes[ITunesSpec.key_art]?.dataValue {
            return CoverArt(originalImageData: imgData)
        }
        
        return nil
    }
    
    func getLyrics(_ metadataMap: AVFMappedMetadata) -> String? {
        metadataMap.iTunes[ITunesSpec.key_lyrics]?.stringValue
    }
    
    func getYear(_ metadataMap: AVFMappedMetadata) -> Int? {
        
        if let item = keys_year.firstNonNilMappedValue({metadataMap.iTunes[$0]}) {
            return ParserUtils.parseYear(item)
        }
        
        return nil
    }
    
    func getBPM(_ metadataMap: AVFMappedMetadata) -> Int? {
        
        if let item = metadataMap.iTunes[ITunesSpec.key_bpm] {
            return ParserUtils.parseBPM(item)
        }
        
        return nil
    }
    
    func getReplayGain(from metadataMap: AVFMappedMetadata) -> ReplayGain? {
        
        for (key, item) in metadataMap.iTunes {
            
            guard let value = item.valueAsString else {continue}
            
            let trimmedKey = key.lowercased().removingOccurrences(of: AVMetadataItem.keyPrefix_iTunesLongForm_lowercased)
            
            if trimmedKey == ITunesSpec.key_normalization {
                
                let hex = value.trim()
                let nums = hex.split(separator: " ")
                let ints: [Int] = nums.compactMap {Int($0, radix: 16)}

                let gain: Float = log10(Float(ints[0..<2].max() ?? 1000) / 1000.0) * -10
                let peak = Float(ints[6..<8].max() ?? 32768) / 32768.0
                
                return ReplayGain(trackGain: gain, trackPeak: peak)
                
            } else if trimmedKey.contains("replaygain") {
                // TODO: 
            }
        }
        
        return nil
        
        /*
         
         https://gist.github.com/daveisadork/4717535
         
         # The following is from http://id3.org/iTunes%20Normalization%20settings

         # The iTunNORM tag consists of 5 value pairs. These 10 values are encoded as
         # ASCII Hex values of 8 characters each inside the tag (plus a space as
         # prefix).
          
         # The tag can be found in MP3, AIFF, AAC and Apple Lossless files.
          
         # The relevant information is what is encoded in these 5 value pairs. The
         # first value of each pair is for the left audio channel, the second value of
         # each pair is for the right channel.
          
         # 0/1: Volume adjustment in milliWatt/dBm
         # 2/3: Same as 0/1, but not based on 1/1000 Watt but 1/2500 Watt
         # 4/5: Not sure, but always the same values for songs that only differs in
         #      volume - so maybe some statistical values.
         # 6/7: The peak value (maximum sample) as absolute (positive) value;
         #      therefore up to 32768 (for songs using 16-Bit samples).
         # 8/9: Not sure, same as for 4/5: same values for songs that only differs in
         #      volume.
         # iTunes is choosing the maximum value of the both first pairs (of the first
         # 4 values) to adjust the whole song.
         
         def sc2rg(soundcheck):
         
             """Convert a SoundCheck tag to ReplayGain values"""
         
             # SoundCheck tags consist of 10 numbers, each represented by 8 characters
             # of ASCII hex preceded by a space.
         
             try:
                 soundcheck = soundcheck.replace(' ', '').decode('hex')
                 soundcheck = struct.unpack('!iiiiiiiiii', soundcheck)
             except:
                 # SoundCheck isn't in the format we expect, so return default values
                 return 0.0, 0.0
         
             # SoundCheck stores absolute calculated/measured RMS value in an unknown
             # unit. We need to find the ratio of this measurement compared to a
             # reference value of 1000 to get our gain in dB. We play it safe by using
             # the larger of the two values (i.e., the most attenuation).
         
            gain = math.log10((max(*soundcheck[:2]) or 1000) / 1000.0) * -10
         
             # SoundCheck stores peak values as the actual value of the sample, and
             # again separately for the left and right channels. We need to convert
             # this to a percentage of full scale, which is 32768 for a 16 bit sample.
             # Once again, we play it safe by using the larger of the two values.
         
             peak = max(soundcheck[6:8]) / 32768.0
             return round(gain, 2), round(peak, 6)
         */
        
//        return ReplayGain(trackGain: trackGain, trackPeak: trackPeak, albumGain: albumGain, albumPeak: albumPeak)
    }

    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {
        return items.first(where: {$0.keySpace == .iTunes && $0.keyAsString == ITunesSpec.key_title})?.stringValue
    }
    
    func getAuxiliaryMetadata(_ metadataMap: AVFMappedMetadata) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for item in metadataMap.iTunes.values {
            
            guard let key = item.keyAsString, !essentialFieldKeys.contains(key) else {continue}
            
            var value: String = ""
            
            if key == ITunesSpec.key_language, let langName = LanguageMap.forCode(value.trim()) {
                
                value = langName
                
            } else if key.equalsOneOf(ITunesSpec.key_compilation, ITunesSpec.key_isPodcast), let numVal = item.numberValue {
                
                // Number to boolean
                value = numVal == 0 ? "No" : "Yes"
                
            } else if ITunesSpec.keys_mediaType.contains(key) {
                
                if let mediaTypeCode = item.numberValue?.intValue, let mediaType = ITunesSpec.mediaTypes[mediaTypeCode] {
                    value = mediaType
                } else {
                    continue
                }
                
            } else if key == ITunesSpec.key_contentRating {
                
                if let ratingCode = item.numberValue?.intValue, let rating = ITunesSpec.contentRating[ratingCode] {
                    value = rating
                } else {
                    continue
                }
                
            } else if key == ITunesSpec.key_bpm {
                
                value = item.valueAsNumericalString
                
            } else {
                
                if let strValue = item.valueAsString {
                    value = strValue
                } else {
                    continue
                }
            }
            
            let rKey = ITunesSpec.readableKey(key.withEncodingAndNullsRemoved())
            
            if !ignoredKeys.contains(rKey.lowercased()) {
                metadata[key] = MetadataEntry(format: .iTunes, key: rKey, value: value.withEncodingAndNullsRemoved())
            }
        }
        
        return metadata
    }
}
