//
// PlayQueueTabularViewController+TableViewDelegate.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension PlayQueueTabularViewController {
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = trackList[row], let column = tableColumn?.identifier else {return nil}
        
        let builder = TableCellBuilder()
        
        switch column {
            
        case .cid_index:
            
            if track == playQueueDelegate.currentTrack {
                builder.withImage(image: .imgPlayFilled, inColor: systemColorScheme.activeControlColor)
                
            } else {
                builder.withText(text: "\(row + 1)",
                                        inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                        selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                        bottomYOffset: systemFontScheme.tableYOffset)
            }
            
        case .cid_fileName:
            builder.withPrimaryText(track.fileName)
            
        case .cid_title:
            builder.withPrimaryText(track.titleOrDefaultDisplayName)
            
        case .cid_artist:
            
            guard let artist = track.artist else {return nil}
            builder.withPrimaryText(artist)
            
        case .cid_album:
            
            guard let album = track.album else {return nil}
            builder.withPrimaryText(album)
            
        case .cid_genre:
            
            guard let genre = track.genre else {return nil}
            builder.withPrimaryText(genre)
            
        case .cid_trackNum:
            
            if let trackNum = track.trackNumber {

                if let totalTracks = track.totalTracks, totalTracks > 0 {
                    builder.withPrimaryText("\(trackNum) / \(totalTracks)")
                    
                } else if trackNum > 0 {
                    builder.withPrimaryText("\(trackNum)")
                    
                } else {
                    return nil
                }
                
            } else {
                return nil
            }
            
        case .cid_discNum:
            
            if let discNum = track.discNumber {
                
                if let totalDiscs = track.totalDiscs, totalDiscs > 0 {
                    builder.withPrimaryText("\(discNum) / \(totalDiscs)")
                    
                } else if discNum > 0 {
                    builder.withPrimaryText("\(discNum)")
                    
                } else {
                    return nil
                }
                
            } else {
                return nil
            }
            
        case .cid_year:
            
            guard let year = track.year else {return nil}
            builder.withPrimaryText("\(year)")
            
        case .cid_duration:
            
            builder.withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                    inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                    selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                    bottomYOffset: systemFontScheme.tableYOffset)
            
        case .cid_format:
            
            guard let format = track.audioInfo.format?.capitalizingFirstLetter() else {return nil}
            builder.withPrimaryText(format)
            
        case .cid_playCount:
            builder.withPrimaryText("\(historyDelegate.playCount(forTrack: track))")
            
        case .cid_playCount:
            builder.withPrimaryText("\(historyDelegate.playCount(forTrack: track))")
            
        case .cid_lastPlayed:
            
            if let lastPlayedTime = historyDelegate.lastPlayedTime(forTrack: track) {
                builder.withPrimaryText("\(lastPlayedTime.hmsString)")
            }
            
        default:
            return nil
        }
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: column, inRow: row)
    }
    
    func tableView(_ tableView: NSTableView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
        tableView.tableColumns[columnIndex].identifier != .cid_index && newColumnIndex != 0
    }
    
    func tableViewColumnDidMove(_ notification: Notification) {
        saveColumnsState()
    }
    
    func tableViewColumnDidResize(_ notification: Notification) {
        saveColumnsState()
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
        guard let sortDescriptor = tableView.sortDescriptors.first, let key = sortDescriptor.key else {return}
        let ascending = sortDescriptor.ascending
        let sortOrder = sortDescriptor.sortOrder
        
        print("Desc: \(key), Asc: \(ascending)")
        
        switch key {
            
        case "fileName":
            doSort(by: [.fileName], order: sortOrder)
            
        case "title":
            doSort(by: [.title], order: sortOrder)
            
        case "duration":
            doSort(by: [.duration], order: sortOrder)
            
        case "artist":
            doSort(by: [.artist], order: sortOrder)
            
        case "album":
            doSort(by: [.album], order: sortOrder)
            
        case "genre":
            doSort(by: [.genre], order: sortOrder)
            
//        case "format":
//            
//
//        case "trackNum":
            
                        
        default: return
            
        }
    }
    
    private func doSort(by fields: [TrackSortField], order: SortOrder) {
        
        sort(by: fields, order: order)
        updateSummary()
    }
}

fileprivate extension NSSortDescriptor {
    
    var sortOrder: SortOrder {
        ascending ? .ascending : .descending
    }
}

fileprivate extension TableCellBuilder {
    
    func withPrimaryText(_ text: String) {
        
        withText(text: text,
                 inFont: systemFontScheme.normalFont, andColor: systemColorScheme.primaryTextColor,
                 selectedTextColor: systemColorScheme.primarySelectedTextColor,
                 bottomYOffset: systemFontScheme.tableYOffset)
    }
}
