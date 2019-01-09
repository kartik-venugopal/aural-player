import Cocoa

class FFMpegReader: MetadataReader {
    
    private let parsers: [FFMpegMetadataParser] = [ObjectGraph.commonFFMpegParser, ObjectGraph.wmParser]
    
    private let genericMetadata_ignoreKeys: [String] = ["title", "artist", "duration", "disc", "track", "album", "genre"]
    
    private lazy var muxer: MuxerProtocol = ObjectGraph.muxer
    
    private func ensureTrackAssetLoaded(_ track: Track) {
        
        if track.libAVInfo == nil {
            track.libAVInfo = FFMpegWrapper.getMetadata(track)
            parsers.forEach({$0.mapTrack(track.libAVInfo!.metadata)})
        }
    }
    
    private func nilIfEmpty(_ string: String?) -> String? {
        return StringUtils.isStringEmpty(string) ? nil : string
    }

    func getPrimaryMetadata(_ track: Track) -> PrimaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let title = nilIfEmpty(getTitle(track))
        let artist = nilIfEmpty(getArtist(track))
        let album = nilIfEmpty(getAlbum(track))
        let genre = nilIfEmpty(getGenre(track))
        
        let duration = getDuration(track)
        
        return PrimaryMetadata(title, artist, album, genre, duration)
    }
    
    private func getTitle(_ track: Track) -> String? {
        
        if let metadata = track.libAVInfo?.metadata {
            
            for parser in parsers {
                
                if let title = parser.getTitle(metadata) {
                    return title
                }
            }
        }
        
        return nil
    }
    
    private func getArtist(_ track: Track) -> String? {
        
        if let metadata = track.libAVInfo?.metadata {
            
            for parser in parsers {
                
                if let artist = parser.getArtist(metadata) {
                    return artist
                }
            }
        }
        
        return nil
    }
    
    private func getAlbum(_ track: Track) -> String? {
        
        if let metadata = track.libAVInfo?.metadata {
            
            for parser in parsers {
                
                if let album = parser.getAlbum(metadata) {
                    return album
                }
            }
        }
        
        return nil
    }
    
    private func getGenre(_ track: Track) -> String? {
        
        if let metadata = track.libAVInfo?.metadata {
            
            for parser in parsers {
                
                if let genre = parser.getGenre(metadata) {
                    return genre
                }
            }
        }
        
        return nil
    }
    
    func getDuration(_ track: Track) -> Double {
        
        if muxer.trackNeedsMuxing(track), let trackDuration = muxer.muxForDuration(track) {
            return trackDuration
        }
        
        return track.libAVInfo!.duration
    }
    
    func getSecondaryMetadata(_ track: Track) -> SecondaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let discNumber = getDiscNumber(track)
        let trackNumber = getTrackNumber(track)
        let lyrics = getLyrics(track)
        
        return SecondaryMetadata(discNumber?.number, discNumber?.total, trackNumber?.number, trackNumber?.total, lyrics)
    }
    
    private func getDiscNumber(_ track: Track) -> (number: Int?, total: Int?)? {
        
        if let map = track.libAVInfo?.metadata {
            
            for parser in parsers {
                
                if let discNum = parser.getDiscNumber(map) {
                    return discNum
                }
            }
        }
        
        return nil
    }
    
    private func getTrackNumber(_ track: Track) -> (number: Int?, total: Int?)? {
        
        if let map = track.libAVInfo?.metadata {
            
            for parser in parsers {
                
                if let trackNum = parser.getTrackNumber(map) {
                    return trackNum
                }
            }
        }
        
        return nil
    }
    
    private func getLyrics(_ track: Track) -> String? {
        
        if let map = track.libAVInfo?.metadata {
            
            for parser in parsers {
                
                if let lyrics = parser.getLyrics(map) {
                    return lyrics
                }
            }
        }
        
        return nil
    }
    
    func getArt(_ track: Track) -> NSImage? {
        
        ensureTrackAssetLoaded(track)
        
        if let avInfo = track.libAVInfo {
        
            if avInfo.hasArt {
                return FFMpegWrapper.getArt(track)
            }
        }
        
        return nil
    }
    
    func getArt(_ file: URL) -> NSImage? {
        return FFMpegWrapper.getArt(file)
    }
    
    func getAllMetadata(_ track: Track) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        if let map = track.libAVInfo?.metadata {
            
            for parser in parsers {
                
                let parserMetadata = parser.getGenericMetadata(map)
                parserMetadata.forEach({(k,v) in metadata[k] = v})
            }
        }
        
        return metadata
    }
    
    func getDurationForFile(_ file: URL) -> Double {
        
        // TODO (not needed yet)
        return 0
    }
}
