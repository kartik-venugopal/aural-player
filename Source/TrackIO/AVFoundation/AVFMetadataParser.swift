//
//  AVFMetadataParser.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

///
/// A contract for a parser that reads metadata from a natively supported track, i.e. a track
/// supported by **AVFoundation**.
///
protocol AVFMetadataParser {
    
    ///
    /// The metadata key space that this parser understands (e.g. ID3).
    ///
    var keySpace: AVMetadataKeySpace {get}
    
    ///
    /// Read track duration from the given metadata map. Returns nil if not present.
    ///
    func getDuration(_ metadataMap: AVFMappedMetadata) -> Double?
    
    ///
    /// Read track title from the given metadata map. Returns nil if not present.
    ///
    func getTitle(_ metadataMap: AVFMappedMetadata) -> String?
    
    ///
    /// Read track artist from the given metadata map. Returns nil if not present.
    ///
    func getArtist(_ metadataMap: AVFMappedMetadata) -> String?
    
    ///
    /// Read track album from the given metadata map. Returns nil if not present.
    ///
    func getAlbum(_ metadataMap: AVFMappedMetadata) -> String?
    
    ///
    /// Read track genre from the given metadata map. Returns nil if not present.
    ///
    func getGenre(_ metadataMap: AVFMappedMetadata) -> String?
    
    ///
    /// Read track lyrics from the given metadata map. Returns nil if not present.
    ///
    func getLyrics(_ metadataMap: AVFMappedMetadata) -> String?
    
    ///
    /// Read album disc number (disc number and total discs) from the given metadata map. Returns nil if not present.
    ///
    func getDiscNumber(_ metadataMap: AVFMappedMetadata) -> (number: Int?, total: Int?)?
    
    ///
    /// Read album / disc track number (track number and total tracks) from the given metadata map. Returns nil if not present.
    ///
    func getTrackNumber(_ metadataMap: AVFMappedMetadata) -> (number: Int?, total: Int?)?
    
    func getYear(_ metadataMap: AVFMappedMetadata) -> Int?
    
    ///
    /// Read track cover art from the given metadata map. Returns nil if not present.
    ///
    func getArt(_ metadataMap: AVFMappedMetadata) -> CoverArt?
    
    ///
    /// Read all auxiliary (non-essential) metadata from the given metadata map.
    /// Returns a map of key -> MetadataEntry.
    ///
    func getAuxiliaryMetadata(_ metadataMap: AVFMappedMetadata) -> [String: MetadataEntry]

    ///
    /// Read a chapter's title from the given collection of metadata items. Returns nil if not present.
    ///
    func getChapterTitle(_ items: [AVMetadataItem]) -> String?
}

///
/// Default function implementations
///
extension AVFMetadataParser {
    
    func getTitle(_ metadataMap: AVFMappedMetadata) -> String? {nil}
    
    func getArtist(_ metadataMap: AVFMappedMetadata) -> String? {nil}
    
    func getAlbum(_ metadataMap: AVFMappedMetadata) -> String? {nil}
    
    func getGenre(_ metadataMap: AVFMappedMetadata) -> String? {nil}
    
    func getDuration(_ metadataMap: AVFMappedMetadata) -> Double? {nil}
    
    func getDiscNumber(_ metadataMap: AVFMappedMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getTrackNumber(_ metadataMap: AVFMappedMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getLyrics(_ metadataMap: AVFMappedMetadata) -> String? {nil}
    
    func getYear(_ metadataMap: AVFMappedMetadata) -> Int? {nil}
    
    func getArt(_ metadataMap: AVFMappedMetadata) -> CoverArt? {nil}
    
    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {nil}
    
    func getAuxiliaryMetadata(_ metadataMap: AVFMappedMetadata) -> [String: MetadataEntry] {[:]}
}
