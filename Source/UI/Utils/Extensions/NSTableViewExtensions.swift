//
//  NSTableViewExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSTableView {
    
    func enableDragDrop() {
        registerForDraggedTypes([.data, .fileURL])
    }
    
    func setBackgroundColor(_ color: NSColor) {
        
        backgroundColor = color
        enclosingScrollView?.backgroundColor = color
        
        if let clipView = enclosingScrollView?.documentView as? NSClipView {
            clipView.backgroundColor = color
        }
    }
    
    var numberOfVisibleColumns: Int {
        tableColumns.filter {$0.isShown}.count
    }
    
    func isRowSelected(_ row: Int) -> Bool {
        selectedRowIndexes.contains(row)
    }
    
    func selectRow(_ row: Int) {
        selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
    }
    
    func selectRows(_ rows: [Int]) {
        selectRowIndexes(IndexSet(rows), byExtendingSelection: false)
    }
    
    func selectRows(_ rows: IndexSet) {
        selectRowIndexes(rows, byExtendingSelection: false)
    }
    
    func redoRowSelection() {

        // Note down the selected rows, clear the selection, and re-select the originally selected rows
        // (to trigger a repaint of the selection boxes).
        
        let selRows = selectedRowIndexes
        
        if !selRows.isEmpty {
            
            selectRowIndexes(IndexSet([]), byExtendingSelection: false)
            selectRowIndexes(selRows, byExtendingSelection: false)
        }
    }
    
    func selectRows(_ rows: Range<Int>) {
        selectRowIndexes(IndexSet(rows), byExtendingSelection: false)
    }
    
    func selectRows(_ rows: ClosedRange<Int>) {
        selectRowIndexes(IndexSet(rows), byExtendingSelection: false)
    }
    
    func selectAllItems() {
        selectRowIndexes(allRowIndices, byExtendingSelection: false)
    }
    
    func clearSelection() {
        selectRowIndexes(IndexSet([]), byExtendingSelection: false)
    }
    
    func invertSelection() {
        selectRowIndexes(invertedSelection, byExtendingSelection: false)
    }
    
    var invertedSelection: IndexSet {
        IndexSet((0..<numberOfRows).filter {!selectedRowIndexes.contains($0)})
    }
    
    var allRowIndices: IndexSet {IndexSet(0..<numberOfRows)}
    
    var allColumnIndices: IndexSet {IndexSet(0..<numberOfColumns)}
    
    func reloadRows(_ rows: [Int]) {
        reloadData(forRowIndexes: IndexSet(rows), columnIndexes: allColumnIndices)
    }
    
    func reloadRows(_ rows: Range<Int>) {
        reloadData(forRowIndexes: IndexSet(rows), columnIndexes: allColumnIndices)
    }
    
    func reloadRows(_ rows: ClosedRange<Int>) {
        reloadData(forRowIndexes: IndexSet(rows), columnIndexes: allColumnIndices)
    }
    
    func reloadRows(_ rows: ClosedRange<Int>, columns: [Int]) {
        reloadData(forRowIndexes: IndexSet(rows), columnIndexes: IndexSet(columns))
    }
    
    func reloadRows(_ rows: IndexSet) {
        reloadData(forRowIndexes: rows, columnIndexes: allColumnIndices)
    }
    
    func reloadRows(_ rows: [Int], columns: [Int]) {
        reloadData(forRowIndexes: IndexSet(rows), columnIndexes: IndexSet(columns))
    }
    
    func reloadRows(_ rows: IndexSet, columns: [Int]) {
        reloadData(forRowIndexes: rows, columnIndexes: IndexSet(columns))
    }
    
    func reloadAllRows(columns: [Int]) {
        reloadData(forRowIndexes: allRowIndices, columnIndexes: IndexSet(columns))
    }
    
    func reloadDataMaintainingSelection() {
        
        let selectedRows = selectedRowIndexes
        reloadData()
        selectRowIndexes(selectedRows, byExtendingSelection: false)
    }
    
    func pageUp() {
        enclosingScrollView?.pageUp(self)
    }
    
    var heightOfARow: CGFloat {self.rect(ofRow: 0).height}
    
    func pageDown() {
        enclosingScrollView?.pageDown(self)
    }
    
    // Scrolls the playlist view to the very top
    func scrollToTop() {
        
        if numberOfRows > 0 {
            scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    func scrollToBottom() {
        
        if numberOfRows > 0 {
            scrollRowToVisible(numberOfRows - 1)
        }
    }
    
    func customizeHeader<C>(heightIncrease: CGFloat, customCellType: C.Type) where C: NSTableHeaderCell {
        
        guard let header = headerView else {return}
        
        header.resize(header.width, header.height + heightIncrease)
        
        if let clipView = enclosingScrollView?.documentView as? NSClipView {
            clipView.resize(clipView.width, clipView.height + heightIncrease)
        }
        
        header.wantsLayer = true
        header.layer?.backgroundColor = .black
        
        tableColumns.forEach {
            
            let col = $0
            let header = C.init()
            
            header.stringValue = col.headerCell.stringValue
            header.isBordered = false
            
            header.identifier = col.identifier
            col.headerCell = header
        }
    }
}

extension NSTableView: ColorSchemePropertyChangeReceiver {
    
    @objc func colorSchemeChanged() {
        
        setBackgroundColor(systemColorScheme.backgroundColor)
        reloadDataMaintainingSelection()
    }
    
    func colorChanged(_ newColor: NSColor) {
        setBackgroundColor(newColor)
    }
    
//    func colorChanged(to newColor: NSColor, forProperty property: ColorSchemeProperty) {
//        
//        switch property {
//            
//        case \.backgroundColor:
//            setBackgroundColor(newColor)
//            
//        case \.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor, \.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor:
//            reloadData()
//            
//        default:
//            return
//        }
//    }
}

extension NSOutlineView {
    
    func isItemSelected(_ item: Any) -> Bool {
        selectedRowIndexes.contains(row(forItem: item))
    }
    
    var selectedItem: Any? {
        item(atRow: selectedRow)
    }
    
    var selectedItems: [Any] {
        selectedRowIndexes.compactMap {item(atRow: $0)}
    }
    
//    var selectedFileSystemItems: [FileSystemItem] {
//        selectedItems.compactMap {$0 as? FileSystemItem}
//    }
//    
//    var selectedFileSystemItemURLs: [URL] {
//        selectedItems.compactMap {($0 as? FileSystemItem)?.url}
//    }
    
    func selectItems(_ items: [Any]) {
        selectRows(items.map {row(forItem: $0)})
    }
}
