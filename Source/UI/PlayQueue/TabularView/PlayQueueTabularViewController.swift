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
    
    override func viewWillDisappear() {
        
        super.viewWillDisappear()
        saveColumnsState()
    }
    
    private func restoreDisplayedColumns() {
        
        let displayedColumns = playQueueUIState.displayedColumns.values
        let displayedColumnIds: [String] = displayedColumns.map {$0.id}
        
        if displayedColumns.isEmpty {
            
            saveColumnsState()
            return
        }

        for column in tableView.tableColumns {
//            column.headerCell = LibraryTableHeaderCell(stringValue: column.headerCell.stringValue)
            column.isHidden = !displayedColumnIds.contains(column.identifier.rawValue)
        }

        for (index, columnId) in displayedColumnIds.enumerated() {

            let oldIndex = tableView.column(withIdentifier: NSUserInterfaceItemIdentifier(columnId))
            tableView.moveColumn(oldIndex, toColumn: index)
        }

        for column in displayedColumns {
            tableView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(column.id))?.width = column.width
        }
    }
    
    func saveColumnsState() {
        
        playQueueUIState.displayedColumns.removeAll()
        
        for column in tableView.tableColumns.filter({$0.isShown}) {
            
            let colID = column.identifier.rawValue
            playQueueUIState.displayedColumns[colID] = .init(id: colID, width: column.width)
        }
    }
    
    // MARK: Table view delegate / data source --------------------------------------------------------------------------------------------------------
    
    override func moveTracks(from sourceIndices: IndexSet, to destRow: Int) {
        
        super.moveTracks(from: sourceIndices, to: destRow)
        
        // Tell the other (sibling) table to refresh
        messenger.publish(.PlayQueue.refresh, payload: [PlayQueueView.expanded])
    }
    
    func tableView(_ tableView: NSTableView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
        tableView.tableColumns[columnIndex].identifier != .cid_index && newColumnIndex != 0
    }
    
    func tableViewColumnDidMove(_ notification: Notification) {
        saveColumnsState()
    }
    
    func tableViewColumnDidResize(_ notification: Notification) {
        saveColumnsState()
    }
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = trackList[row], let column = tableColumn?.identifier else {return nil}
        
        let builder = TableCellBuilder()
        
        switch column {
            
        case .cid_index:
            
            if track == playQueueDelegate.currentTrack {
                builder.withImage(image: .imgPlayFilled, inColor: systemColorScheme.activeControlColor)
                
            } else {
                builder.withText(text: "\(row + 1)",
                                        inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                        selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                        bottomYOffset: systemFontScheme.tableYOffset)
            }
            
        case .cid_fileName:
            builder.withPrimaryText(track.fileName)
            
        case .cid_title:
            builder.withPrimaryText(track.titleOrDefaultDisplayName)
            
        case .cid_artist:
            
            guard let artist = track.artist else {return nil}
            builder.withPrimaryText(artist)
            
        case .cid_album:
            
            guard let album = track.album else {return nil}
            builder.withPrimaryText(album)
            
        case .cid_genre:
            
            guard let genre = track.genre else {return nil}
            builder.withPrimaryText(genre)
            
        case .cid_trackNum:
            
            if let trackNum = track.trackNumber {

                if let totalTracks = track.totalTracks, totalTracks > 0 {
                    builder.withPrimaryText("\(trackNum) / \(totalTracks)")
                    
                } else if trackNum > 0 {
                    builder.withPrimaryText("\(trackNum)")
                    
                } else {
                    return nil
                }
                
            } else {
                return nil
            }
            
        case .cid_discNum:
            
            if let discNum = track.discNumber {
                
                if let totalDiscs = track.totalDiscs, totalDiscs > 0 {
                    builder.withPrimaryText("\(discNum) / \(totalDiscs)")
                    
                } else if discNum > 0 {
                    builder.withPrimaryText("\(discNum)")
                    
                } else {
                    return nil
                }
                
            } else {
                return nil
            }
            
        case .cid_year:
            
            guard let year = track.year else {return nil}
            builder.withPrimaryText("\(year)")
            
        case .cid_duration:
            
            builder.withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                    inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                    selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                    bottomYOffset: systemFontScheme.tableYOffset)
            
        case .cid_format:
            
            guard let format = track.audioInfo.format?.capitalizingFirstLetter() else {return nil}
            builder.withPrimaryText(format)
            
        case .cid_playCount:
            builder.withPrimaryText("\(historyDelegate.playCount(forTrack: track))")
            
        case .cid_playCount:
            builder.withPrimaryText("\(historyDelegate.playCount(forTrack: track))")
            
        default:
            return nil
        }
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: column, inRow: row)
    }
    
    fileprivate static let columnIDs: [NSUserInterfaceItemIdentifier] = [.cid_title, .cid_fileName, .cid_artist, .cid_album, .cid_genre, .cid_trackNum, .cid_discNum, .cid_year, .cid_duration, .cid_format, .cid_playCount, .cid_lastPlayed]
    
    @IBAction func toggleColumnAction(_ sender: NSMenuItem) {
        
        // TODO: Validation - Don't allow 0 columns to be shown.
        
        let index = sender.tag
        guard Self.columnIDs.indices.contains(index), let column = tableView.tableColumn(withIdentifier: Self.columnIDs[index]) else {return}
        
        column.isHidden.toggle()
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

fileprivate extension TableCellBuilder {
    
    func withPrimaryText(_ text: String) {
        
        withText(text: text,
                 inFont: systemFontScheme.normalFont, andColor: systemColorScheme.primaryTextColor,
                 selectedTextColor: systemColorScheme.primarySelectedTextColor,
                 bottomYOffset: systemFontScheme.tableYOffset)
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
