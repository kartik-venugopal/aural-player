//
//  TuneBrowserTabViewController+ViewDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension TuneBrowserTabViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, typeSelectStringFor tableColumn: NSTableColumn?, item: Any) -> String? {
        
        guard tableColumn?.identifier == .cid_tuneBrowserName, NSEvent.noModifiedFlagsSet, let fsItem = item as? FileSystemItem else {return nil}
        return fsItem.name
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        LibrarySidebarRowView()
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {30}
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        guard let fsItem = item as? FileSystemItem else {return false}
        return fsItem.type.equalsOneOf(.folder, .playlist)
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let colID = tableColumn?.identifier, let fsItem = item as? FileSystemItem else {return nil}
        
        if colID == .cid_tuneBrowserName {
            return createNameCell(outlineView, fsItem)
        }
        
        if colID == .cid_tuneBrowserType {
            return createTypeCell(outlineView, fsItem)
        }
            
        guard let trackItem = item as? FileSystemTrackItem else {return nil}
        
        switch colID {
            
        case .cid_tuneBrowserTitle:     return createTitleCell(outlineView, trackItem)
            
        case .cid_tuneBrowserArtist:    return createArtistCell(outlineView, trackItem)
            
        case .cid_tuneBrowserAlbum:    return createAlbumCell(outlineView, trackItem)
            
        case .cid_tuneBrowserGenre:    return createGenreCell(outlineView, trackItem)
            
        case .cid_tuneBrowserTrackNum:    return createTrackNumberCell(outlineView, trackItem)
            
        case .cid_tuneBrowserDiscNum:    return createDiscNumberCell(outlineView, trackItem)
            
        case .cid_tuneBrowserYear:    return createYearCell(outlineView, trackItem)
            
        case .cid_tuneBrowserDuration:    return createDurationCell(outlineView, trackItem)
            
        case .cid_tuneBrowserFormat:    return createFormatCell(outlineView, trackItem)
            
        default:                        return nil
            
        }
    }
    
    private func createNameCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemNameCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserName, owner: nil)
                as? TuneBrowserItemNameCell else {return nil}
        
        cell.initializeForFile(item)
        cell.lblName.font = textFont
        cell.lblName.textColor = systemColorScheme.primaryTextColor
        
        return cell
    }
    
    private func createTypeCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTypeCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserType, owner: nil)
                as? TuneBrowserItemTypeCell else {return nil}
        
        cell.initializeForFile(item)
        cell.textFont = textFont
        cell.textColor = systemColorScheme.secondaryTextColor
        
        return cell
    }
    
    private func createTitleCell(_ outlineView: NSOutlineView, _ item: FileSystemTrackItem) -> TuneBrowserItemTextCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserTitle, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = item.track.title
        cell.textFont = textFont
        cell.textColor = systemColorScheme.secondaryTextColor
        
        return cell
    }
    
    private func createArtistCell(_ outlineView: NSOutlineView, _ item: FileSystemTrackItem) -> TuneBrowserItemTextCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserArtist, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = item.track.artist ?? item.track.albumArtist
        cell.textFont = textFont
        cell.textColor = systemColorScheme.secondaryTextColor
        
        return cell
    }
    
    private func createAlbumCell(_ outlineView: NSOutlineView, _ item: FileSystemTrackItem) -> TuneBrowserItemTextCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserAlbum, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = item.track.album
        cell.textFont = textFont
        cell.textColor = systemColorScheme.secondaryTextColor
        
        return cell
    }
    
    private func createGenreCell(_ outlineView: NSOutlineView, _ item: FileSystemTrackItem) -> TuneBrowserItemTextCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserGenre, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = item.track.genre
        cell.textFont = textFont
        cell.textColor = systemColorScheme.secondaryTextColor
        
        return cell
    }
    
    private func createTrackNumberCell(_ outlineView: NSOutlineView, _ item: FileSystemTrackItem) -> TuneBrowserItemTextCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserTrackNum, owner: nil) as? TuneBrowserItemTextCell,
              let trackNum = item.track.trackNumber else {return nil}
        
        if let totalTracks = item.track.totalTracks {
            cell.text = "\(trackNum) / \(totalTracks)"
        } else {
            cell.text = "\(trackNum)"
        }
        
        cell.textFont = textFont
        cell.textColor = systemColorScheme.secondaryTextColor
        
        return cell
    }
    
    private func createDiscNumberCell(_ outlineView: NSOutlineView, _ item: FileSystemTrackItem) -> TuneBrowserItemTextCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserDiscNum, owner: nil) as? TuneBrowserItemTextCell,
              let discNum = item.track.discNumber else {return nil}
        
        if let totalDiscs = item.track.totalDiscs {
            cell.text = "\(discNum) / \(totalDiscs)"
        } else {
            cell.text = "\(discNum)"
        }
        
        cell.textFont = textFont
        cell.textColor = systemColorScheme.secondaryTextColor
        
        return cell
    }
    
    private func createYearCell(_ outlineView: NSOutlineView, _ item: FileSystemTrackItem) -> TuneBrowserItemTextCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserYear, owner: nil) as? TuneBrowserItemTextCell,
              let year = item.track.year else {return nil}
        
        cell.text = "\(year)"
        cell.textFont = textFont
        cell.textColor = systemColorScheme.secondaryTextColor
        
        return cell
    }
    
    private func createDurationCell(_ outlineView: NSOutlineView, _ item: FileSystemTrackItem) -> TuneBrowserItemTextCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserDuration, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = ValueFormatter.formatSecondsToHMS(item.track.duration)
        cell.textFont = textFont
        cell.textColor = systemColorScheme.secondaryTextColor
        
        return cell
    }
    
    private func createFormatCell(_ outlineView: NSOutlineView, _ item: FileSystemTrackItem) -> TuneBrowserItemTextCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserFormat, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        let metadata = item.track.audioInfo
        cell.text = metadata?.codec ?? metadata?.format
        cell.textFont = textFont
        cell.textColor = systemColorScheme.secondaryTextColor
        
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
        guard let sortDescriptor = outlineView.sortDescriptors.first, let key = sortDescriptor.key else {return}
        let ascending = sortDescriptor.ascending
        
        switch key {
            
        case "name":
            
            rootFolder.sortChildren(by: .name, ascending: ascending)
            
        case "title":
            
            rootFolder.sortChildren(by: .title, ascending: ascending)
            
        case "duration":
            
            rootFolder.sortChildren(by: .duration, ascending: ascending)
            
        case "artist":
            
            rootFolder.sortChildren(by: .artist, ascending: ascending)
            
        case "album":
            
            rootFolder.sortChildren(by: .album, ascending: ascending)
            
        case "genre":
            
            rootFolder.sortChildren(by: .genre, ascending: ascending)
            
        case "type":
            
            rootFolder.sortChildren(by: .type, ascending: ascending)
            
        case "trackNum":
            
            rootFolder.sortChildren(by: .trackNumber, ascending: ascending)
            
        default: return
            
        }
        
        outlineView.reloadData()
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let cid_tuneBrowserName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_name")
    static let cid_tuneBrowserType: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_type")
    
    static let cid_tuneBrowserTitle: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_title")
    static let cid_tuneBrowserArtist: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_artist")
    static let cid_tuneBrowserAlbum: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_album")
    static let cid_tuneBrowserGenre: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_genre")
    
    static let cid_tuneBrowserDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_duration")
    static let cid_tuneBrowserFormat: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_format")
    
    static let cid_tuneBrowserYear: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_year")
    
    static let cid_tuneBrowserTrackNum: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_trackNum")
    static let cid_tuneBrowserDiscNum: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_discNum")
}
