//
//  PlayQueueTabularViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueTabularViewController: PlayQueueViewController {
    
    override var nibName: NSNib.Name? {"PlayQueueTabularView"}
    
    override var playQueueView: PlayQueueView {
        .tabular
    }
    
    override var rowHeight: CGFloat {30}
    
    @IBOutlet weak var coverBox: NSBox!
    @IBOutlet weak var coverBox2: NSBox!
    
    @IBOutlet weak var columnsMenu: NSMenu!
    private lazy var columnsMenuDelegate: PlayQueueTabularViewColumnsMenuDelegate = .init(tableView: tableView)
    
    var columnsRestored: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.customizeHeader(heightIncrease: 0, customCellType: PlayQueueTabularViewTableHeaderCell.self)
        columnsMenu.delegate = columnsMenuDelegate
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        DispatchQueue.main.async {
            self.restoreDisplayedColumns()
        }
    }
    
    private func restoreDisplayedColumns() {
        
        let displayedColumns = playQueueUIState.displayedColumns.values
        let displayedColumnIds: [String] = displayedColumns.map {$0.id}
        
        defer {tableView.sizeToFit()}
        
        if displayedColumns.isEmpty {
            
            columnsRestored = true
            saveColumnsState()
            return
        }

        for column in tableView.tableColumns {
            column.isHidden = !displayedColumnIds.contains(column.identifier.rawValue)
        }

        for (index, column) in displayedColumns.enumerated() {
            
            let colID = NSUserInterfaceItemIdentifier(column.id)
            
            let oldIndex = tableView.column(withIdentifier: colID)
            tableView.moveColumn(oldIndex, toColumn: index)
            
            tableView.tableColumn(withIdentifier: colID)?.width = column.width
        }
        
        columnsRestored = true
    }
    
    func saveColumnsState() {
        
        playQueueUIState.displayedColumns.removeAll()
        
        for column in tableView.tableColumns.filter({$0.isShown}) {
            
            let colID = column.identifier.rawValue
            playQueueUIState.displayedColumns[colID] = .init(id: colID, width: column.width)
        }
    }
    
    override func moveTracks(from sourceIndices: IndexSet, to destRow: Int) {
        
        super.moveTracks(from: sourceIndices, to: destRow)
        
        // Tell the other (sibling) tables to refresh
        messenger.publish(.PlayQueue.refresh, payload: [PlayQueueView.simple, PlayQueueView.expanded])
    }
    
    fileprivate static let columnIDs: [NSUserInterfaceItemIdentifier] = [.cid_title, .cid_fileName, .cid_artist, .cid_album, .cid_genre, .cid_trackNum, .cid_discNum, .cid_year, .cid_format, .cid_playCount, .cid_lastPlayed]
    
    @IBAction func toggleColumnAction(_ sender: NSMenuItem) {
        
        let index = sender.tag
        guard Self.columnIDs.indices.contains(index), let column = tableView.tableColumn(withIdentifier: Self.columnIDs[index]) else {return}
        
        column.isHidden.toggle()
        tableView.sizeToFit()
        
        saveColumnsState()
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        tableView.headerView?.redraw()
        coverBox.fillColor = systemColorScheme.backgroundColor
        coverBox2.fillColor = systemColorScheme.backgroundColor
    }
    
    override func initTheme() {
        
        super.initTheme()
        tableView.headerView?.redraw()
        coverBox.fillColor = systemColorScheme.backgroundColor
        coverBox2.fillColor = systemColorScheme.backgroundColor
    }
}

class PlayQueueTabularViewColumnsMenuDelegate: NSObject, NSMenuDelegate {
    
    let tableView: NSTableView
    
    init(tableView: NSTableView) {
        self.tableView = tableView
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        for item in menu.items {
            
            let index = item.tag
            
            if PlayQueueTabularViewController.columnIDs.indices.contains(index),
               let column = tableView.tableColumn(withIdentifier: PlayQueueTabularViewController.columnIDs[index]) {
                
                item.onIf(column.isShown)
            }
        }
    }
}
