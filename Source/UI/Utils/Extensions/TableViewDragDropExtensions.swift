//
//  TableViewDragDropExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

extension NSPasteboard {
    
    // Helper to set / retrieve source indexes to / from the NSDraggingInfo pasteboard.
    var sourceIndexes: IndexSet? {
        
        get {
            data as? IndexSet
        }
        
        set {
            data = newValue
        }
    }
    
    var data: Any? {
        
        get {
            
            if let data = pasteboardItems?.first?.data(forType: .data) {
                return NSKeyedUnarchiver.unarchiveObject(with: data)
//                return NSKeyedUnarchiver.unarchivedObject(ofClass: NSObject.self, from: data)
            }
            
            return nil
        }
        
        set {
            
            guard let theData = newValue else {return}
            
            let data = NSKeyedArchiver.archivedData(withRootObject: theData)
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
    
    var data: Any? {
        draggingPasteboard.data
    }
    
    var urls: [URL]? {
        draggingPasteboard.readObjects(forClasses: [NSURL.self]) as? [URL]
    }
}

extension NSPasteboard.PasteboardType {

    // Enables drag/drop reordering of playlist rows
    static let data: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: String(kUTTypeData))
    
    // Enables drag/drop adding of tracks into the playlist from Finder
    static let fileURL: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: String(kUTTypeFileURL))
}
