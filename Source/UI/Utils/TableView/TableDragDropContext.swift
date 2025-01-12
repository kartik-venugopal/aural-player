//
//  TableDragDropContext.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class TableDragDropContext {

    static var indices: IndexSet?
    static var data: Any?
    
    static var sourceTable: NSTableView?
    
    private static let dummyObject: [URL] = []
    
    static func reset() {
        
        indices = nil
        data = nil
        sourceTable = nil
    }
    
    static func setIndicesAndData(_ indices: IndexSet, _ data: Any, from sourceTable: NSTableView, pasteboard: NSPasteboard) {
        
        // Do this to prevent the pasteboard from complaining when dragging / dropping.
        pasteboard.sourceIndexes = indices
        
        Self.indices = indices
        Self.data = data
        Self.sourceTable = sourceTable
    }
    
    static func setData(_ data: Any, from sourceTable: NSTableView, pasteboard: NSPasteboard) {
        
        // Do this to prevent the pasteboard from complaining when dragging / dropping.
        pasteboard.sourceIndexes = .empty
        
        Self.data = data
        Self.sourceTable = sourceTable
    }
}
