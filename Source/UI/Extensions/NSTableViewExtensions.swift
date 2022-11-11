//
//  NSTableViewExtensions.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSTableView {
    
    func isRowSelected(_ row: Int) -> Bool {
        self.selectedRowIndexes.contains(row)
    }
    
    func selectRow(_ row: Int) {
        self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
    }
    
    func selectRows(_ rows: [Int]) {
        self.selectRowIndexes(IndexSet(rows), byExtendingSelection: false)
    }
    
    func selectRows(_ rows: IndexSet) {
        self.selectRowIndexes(rows, byExtendingSelection: false)
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
        self.selectRowIndexes(IndexSet(rows), byExtendingSelection: false)
    }
    
    func selectRows(_ rows: ClosedRange<Int>) {
        self.selectRowIndexes(IndexSet(rows), byExtendingSelection: false)
    }
    
    func clearSelection() {
        self.selectRowIndexes(IndexSet([]), byExtendingSelection: false)
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
        
        // Determine if the first row currently displayed has been truncated so it is not fully visible
        let visibleRect = self.visibleRect
        
        let firstRowShown = self.rows(in: visibleRect).lowerBound
        let firstRowShownRect = self.rect(ofRow: firstRowShown)
        
        let truncationAmount =  visibleRect.minY - firstRowShownRect.minY
        let truncationRatio = truncationAmount / firstRowShownRect.height
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page
        
        let lastRowToShow = truncationRatio > 0.1 ? firstRowShown : firstRowShown - 1
        let lastRowToShowRect = self.rect(ofRow: lastRowToShow)
        
        // Calculate the scroll amount, as a function of the last row to show next, using the visible rect origin (i.e. the top of the first row in the playlist) as the stopping point
        
        let scrollAmount = min(visibleRect.origin.y, visibleRect.maxY - lastRowToShowRect.maxY)
        
        if scrollAmount > 0 {
            
            let up = visibleRect.origin.applying(CGAffineTransform.init(translationX: 0, y: -scrollAmount))
            self.enclosingScrollView?.contentView.scroll(to: up)
        }
    }
    
    func pageDown() {
        
        // Determine if the last row currently displayed has been truncated so it is not fully visible
        let visibleRect = self.visibleRect
        let visibleRows = self.rows(in: visibleRect)
        
        let lastRowShown = visibleRows.lowerBound + visibleRows.length - 1
        let lastRowShownRect = self.rect(ofRow: lastRowShown)
        
        let lastRowInPlaylistRect = self.rect(ofRow: self.numberOfRows - 1)
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page
        
        let truncationAmount = lastRowShownRect.maxY - visibleRect.maxY
        let truncationRatio = truncationAmount / lastRowShownRect.height
        
        let firstRowToShow = truncationRatio > 0.1 ? lastRowShown : lastRowShown + 1
        let firstRowToShowRect = self.rect(ofRow: firstRowToShow)
        
        // Calculate the scroll amount, as a function of the first row to show next, using the visible rect maxY (i.e. the bottom of the last row in the playlist) as the stopping point

        let scrollAmount = min(firstRowToShowRect.origin.y - visibleRect.origin.y, lastRowInPlaylistRect.maxY - visibleRect.maxY)
        
        if scrollAmount > 0 {
            
            let down = visibleRect.origin.applying(CGAffineTransform.init(translationX: 0, y: scrollAmount))
            self.enclosingScrollView?.contentView.scroll(to: down)
        }
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
        
        guard let header = self.headerView else {return}
        
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
            
            col.headerCell = header
        }
    }
}

extension NSOutlineView {
    
    func isItemSelected(_ item: Any) -> Bool {
        self.selectedRowIndexes.contains(row(forItem: item))
    }
}
