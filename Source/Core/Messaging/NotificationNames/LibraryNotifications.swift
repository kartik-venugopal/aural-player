//
//  LibraryNotifications.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension Notification.Name {
    
    struct Library {
        
        // MARK: Notifications published by the library.
        
        // Signifies that the library has begun reading the home folder in the file system, but has not yet started reading metadata
        // from the individual files / playlists.
        static let startedReadingFileSystem = Notification.Name("library_startedReadingFileSystem")
        
        // Signifies that the library has begun adding a set of tracks.
        static let startedAddingTracks = Notification.Name("library_startedAddingTracks")
        
        // Signifies that the library has finished adding a set of tracks.
        static let doneAddingTracks = Notification.Name("library_doneAddingTracks")
        
        // Signifies that some chosen tracks could not be added to the library (i.e. an error condition).
        static let tracksNotAdded = Notification.Name("library_tracksNotAdded")
        
        // Signifies that new tracks have been added to the library.
        static let tracksAdded = Notification.Name("library_tracksAdded")
        
        static let tracksRemoved = Notification.Name("library_tracksRemoved")
        
        static let tracksDragDropped = Notification.Name("library_tracksDragDropped")
        
        static let sorted = Notification.Name("library_sorted")
        
        // Signifies that the summary for the library needs to be updated.
        static let updateSummary = Notification.Name("library_updateSummary")
        
        // Signifies that the summary for the library needs to be updated.
        static let reloadTable = Notification.Name("library_reloadTable")
        
        // Command to show a specific Library browser tab (specified in the payload).
        static let showBrowserTabForItem = Notification.Name("library_showBrowserTabForItem")
        
        // Command to show a specific Library browser tab (specified in the payload).
        static let showBrowserTabForCategory = Notification.Name("library_showBrowserTabForCategory")
        
        struct Sidebar {
            
            // Command to show a specific Library browser tab (specified in the payload).
            static let addFileSystemShortcut = Notification.Name("library_sidebar_addFileSystemShortcut")
        }
    }
}
