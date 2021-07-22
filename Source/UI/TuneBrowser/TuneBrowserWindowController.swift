//
//  TuneBrowserWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TuneBrowserWindowController: NSWindowController, NSMenuDelegate, Destroyable {
    
    override var windowNibName: String? {"TuneBrowser"}
    
    @IBOutlet weak var splitView: NSSplitView!
    
    @IBOutlet weak var browserView: TuneBrowserOutlineView!
    @IBOutlet weak var browserViewDelegate: TuneBrowserViewDelegate!
    
    @IBOutlet weak var sidebarView: TuneBrowserOutlineView!
    
    @IBOutlet weak var pathControlWidget: NSPathControl! {
        
        didSet {
            pathControlWidget.url = fileSystem.rootURL
        }
    }
    
    private let fileSystem: FileSystem = objectGraph.fileSystem
    
    // Delegate that relays CRUD actions to the playlist
    private lazy var playlist: PlaylistDelegateProtocol = objectGraph.playlistDelegate
    
    private lazy var messenger = Messenger(for: self)
    
    private lazy var uiState: TuneBrowserUIState = objectGraph.tuneBrowserUIState
    
    override func awakeFromNib() {
        
        // Sidebar width
        splitView.setPosition(uiState.sidebarWidth + 3, ofDividerAt: 0)
        
        var displayedColumnIds: [String] = uiState.displayedColumns.compactMap {$0.id}
        
        // Show default columns if none have been selected (eg. first time app is launched).
        if displayedColumnIds.isEmpty {
            displayedColumnIds = [NSUserInterfaceItemIdentifier.uid_tuneBrowserName.rawValue]
        }
        
        for column in browserView.tableColumns {
//            column.headerCell = LibraryTableHeaderCell(stringValue: column.headerCell.stringValue)
            column.isHidden = !displayedColumnIds.contains(column.identifier.rawValue)
        }
        
        for (index, columnId) in displayedColumnIds.enumerated() {
            
            let oldIndex = browserView.column(withIdentifier: NSUserInterfaceItemIdentifier(columnId))
            browserView.moveColumn(oldIndex, toColumn: index)
        }
        
        var windowFrame = self.window!.frame
        windowFrame.size = uiState.windowSize
        self.window?.setFrame(windowFrame, display: true)
        
        for column in uiState.displayedColumns {
            browserView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(column.id))?.width = column.width
        }
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        messenger.subscribe(to: .tuneBrowser_sidebarSelectionChanged, handler: sidebarSelectionChanged(_:),
                            filter: {[weak self] notif in self?.respondToSidebarSelectionChange ?? false})
        
        messenger.subscribeAsync(to: .fileSystem_fileMetadataLoaded, handler: fileMetadataLoaded(_:))
        
        messenger.subscribe(to: .application_willExit, handler: onAppExit)
        
        TuneBrowserSidebarCategory.allCases.forEach {sidebarView.expandItem($0)}
        
        respondToSidebarSelectionChange = false
        selectMusicFolder()
        respondToSidebarSelectionChange = true
        
        fileSystem.root = FileSystemItem.create(forURL: FilesAndPaths.musicDir)
        pathControlWidget.url = tuneBrowserMusicFolderURL
    }
    
    private func onAppExit() {
        
        uiState.windowSize = theWindow.size
        uiState.sidebarWidth = sidebarView.width
        
        uiState.displayedColumns = browserView.tableColumns.filter {$0.isShown}.map {TuneBrowserTableColumn(id: $0.identifier.rawValue, width: $0.width)}
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        for item in menu.items {
            
            if let id = item.identifier {
                item.onIf(browserView.tableColumn(withIdentifier: id)?.isShown ?? false)
            }
        }
    }
    
    @IBAction func toggleColumnAction(_ sender: NSMenuItem) {
        
        // TODO: Validation - Don't allow 0 columns to be shown.
        
        if let id = sender.identifier {
            browserView.tableColumn(withIdentifier: id)?.isHidden.toggle()
        }
    }
    
    private func selectMusicFolder() {
        
        let foldersRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders)
        let musicFolderRow = foldersRow + 1
        sidebarView.selectRow(musicFolderRow)
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    private func fileMetadataLoaded(_ file: FileSystemItem) {
        
        DispatchQueue.main.async {
            self.browserView.reloadItem(file)
        }
        
        //        let itemIndex: Int = browserView.row(forItem: notif.file)
//        browserView.reloadRows([itemIndex], columns: )
    }
        
    @IBAction func doubleClickAction(_ sender: Any) {
        
        if let item = browserView.item(atRow: browserView.selectedRow), let fsItem = item as? FileSystemItem {
            
            if fsItem.isDirectory {
                openFolder(item: fsItem)
            } else {
                doAddBrowserItemsToPlaylist(indexes: IndexSet([browserView.selectedRow]), beginPlayback: true)
            }
        }
    }
    
    private func openFolder(item: FileSystemItem) {
        
        let path = item.url.path
        
        if !path.hasPrefix("/Volumes"), let volumeName = SystemUtils.primaryVolumeName {
            pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
        } else {
            pathControlWidget.url = item.url
        }
        
        fileSystem.root = item
        browserView.reloadData()
        browserView.scrollRowToVisible(0)
        
        updateSidebarSelection()
    }
    
    // If the folder currently shown by the browser corresponds to one of the folder shortcuts in the sidebar, select that
    // item in the sidebar.
    func updateSidebarSelection() {
        
        respondToSidebarSelectionChange = false
        
        if let folder = uiState.userFolder(forURL: fileSystem.rootURL) {
            sidebarView.selectRow(sidebarView.row(forItem: folder))
            
        } else if fileSystem.rootURL.equalsOneOf(FilesAndPaths.musicDir, tuneBrowserMusicFolderURL) {
            selectMusicFolder()
            
        } else {
            sidebarView.clearSelection()
        }
        
        respondToSidebarSelectionChange = true
    }
    
    @IBAction func pathControlAction(_ sender: Any) {
        
        if let item = pathControlWidget.clickedPathItem, let url = item.url, url != pathControlWidget.url {
            
            var path = url.path
            
            if !path.hasPrefix("/Volumes"), let volumeName = SystemUtils.primaryVolumeName {
                pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
            } else {
                pathControlWidget.url = url
            }
            
            // Remove /Volumes from URL before setting fileSystem.rootURL
            
            if let volumeName = SystemUtils.primaryVolumeName, path.hasPrefix("/Volumes/\(volumeName)") {
                path = path.replacingOccurrences(of: "/Volumes/\(volumeName)", with: "")
            }
            
            if path.hasSuffix("/") {
                fileSystem.rootURL = url
                
            } else {
                
                path += "/"
                fileSystem.rootURL = URL(fileURLWithPath: path)
            }
            
            browserView.reloadData()
            browserView.scrollRowToVisible(0)
            
            updateSidebarSelection()
        }
    }
    
    private var respondToSidebarSelectionChange: Bool = true
    
    private func sidebarSelectionChanged(_ selectedItem: TuneBrowserSidebarItem) {
        
        let path = selectedItem.url.path
        
        if !path.hasPrefix("/Volumes"), let volumeName = SystemUtils.primaryVolumeName {
            pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
        } else {
            pathControlWidget.url = selectedItem.url
        }
        
        fileSystem.root = FileSystemItem.create(forURL: selectedItem.url)
        browserView.reloadData()
        browserView.scrollRowToVisible(0)
    }
    
    @IBAction func addBrowserItemsToPlaylistAction(_ sender: Any) {
        doAddBrowserItemsToPlaylist(indexes: browserView.selectedRowIndexes)
    }
    
    // TODO: Clarify this use case (which items qualify for this) ?
    @IBAction func addBrowserItemsToPlaylistAndPlayAction(_ sender: Any) {
        doAddBrowserItemsToPlaylist(indexes: browserView.selectedRowIndexes, beginPlayback: true)
    }
    
    // TODO: If some of these items already exist, playback won't begin.
    // Need to modify playlist to always play the first item.
    private func doAddBrowserItemsToPlaylist(indexes: IndexSet, beginPlayback: Bool = false) {
        
        let selItemURLs = indexes.compactMap {[weak browserView] in browserView?.item(atRow: $0) as? FileSystemItem}.map {$0.url}
        
        playlist.addFiles(selItemURLs, beginPlayback: beginPlayback)
    }
    
    @IBAction func addSidebarShortcutAction(_ sender: Any) {
        
        if let clickedItem: FileSystemItem = browserView.rightClickedItem as? FileSystemItem {
            
            uiState.addUserFolder(forURL: clickedItem.url)
            
            sidebarView.insertItems(at: IndexSet(integer: uiState.sidebarUserFolders.count),
                                    inParent: TuneBrowserSidebarCategory.folders, withAnimation: .slideDown)
        }
    }
    
    @IBAction func removeSidebarShortcutAction(_ sender: Any) {
        
        if let clickedItem: TuneBrowserSidebarItem = sidebarView.rightClickedItem as? TuneBrowserSidebarItem,
           let removedItemIndex = uiState.removeUserFolder(item: clickedItem) {
            
            let musicFolderRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders) + 1
            let selectedRow = sidebarView.selectedRow
            let selectedItemRemoved = selectedRow == (musicFolderRow + removedItemIndex + 1)
            
            sidebarView.removeItems(at: IndexSet([removedItemIndex + 1]),
                                    inParent: TuneBrowserSidebarCategory.folders, withAnimation: .effectFade)
            
            if selectedItemRemoved {
                
                let foldersRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders)
                let musicFolderRow = foldersRow + 1
                sidebarView.selectRow(musicFolderRow)
            }
        }
    }
    
    @IBAction func showBrowserItemInFinderAction(_ sender: Any) {
        
        if let selItem = browserView.rightClickedItem as? FileSystemItem {
            selItem.url.showInFinder()
        }
    }
    
    @IBAction func showSidebarShortcutInFinderAction(_ sender: Any) {
        
        if let selItem = sidebarView.rightClickedItem as? TuneBrowserSidebarItem {
            selItem.url.showInFinder()
        }
    }
        
    @IBAction func closeAction(_ sender: Any) {
        self.window?.close()
    }
}
