//
//  LibrarySidebarViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibrarySidebarViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"LibrarySidebar"}
    
    @IBOutlet weak var sidebarView: NSOutlineView!
    
    let categories: [LibrarySidebarCategory] = LibrarySidebarCategory.allCases
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    var respondToSelectionChange: Bool = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        categories.forEach {sidebarView.expandItem($0)}
        sidebarView.selectRow(1)
        
        messenger.subscribe(to: .Library.Sidebar.addFileSystemShortcut, handler: addFileSystemShortcut)
        
        // TODO: This is inefficient!!! Wait till library is built before doing this.
        messenger.subscribeAsync(to: .Library.doneAddingTracks) {[weak self] in
            
            self?.sidebarView.reloadItem(LibrarySidebarCategory.tuneBrowser)
            self?.sidebarView.expandItem(LibrarySidebarCategory.tuneBrowser)
        }
        
        messenger.subscribe(to: .tuneBrowser_displayedFolderChanged, handler: displayedFolderChanged(_:))
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: backgroundColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor, \.buttonColor],
                                                     handler: textColorOrButtonColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primarySelectedTextColor,
                                                     handler: selectedTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.textSelectionColor,
                                                     handler: textSelectionColorChanged(_:))
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        categories.forEach {sidebarView.expandItem($0)}
        sidebarView.selectRow(1)
    }
    
    @IBAction func doubleClickAction(_ sender: NSOutlineView) {
        
        guard let sidebarItem = sidebarView.selectedItem as? LibrarySidebarItem else {return}
        
        switch sidebarItem.browserTab {
            
        case .fileSystem:
            
            if let folder = sidebarItem.tuneBrowserFolder {
                playQueueDelegate.enqueueToPlayNow(fileSystemItems: [folder], clearQueue: false)
            }
            
        default:
            
            return
        }
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    @IBAction func createEmptyPlaylistAction(_ sender: Any) {
        
        playlistsManager.createNewPlaylist(named: uniquePlaylistName)
        let numPlaylists = playlistsManager.numberOfUserDefinedObjects
        
        sidebarView.insertItems(at: IndexSet(integer: numPlaylists - 1), inParent: LibrarySidebarCategory.playlists, withAnimation: .effectGap)
        
        sidebarView.reloadItem(LibrarySidebarCategory.playlists)
        sidebarView.expandItem(LibrarySidebarCategory.playlists)
        
        let playlistCategoryIndex = sidebarView.row(forItem: LibrarySidebarCategory.playlists)
        
        let indexOfNewPlaylist = playlistCategoryIndex + numPlaylists
        
        sidebarView.selectRow(indexOfNewPlaylist)
        editTextField(inRow: indexOfNewPlaylist)
    }
    
    private func editTextField(inRow row: Int) {
        
        let rowView = sidebarView.rowView(atRow: row, makeIfNecessary: true)
        
        if let editedTextField = (rowView?.view(atColumn: 0) as? NSTableCellView)?.textField {
            view.window?.makeFirstResponder(editedTextField)
        }
    }
    
    private var uniquePlaylistName: String {
        
        var newPlaylistName: String = "New Playlist"
        var ctr: Int = 1
        
        while playlistsManager.userDefinedObjectExists(named: newPlaylistName) {
            
            ctr.increment()
            newPlaylistName = "New Playlist \(ctr)"
        }
        
        return newPlaylistName
    }
    
    private func addFileSystemShortcut() {
        
        sidebarView.insertItems(at: IndexSet(integer: tuneBrowserUIState.sidebarUserFolders.count),
                                inParent: LibrarySidebarCategory.tuneBrowser, withAnimation: .slideDown)
    }
    
    private func displayedFolderChanged(_ newLocation: FileSystemFolderLocation) {
        
        let tbItems = LibrarySidebarCategory.tuneBrowser.items
        
        for item in tbItems {
            
            if item.tuneBrowserFolder == newLocation.folder {
                
                sidebarView.selectItems([item])
                return
            }
        }
        
        sidebarView.clearSelection()
    }
}

extension LibrarySidebarViewController: FontSchemeObserver, ColorSchemeObserver {
    
    func fontSchemeChanged() {
        sidebarView.reloadDataMaintainingSelection()
    }
    
    func fontChanged(to newFont: NSFont, forProperty property: KeyPath<FontScheme, NSFont>) {
        sidebarView.reloadDataMaintainingSelection()
    }
    
    func colorSchemeChanged() {
        
        sidebarView.setBackgroundColor(systemColorScheme.backgroundColor)
        sidebarView.reloadDataMaintainingSelection()
    }
    
    func backgroundColorChanged(_ newColor: NSColor) {
        sidebarView.setBackgroundColor(systemColorScheme.backgroundColor)
    }
    
    func textColorOrButtonColorChanged(_ newColor: NSColor) {
        sidebarView.reloadDataMaintainingSelection()
    }
    
    func selectedTextColorChanged(_ newColor: NSColor) {
        sidebarView.reloadRows(sidebarView.selectedRowIndexes)
    }
    
    func textSelectionColorChanged(_ newColor: NSColor) {
        sidebarView.redoRowSelection()
    }
}

extension LibrarySidebarViewController: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        let playlistCategoryRow = sidebarView.row(forItem: LibrarySidebarCategory.playlists)
        let rowOfPlaylist = sidebarView.selectedRow
        let indexOfPlaylist = rowOfPlaylist - playlistCategoryRow - 1
        
        guard let editedTextField = obj.object as? NSTextField else {return}
        
        let playlist = playlistsManager.userDefinedObjects[indexOfPlaylist]
        let oldPlaylistName = playlist.name
        let newPlaylistName = editedTextField.stringValue
        
        // No change in playlist name. Nothing to be done.
        if newPlaylistName == oldPlaylistName {return}
        
        editedTextField.textColor = systemColorScheme.primaryTextColor
        
        // If new name is empty or a playlist with the new name exists, revert to old value.
        if newPlaylistName.isEmptyAfterTrimming {
            
            editedTextField.stringValue = playlist.name
            
            _ = DialogsAndAlerts.genericErrorAlert("Can't rename playlist", "Playlist name must have at least one non-whitespace character.", "Please type a valid name.").showModal()
            
        } else if playlistsManager.userDefinedObjectExists(named: newPlaylistName) {
            
            editedTextField.stringValue = playlist.name
            
            _ = DialogsAndAlerts.genericErrorAlert("Can't rename playlist", "Another playlist with that name already exists.", "Please type a unique name.").showModal()
            
        } else {
            
            playlistsManager.renameObject(named: oldPlaylistName, to: newPlaylistName)
            messenger.publish(PlaylistRenamedNotification(index: indexOfPlaylist, newName: newPlaylistName))
            
            if let sidebarItem = sidebarView.item(atRow: rowOfPlaylist) as? LibrarySidebarItem {
                sidebarItem.displayName = newPlaylistName
            }
            
//            playlistViewController.playlist = playlist
        }
    }
}
