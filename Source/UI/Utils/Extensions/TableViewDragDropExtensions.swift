//
//  TableViewDragDropExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

extension NSPasteboard {
    
    // Helper to set / retrieve source indexes to / from the NSDraggingInfo pasteboard.
    var sourceIndexes: IndexSet? {
        
        get {
            object as? IndexSet
        }
        
        set {
            object = newValue
        }
    }
    
    fileprivate var object: Any? {
        
        get {
            
            guard let data = pasteboardItems?.first?.data(forType: .data) else {return nil}
            return NSKeyedUnarchiver.unarchiveObject(from: data)
        }
        
        set {
            
            guard let theData = newValue else {return}
            
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: theData, requiringSecureCoding: false) {
                
                let item = NSPasteboardItem()
                item.setData(data, forType: .data)
                writeObjects([item])
            }
        }
    }
}

extension NSDraggingInfo {
    
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

extension NSKeyedUnarchiver {
    
    static func unarchiveObject(from data: Data) -> Any? {
        
        guard let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: data) else {return nil}
        
        unarchiver.requiresSecureCoding = false
        return unarchiver.decodeObject()
    }
}
