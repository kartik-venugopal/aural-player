//
//  TableViewDragDropExtensions.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

extension NSPasteboard {
    
    // Helper to set / retrieve source indexes to / from the NSDraggingInfo pasteboard.
    var sourceIndexes: IndexSet? {
        
        get {
            
            if let data = pasteboardItems?.first?.data(forType: .data) {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? IndexSet
            }
            
            return nil
        }
        
        set {
            
            guard let indexSet = newValue else {return}
            
            let data = NSKeyedArchiver.archivedData(withRootObject: indexSet)
            let item = NSPasteboardItem()
            item.setData(data, forType: .data)
            writeObjects([item])
        }
    }
}

extension NSDraggingInfo {
    
    // Helper to set / retrieve source indexes to / from the NSDraggingInfo pasteboard.
    var sourceIndexes: IndexSet? {
        draggingPasteboard.sourceIndexes
    }
    
    var urls: [URL]? {
        draggingPasteboard.readObjects(forClasses: [NSURL.self]) as? [URL]
    }
}

extension NSPasteboard.PasteboardType {

    // Enables drag/drop reordering of playlist rows
    static let data: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: String(kUTTypeData))
    
    // Enables drag/drop adding of tracks into the playlist from Finder
    static let file_URL: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: String(kUTTypeFileURL))
}
