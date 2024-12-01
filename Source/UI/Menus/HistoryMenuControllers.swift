//
//  HistoryMenuControllers.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

let menuItemCoverArtImageSize: NSSize = NSSize(width: 25, height: 25)

/*
    Manages and provides actions for the History menu that displays historical information about the usage of the app.
 */
class HistoryMenuController: NSObject, NSMenuDelegate {
    
    // Sub-menu that displays recently played tracks. Clicking on any of these items will result in the track being played.
    @IBOutlet weak var recentItemsMenu: NSMenu!
    
    @IBOutlet weak var resumeLastPlayedTrackItem: NSMenuItem!
    @IBOutlet weak var resumeShuffleSequenceItem: NSMenuItem!
    
    func menuWillOpen(_ menu: NSMenu) {
        
        recentItemsMenu.removeAllItems()
        
        // Retrieve the model and re-create all sub-menu items
        createChronologicalMenu(historyDelegate.allRecentItems, recentItemsMenu, self, #selector(self.playSelectedItemAction(_:)))
        
        let isStopped = player.state == .stopped
        
        resumeLastPlayedTrackItem.enableIf(isStopped && historyDelegate.canResumeLastPlayedTrack)
        resumeShuffleSequenceItem.enableIf(isStopped && historyDelegate.canResumeShuffleSequence)
    }
    
    // When a "Recently played" or "Favorites" menu item is clicked, the item is played
    @IBAction fileprivate func playSelectedItemAction(_ sender: HistoryMenuItem) {
        
        if let item = sender.historyItem {
            historyDelegate.playItem(item)
        }
    }
    
    @IBAction fileprivate func resumeLastPlayedTrackAction(_ sender: NSMenuItem) {
        
        do {
            
            try historyDelegate.resumeLastPlayedTrack()
            
        } catch {
            
            if let lastPlayedItem = historyDelegate.lastPlayedItem, let fnfError = error as? FileNotFoundError {
                
                // This needs to be done async. Otherwise, other open dialogs could hang.
                DispatchQueue.main.async {
                    
                    // Position and display an alert with error info
                    _ = DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove item").showModal()
                    historyDelegate.deleteItem(lastPlayedItem)
                }
            }
        }
    }
    
    @IBAction fileprivate func resumeShuffleSequenceAction(_ sender: NSMenuItem) {
        
        do {
            
            try historyDelegate.resumeShuffleSequence()
            
        } catch {
            
            if let lastPlayedItem = historyDelegate.lastPlayedItem, let fnfError = error as? FileNotFoundError {
                
                // This needs to be done async. Otherwise, other open dialogs could hang.
                DispatchQueue.main.async {
                    
                    // Position and display an alert with error info
                    _ = DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove item").showModal()
                    historyDelegate.deleteItem(lastPlayedItem)
                }
            }
        }
    }
    
    @IBAction fileprivate func clearHistoryAction(_ sender: NSMenuItem) {
        historyDelegate.clearAllHistory()
    }
}

// A menu item that stores an associated history item (used when executing the menu item action)
class HistoryMenuItem: NSMenuItem {
    var historyItem: HistoryItem!
}

// Factory method to create a single history menu item, given a model object (HistoryItem)
fileprivate func createHistoryMenuItem(_ item: HistoryItem, _ actionTarget: AnyObject, _ action: Selector) -> NSMenuItem {
    
    // The action for the menu item will depend on whether it is a playable item
    
    let menuItem = HistoryMenuItem(title: "  " + item.displayName, action: action)
    menuItem.target = actionTarget
    
    if let trackItem = item as? TrackHistoryItem {
        menuItem.image = trackItem.track.art?.downscaledOrOriginalImage ?? .imgPlayingArt
        
    } else if item is PlaylistFileHistoryItem {
        menuItem.image = .imgPlaylist
        
    } else if item is FolderHistoryItem {
        menuItem.image = .imgFileSystem
//        
//    } else if item is GroupHistoryItem {
//        menuItem.image = .imgGroup_menu
    }
    
    menuItem.image?.size = menuItemCoverArtImageSize
    menuItem.historyItem = item
    
    return menuItem
}

// Populates the given menu with items corresponding to the given historical item info, grouped by timestamp into categories like "Past 24 hours", "Past 7 days", etc.
fileprivate func createChronologicalMenu(_ items: [HistoryItem], _ menu: NSMenu, _ actionTarget: AnyObject, _ action: Selector) {
    
    // Keeps track of which time categories have already been created
    var timeCategories = Set<TimeElapsed>()
    
    for item in items {
        
        let menuItem = createHistoryMenuItem(item, actionTarget, action)
        
        // Figure out how old this item is
        let timeElapsed = Date.timeElapsedSince(item.lastEventTime)
        
        // If this category doesn't already exist, create it
        if !timeCategories.contains(timeElapsed) {
            
            timeCategories.insert(timeElapsed)
            
            // Add a descriptor menu item that describes the time category, between 2 separators
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem.createDescriptor(title: timeElapsed.rawValue))
            menu.addItem(NSMenuItem.separator())
        }
        
        // Add the history menu item to the menu
        menu.addItem(menuItem)
    }
}
