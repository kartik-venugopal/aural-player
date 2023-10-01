//
//  CueSheetIO.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation


// *** Code in early stages of development. Not production-ready.

class CueSheetIO: PlaylistIOProtocol {
    
    static func savePlaylist(tracks: [Track], toFile file: URL) {
        
    }

    static var playlist: PlaylistAccessorProtocol!

    static func initialize(_ playlist: PlaylistAccessorProtocol) {
        Self.playlist = playlist
    }
    
    private static let prefix_comment: String = "REM"

    private static let prefix_file: String = "FILE"
    private static let prefix_track: String = "TRACK"

    private static let trackFormat_audio: String = "AUDIO"

    private static let prefix_title: String = "TITLE"
    private static let prefix_index: String = "INDEX"

    private static let prefix_performer: String = "PERFORMER"
    private static let prefix_songwriter: String = "SONGWRITER"

    // Transient data
    
    private static var cursor: Int = 0
    private static var lines: [String] = []
    private static var line: String = ""

    static func loadPlaylist(fromFile playlistFile: URL) -> ImportedPlaylist? {

        guard let fileContents: String = PlaylistIO.readFileAsString(playlistFile) else {return nil}

        lines = fileContents.components(separatedBy: .newlines)

        var tracks: [ImportedPlaylistTrack] = []
        cursor = 0

        while cursor < lines.count {

            line = lines[cursor].trim()

            if line.starts(with: prefix_file), let track = readFile(playlistFile, 0) {
                tracks.append(ImportedPlaylistTrack(file: track.file, chapters: track.chapters))

            } else {
                cursor.increment()
            }
        }

        return ImportedPlaylist(file: playlistFile, tracks: tracks)
    }

    private static func readFile(_ playlistFile: URL, _ rootIndentLevel: Int) -> (file: URL, chapters: [Chapter])? {

        var tokens = line.components(separatedBy: " ")

        var chapterTitlesAndStartTimes: [(title: String?, startTime: Double)] = []
        var chapters: [Chapter] = []

        if tokens.count < 2 {return nil}

        tokens.remove(at: 0)
        tokens.removeLast()

        let filePath: String = (tokens.count == 1 ? tokens[0] : tokens.joined(separator: " ")).replacingOccurrences(of: "\"", with: "")

        cursor.increment()

        while cursor < lines.count {

            line = lines[cursor]
            let indentLevel = line.prefix(while: {$0 == " "}).count

            // Terminate
            if !line.isEmptyAfterTrimming && indentLevel <= rootIndentLevel {
                break
            }

            line = line.trim()

            if line.starts(with: prefix_track) {

                if let chapter = readTrack(indentLevel) {
                    chapterTitlesAndStartTimes.append(chapter)
                }

            } else {
                cursor.increment()
            }
        }

        let playlistFolder: URL = playlistFile.deletingLastPathComponent()
        let url = playlistFolder.appendingPathComponent(filePath, isDirectory: false)

        chapterTitlesAndStartTimes.sort(by: {$0.startTime < $1.startTime})

        for index in 0..<chapterTitlesAndStartTimes.count {

            let title = chapterTitlesAndStartTimes[index].title
            let start = chapterTitlesAndStartTimes[index].startTime

            // Use start times to compute end times and durations

            let end = index == chapterTitlesAndStartTimes.count - 1 ? 0 : chapterTitlesAndStartTimes[index + 1].startTime
            let duration = end - start

            // Validate the time fields for NaN and negative values
            let correctedStart = (start.isNaN || start < 0) ? 0 : start
            let correctedEnd = (end.isNaN || end < 0) ? 0 : end
            let correctedDuration = (duration.isNaN || duration < 0) ? nil : duration

            chapters.append(Chapter(title: title ?? String(format: "Chapter %d", index + 1), startTime: correctedStart, endTime: correctedEnd, duration: correctedDuration))
        }
        
        // If there is only one chapter with no end time specified, that refers to the whole track.
        if chapters.count == 1, chapters[0].endTime == 0 {
            chapters = []
        }

        return (url, chapters)
    }

    private static func readTrack(_ rootIndentLevel: Int) -> (title: String?, startTime: Double)? {

        // Verify that it's an audio track
        let trackTokens = line.components(separatedBy: " ")
        if trackTokens.count < 3 || !trackTokens.contains(trackFormat_audio) {return nil}

        cursor.increment()

        var title: String?
        var performer: String?
        var songwriter: String?
        var index: Double?

        // Read performer, title, start time
        while cursor < lines.count {

            line = lines[cursor]
            let indentLevel = line.prefix(while: {$0 == " "}).count

            let trimmedLine = line.trim()

            // Terminate if indentation has reduced to the same level as the root TRACK element
            if !trimmedLine.isEmpty && indentLevel <= rootIndentLevel {
                break
            }

            line = trimmedLine

            if line.starts(with: prefix_title) {
                title = readTitleOrPerformer()

            } else if line.starts(with: prefix_performer) {
                performer = readTitleOrPerformer()

            } else if line.starts(with: prefix_songwriter) {
                songwriter = readTitleOrPerformer()

            } else if index == nil && line.starts(with: prefix_index) {
                index = readIndex()
            }

            cursor.increment()
        }

        guard let theIndex = index else {return nil}

        var chapterTitle: String? = nil

        if let theTitle = title, performer != nil || songwriter != nil {

            chapterTitle = "\(performer ?? songwriter ?? "") - \(theTitle)"

        } else if let theTitle = title {

            chapterTitle = theTitle
        }

        return (chapterTitle, theIndex)
    }

    private static func readTitleOrPerformer() -> String? {

        let tokens = line.components(separatedBy: " ")
        if tokens.count < 2 {return nil}

        return tokens.suffix(from: 1).joined(separator: " ").replacingOccurrences(of: "\"", with: "")
    }

    private static func readIndex() -> Double? {

        let tokens = line.components(separatedBy: " ")
        if tokens.count < 3 || tokens[1] != "01" {return nil}

        // mm:ss:ff (ff = frames ... 1/75 second)
        let timeTokens = tokens[2].components(separatedBy: ":")

        if timeTokens.count >= 3, let minutes = Double(timeTokens[0]), let seconds = Double(timeTokens[1]), let frames = Double(timeTokens[2]) {
            return (minutes * 60.0) + seconds + (frames / 75.0)
        }

        return nil
    }
}
