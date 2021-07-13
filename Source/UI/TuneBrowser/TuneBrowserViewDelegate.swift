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
    
    let textFont: NSFont = FontConstants.Auxiliary.size13
    
    @IBOutlet weak var browserView: TuneBrowserOutlineView!
    
    private let fileSystem: FileSystem = ObjectGraph.fileSystem
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, typeSelectStringFor tableColumn: NSTableColumn?, item: Any) -> String? {
        
        guard tableColumn?.identifier == .uid_tuneBrowserName, let fsItem = item as? FileSystemItem else {return nil}
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
        
        case .uid_tuneBrowserName:      return createNameCell(outlineView, fsItem)
            
        case .uid_tuneBrowserType:      return createTypeCell(outlineView, fsItem)
            
        case .uid_tuneBrowserTitle:     return createTitleCell(outlineView, fsItem)
            
        case .uid_tuneBrowserArtist:    return createArtistCell(outlineView, fsItem)
            
        case .uid_tuneBrowserAlbum:    return createAlbumCell(outlineView, fsItem)
            
        case .uid_tuneBrowserGenre:    return createGenreCell(outlineView, fsItem)
            
        case .uid_tuneBrowserTrackNum:    return createTrackNumberCell(outlineView, fsItem)
            
        case .uid_tuneBrowserDiscNum:    return createDiscNumberCell(outlineView, fsItem)
            
        case .uid_tuneBrowserYear:    return createYearCell(outlineView, fsItem)
            
        case .uid_tuneBrowserDuration:    return createDurationCell(outlineView, fsItem)
            
        case .uid_tuneBrowserFormat:    return createFormatCell(outlineView, fsItem)
            
        default:                        return nil
            
        }
    }
    
    private func createNameCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemNameCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_tuneBrowserName, owner: nil)
            as? TuneBrowserItemNameCell else {return nil}
        
        cell.initializeForFile(item)
        cell.lblName.font = textFont
        
        return cell
    }
    
    private func createTypeCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTypeCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_tuneBrowserType, owner: nil)
            as? TuneBrowserItemTypeCell else {return nil}
        
        cell.initializeForFile(item)
        cell.textField?.font = textFont
        
        return cell
    }
    
    private func createTitleCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack, let cell = outlineView.makeView(withIdentifier: .uid_tuneBrowserTitle, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = item.metadata?.playlist?.title
        cell.textField?.font = textFont
        
        return cell
    }
    
    private func createArtistCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack, let cell = outlineView.makeView(withIdentifier: .uid_tuneBrowserArtist, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        let metadata = item.metadata?.playlist
        cell.text = metadata?.artist ?? metadata?.albumArtist ?? metadata?.performer
        cell.textField?.font = textFont
        
        return cell
    }
    
    private func createAlbumCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack, let cell = outlineView.makeView(withIdentifier: .uid_tuneBrowserAlbum, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = item.metadata?.playlist?.album
        cell.textField?.font = textFont
        
        return cell
    }
    
    private func createGenreCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack, let cell = outlineView.makeView(withIdentifier: .uid_tuneBrowserGenre, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = item.metadata?.playlist?.genre
        cell.textField?.font = textFont
        
        return cell
    }
    
    private func createTrackNumberCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack,
              let cell = outlineView.makeView(withIdentifier: .uid_tuneBrowserTrackNum, owner: nil) as? TuneBrowserItemTextCell,
              let trackNum = item.metadata?.playlist?.trackNumber else {return nil}
        
        if let totalTracks = item.metadata?.playlist?.totalTracks {
            cell.text = "\(trackNum) / \(totalTracks)"
        } else {
            cell.text = "\(trackNum)"
        }
        
        cell.textField?.font = textFont
        
        return cell
    }
    
    private func createDiscNumberCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack,
              let cell = outlineView.makeView(withIdentifier: .uid_tuneBrowserDiscNum, owner: nil) as? TuneBrowserItemTextCell,
              let discNum = item.metadata?.playlist?.discNumber else {return nil}
        
        if let totalDiscs = item.metadata?.playlist?.totalDiscs {
            cell.text = "\(discNum) / \(totalDiscs)"
        } else {
            cell.text = "\(discNum)"
        }
        
        cell.textField?.font = textFont
        
        return cell
    }
    
    private func createYearCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack,
              let cell = outlineView.makeView(withIdentifier: .uid_tuneBrowserYear, owner: nil) as? TuneBrowserItemTextCell,
              let year = item.metadata?.auxiliary?.year else {return nil}
        
        cell.text = "\(year)"
        cell.textField?.font = textFont
        
        return cell
    }
    
    private func createDurationCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack, let cell = outlineView.makeView(withIdentifier: .uid_tuneBrowserDuration, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        cell.text = ValueFormatter.formatSecondsToHMS(item.metadata?.playlist?.duration ?? 0)
        cell.textField?.font = textFont
        
        return cell
    }
    
    private func createFormatCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTextCell? {
        
        guard item.isTrack, let cell = outlineView.makeView(withIdentifier: .uid_tuneBrowserFormat, owner: nil)
                as? TuneBrowserItemTextCell else {return nil}
        
        let metadata = item.metadata?.auxiliary?.audioInfo
        cell.text = metadata?.codec ?? metadata?.format
        cell.textField?.font = textFont
        
        return cell
    }
    
    func outlineViewItemWillExpand(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo, let fsItem = userInfo["NSObject"] as? FileSystemItem else {
            return
        }
        
        fileSystem.loadMetadata(forChildrenOf: fsItem)
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let uid_tuneBrowserName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_name")
    static let uid_tuneBrowserType: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_type")
    
    static let uid_tuneBrowserTitle: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_title")
    static let uid_tuneBrowserArtist: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_artist")
    static let uid_tuneBrowserAlbum: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_album")
    static let uid_tuneBrowserGenre: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_genre")
    
    static let uid_tuneBrowserDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_duration")
    static let uid_tuneBrowserFormat: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_format")
    
    static let uid_tuneBrowserYear: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_year")
    
    static let uid_tuneBrowserTrackNum: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_trackNum")
    static let uid_tuneBrowserDiscNum: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowser_discNum")
}
