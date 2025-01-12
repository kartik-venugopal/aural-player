////
////  CueSheetIO+Parser.swift
////  Aural
////
////  Copyright © 2025 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////  
//
//import Foundation
//
//extension CueSheetIO {
//    
//    private static let prefix_genre: String = "REM GENRE"
//    private static let prefix_date: String = "REM DATE"
//    private static let prefix_discID: String = "REM DISCID"
//    private static let prefix_comment: String = "REM COMMENT"
//
//    private static let prefix_file: String = "FILE"
//    private static let prefix_track: String = "TRACK"
//
//    private static let trackFormat_audio: String = "AUDIO"
//
//    private static let prefix_title: String = "TITLE"
//    private static let prefix_index: String = "INDEX"
//
//    private static let prefix_performer: String = "PERFORMER"
//    private static let prefix_songwriter: String = "SONGWRITER"
//
//    private static var cursor: Int = 0
//    private static var lines: [String] = []
//    private static var line: String = ""
//    
//    static func parseCueSheet(fromFile playlistFile: URL) -> CueSheet? {
//        
//        guard let fileContents: String = PlaylistIO.readFileAsString(playlistFile) else {return nil}
//        lines = fileContents.components(separatedBy: .newlines)
//
//        let cueSheet: CueSheet = .init()
//        cursor = 0
//
//        while cursor < lines.count {
//
//            line = lines[cursor].trim()
//
//            if line.starts(with: prefix_file), let file = parseFile(playlistFile, 0) {
//                
//                cueSheet.files.append(file)
//                cursor.decrement()
//                
//            } else if line.starts(with: prefix_performer) {
//                cueSheet.albumPerformer = parseMetdataField(prefix_performer)
//                
//            } else if line.starts(with: prefix_songwriter), cueSheet.albumPerformer == nil {
//                cueSheet.albumPerformer = parseMetdataField(prefix_songwriter)
//                
//            } else if line.starts(with: prefix_title) {
//                cueSheet.album = parseMetdataField(prefix_title)
//                
//            } else if line.starts(with: prefix_genre) {
//                cueSheet.genre = parseMetdataField(prefix_genre)
//                
//            } else if line.starts(with: prefix_date) {
//                cueSheet.date = parseMetdataField(prefix_date)
//                
//            } else if line.starts(with: prefix_discID) {
//                cueSheet.discID = parseMetdataField(prefix_discID)
//                
//            } else if line.starts(with: prefix_comment) {
//                cueSheet.comment = parseMetdataField(prefix_comment)
//            }
//            
//            cursor.increment()
//        }
//        
//        return cueSheet
//    }
//    
//    private static let character_doubleQuote: String = "\""
//    
//    private static func parseFile(_ playlistFile: URL, _ rootIndentLevel: Int) -> CueSheetFile? {
//        
//        var tokens = line.components(separatedBy: " ")
//        if tokens.count < 2 {return nil}
//
//        // Remove "FILE" and "<FileFormat>" tokens
//        tokens.removeFirst()
//        tokens.removeLast()
//
//        let filename: String = (tokens.count == 1 ? tokens[0] : tokens.joined(separator: " ")).removingOccurrences(of: character_doubleQuote)
//        let cueSheetFile: CueSheetFile = .init(filename: filename)
//
//        cursor.increment()
//
//        while cursor < lines.count {
//
//            line = lines[cursor]
//            let indentLevel = line.prefix(while: {$0 == " "}).count
//
//            // Terminate
//            if !line.isEmptyAfterTrimming && indentLevel <= rootIndentLevel {
//                break
//            }
//
//            line = line.trim()
//
//            if line.starts(with: prefix_track) {
//
//                if let track = parseTrack(indentLevel) {
//                    cueSheetFile.tracks.append(track)
//                }
//
//            } else {
//                cursor.increment()
//            }
//        }
//        
//        return cueSheetFile
//    }
//
//    private static func parseTrack(_ rootIndentLevel: Int) -> CueSheetTrack? {
//
//        // Verify that it's an audio track
//        let trackTokens = line.components(separatedBy: " ")
//        if trackTokens.count < 3 || !trackTokens.contains(trackFormat_audio) {return nil}
//
//        cursor.increment()
//
//        var title: String?
//        var performer: String?
//        var songwriter: String?
//        var index: Double?
//
//        // Read performer, title, start time
//        while cursor < lines.count {
//
//            line = lines[cursor]
//            let indentLevel = line.prefix(while: {$0 == " "}).count
//
//            let trimmedLine = line.trim()
//
//            // Terminate if indentation has reduced to the same level as the root TRACK element
//            if !trimmedLine.isEmpty && indentLevel <= rootIndentLevel {
//                break
//            }
//
//            line = trimmedLine
//
//            if line.starts(with: prefix_title) {
//                title = parseMetdataField(prefix_title)
//
//            } else if line.starts(with: prefix_performer) {
//                performer = parseMetdataField(prefix_performer)
//
//            } else if line.starts(with: prefix_songwriter), performer == nil {
//                songwriter = parseMetdataField(prefix_songwriter)
//
//            } else if index == nil && line.starts(with: prefix_index) {
//                index = parseIndex()
//            }
//
//            cursor.increment()
//        }
//        
//        return CueSheetTrack(title: title, performer: performer ?? songwriter, startTime: index)
//    }
//    
//    private static func parseMetdataField(_ field: String) -> String? {
//
//        let value = line.replacingOccurrences(of: field, with: "").trim().removingOccurrences(of: "\"")
//        return value.isEmpty ? nil : value
//    }
//
//    private static func parseIndex() -> Double? {
//
//        let tokens = line.components(separatedBy: " ")
//        
//        guard tokens.count >= 3, tokens[1] == "01" else {return nil}
//
//        // mm:ss:ff (ff = frames ... 1/75 second)
//        let timeTokens = tokens[2].components(separatedBy: ":")
//
//        if timeTokens.count >= 3, let minutes = Double(timeTokens[0]), let seconds = Double(timeTokens[1]), let frames = Double(timeTokens[2]) {
//            return (minutes * 60.0) + seconds + (frames / 75.0)
//        }
//
//        return nil
//    }
//}
