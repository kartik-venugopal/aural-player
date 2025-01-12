//
//  TuneBrowserTabViewController+Actions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension TuneBrowserTabViewController {
    
    @IBAction func toggleColumnAction(_ sender: NSMenuItem) {
        
        // TODO: Validation - Don't allow 0 columns to be shown.
        
        guard let id = sender.identifier, let col = browserView.tableColumn(withIdentifier: id) else {return}
        
        col.isHidden.toggle()
        
        //        if col.isHidden {
        //            tuneBrowserUIState.displayedColumns.removeValue(forKey: id.rawValue)
        //        } else {
        //            tuneBrowserUIState.displayedColumns[id.rawValue] = .init(id: id.rawValue, width: col.width)
        //        }
    }
    
    @IBAction func doubleClickAction(_ sender: Any) {
        
        guard let item = browserView.item(atRow: browserView.selectedRow),
              let fsItem = item as? FileSystemItem else {return}
        
        if fsItem.isTrack || fsItem.isPlaylist {
            playQueueDelegate.enqueueToPlayNow(fileSystemItems: [fsItem], clearQueue: false)
            
        } else if let folderItem = fsItem as? FileSystemFolderItem {
            
            saveColumnsState()
            
            // Folder
            messenger.publish(.tuneBrowser_openFolder,
                              payload: OpenTuneBrowserFolderCommandNotification(folderToOpen: folderItem,
                                                                                treeContainingFolder: self.tree,
                                                                                currentlyOpenFolder: self.rootFolder))
        }
    }
    
    /// Clear Queue and Play Now
    @IBAction func playNowAction(_ sender: Any) {
        doAddBrowserItemsToPlayQueue(items: browserView.selectedFileSystemItems, clearQueue: true, beginPlayback: true)
    }
    
    /// Enqueue and Play Now
    @IBAction func enqueueAndPlayBrowserItemsAction(_ sender: Any) {
        doAddBrowserItemsToPlayQueue(items: browserView.selectedFileSystemItems, beginPlayback: true)
    }
    
    /// Play Later
    @IBAction func enqueueBrowserItemsAction(_ sender: Any) {
        doAddBrowserItemsToPlayQueue(items: browserView.selectedFileSystemItems)
    }
    
    @IBAction func addSidebarShortcutAction(_ sender: Any) {
        
        if let clickedItem: FileSystemFolderItem = browserView.rightClickedItem as? FileSystemFolderItem {

            tuneBrowserUIState.addUserFolder(clickedItem, inTree: self.tree)
            messenger.publish(.Library.Sidebar.addFileSystemShortcut, payload: clickedItem.url)
        }
    }
    
    @IBAction func removeSidebarShortcutAction(_ sender: Any) {
        
//        if let clickedItem: TuneBrowserSidebarItem = sidebarView.rightClickedItem as? TuneBrowserSidebarItem,
//           let removedItemIndex = tuneBrowserUIState.removeUserFolder(item: clickedItem) {
//
//            let musicFolderRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders) + 1
//            let selectedRow = sidebarView.selectedRow
//            let selectedItemRemoved = selectedRow == (musicFolderRow + removedItemIndex + 1)
//
//            sidebarView.removeItems(at: IndexSet([removedItemIndex + 1]),
//                                    inParent: TuneBrowserSidebarCategory.folders, withAnimation: .effectFade)
//
//            if selectedItemRemoved {
//
//                let foldersRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders)
//                let musicFolderRow = foldersRow + 1
//                sidebarView.selectRow(musicFolderRow)
//            }
//        }
    }
    
    @IBAction func addToFavoritesAction(_ sender: NSMenuItem) {
        
        guard let selItem = browserView.selectedFileSystemItems.first else {return}
        
        if selItem.isDirectory {
            favoritesDelegate.addFavorite(folder: selItem.url)
            
        } else if selItem.isTrack, let track = selItem as? FileSystemTrackItem {
            favoritesDelegate.addFavorite(track: track.track)
            
        } else if selItem.isPlaylist {
            favoritesDelegate.addFavorite(playlistFile: selItem.url)
        }
    }
    
    @IBAction func showBrowserItemInFinderAction(_ sender: Any) {
        
        if let selItem = browserView.rightClickedItem as? FileSystemItem {
            selItem.url.showInFinder()
        }
    }
}
