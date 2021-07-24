//
//  TuneBrowserViewDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TuneBrowserViewDelegate: NSObject, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    let textFont: NSFont = .auxiliary_size13
    
    @IBOutlet weak var browserView: TuneBrowserOutlineView!
    
    private let fileSystem: FileSystem = objectGraph.fileSystem
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, typeSelectStringFor tableColumn: NSTableColumn?, item: Any) -> String? {
        
        guard tableColumn?.identifier == .cid_tuneBrowserName, let fsItem = item as? FileSystemItem else {return nil}
        return fsItem.name
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {

            return fileSystem.root.children.count

        } else if let fsItem = item as? FileSystemItem {

            return fsItem.children.count
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            
            return fileSystem.root.children[index]
            
        } else if let fsItem = item as? FileSystemItem {
            
            return fsItem.children[index]
        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (item as? FileSystemItem)?.isDirectory ?? false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let colID = tableColumn?.identifier, let fsItem = item as? FileSystemItem else {return nil}
        
        switch colID {
        
        case .cid_tuneBrowserName:      return createNameCell(outlineView, fsItem)
            
        case .cid_tuneBrowserType:      return createTypeCell(outlineView, fsItem)
            
        case .cid_tuneBrowserTitle:     return createTitleCell(outlineView, fsItem)
            
        case .cid_tuneBrowserArtist:    return createArtistCell(outlineView, fsItem)
            
        case .cid_tuneBrowserAlbum:    return createAlbumCell(outlineView, fsItem)
            
        case .cid_tuneBrowserGenre:    return createGenreCell(outlineView, fsItem)
            
        case .cid_tuneBrowserTrackNum:    return createTrackNumberCell(outlineView, fsItem)
            
        case .cid_tuneBrowserDiscNum:    return createDiscNumberCell(outlineView, fsItem)
            
        case .cid_tuneBrowserYear:    return createYearCell(outlineView, fsItem)
            
        case .cid_tuneBrowserDuration:    return createDurationCell(outlineView, fsItem)
            
        case .cid_tuneBrowserFormat:    return createFormatCell(outlineView, fsItem)
            
        default:                        return nil
            
        }
    }
    
    private func createNameCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemNameCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserName, owner: nil)
            as? TuneBrowserItemNameCell else {return nil}
        
        cell.initializeForFile(item)
        cell.lblName.font = textFont
        
        return cell
    }
    
    private func createTypeCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTypeCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserType, owner: nil)
            as? TuneBrowserItemTypeCell else {return nil}
        
        cell.initializeForFile(item)
        cell.textFont = textFont
        
        return cell
    }
    
    private func createTitleCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack, let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserTitle, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = item.metadata?.playlist?.title
        cell.textFont = textFont
        
        return cell
    }
    
    private func createArtistCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack, let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserArtist, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        let metadata = item.metadata?.playlist
        cell.text = metadata?.artist ?? metadata?.albumArtist ?? metadata?.performer
        cell.textFont = textFont
        
        return cell
    }
    
    private func createAlbumCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack, let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserAlbum, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = item.metadata?.playlist?.album
        cell.textFont = textFont
        
        return cell
    }
    
    private func createGenreCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack, let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserGenre, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = item.metadata?.playlist?.genre
        cell.textFont = textFont
        
        return cell
    }
    
    private func createTrackNumberCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack,
              let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserTrackNum, owner: nil) as? TuneBrowserItemTextCell,
              let trackNum = item.metadata?.playlist?.trackNumber else {return nil}
        
        if let totalTracks = item.metadata?.playlist?.totalTracks {
            cell.text = "\(trackNum) / \(totalTracks)"
        } else {
            cell.text = "\(trackNum)"
        }
        
        cell.textFont = textFont
        
        return cell
    }
    
    private func createDiscNumberCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack,
              let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserDiscNum, owner: nil) as? TuneBrowserItemTextCell,
              let discNum = item.metadata?.playlist?.discNumber else {return nil}
        
        if let totalDiscs = item.metadata?.playlist?.totalDiscs {
            cell.text = "\(discNum) / \(totalDiscs)"
        } else {
            cell.text = "\(discNum)"
        }
        
        cell.textFont = textFont
        
        return cell
    }
    
    private func createYearCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack,
              let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserYear, owner: nil) as? TuneBrowserItemTextCell,
              let year = item.metadata?.auxiliary?.year else {return nil}
        
        cell.text = "\(year)"
        cell.textFont = textFont
        
        return cell
    }
    
    private func createDurationCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack, let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserDuration, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = ValueFormatter.formatSecondsToHMS(item.metadata?.playlist?.duration ?? 0)
        cell.textFont = textFont
        
        return cell
    }
    
    private func createFormatCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack, let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserFormat, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        let metadata = item.metadata?.auxiliary?.audioInfo
        cell.text = metadata?.codec ?? metadata?.format
        cell.textFont = textFont
        
        return cell
    }
    
    func outlineViewItemWillExpand(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo, let fsItem = userInfo["NSObject"] as? FileSystemItem else {
            return
        }
        
        fileSystem.loadMetadata(forChildrenOf: fsItem)
    }
    
    func outlineView(_ outlineView: NSOutlineView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
        guard let sortDescriptor = outlineView.sortDescriptors.first, let key = sortDescriptor.key else {return}
        let ascending = sortDescriptor.ascending
        
        switch key {
        
        case "name":
            
            fileSystem.sort(by: .name, ascending: ascending)
        
        case "title":
            
            fileSystem.sort(by: .title, ascending: ascending)
            
        case "duration":
            
            fileSystem.sort(by: .duration, ascending: ascending)
            
        case "artist":
            
            fileSystem.sort(by: .artist, ascending: ascending)
            
        case "album":
            
            fileSystem.sort(by: .album, ascending: ascending)
            
        case "genre":
            
            fileSystem.sort(by: .genre, ascending: ascending)
            
        case "type":
            
            fileSystem.sort(by: .type, ascending: ascending)
            
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
