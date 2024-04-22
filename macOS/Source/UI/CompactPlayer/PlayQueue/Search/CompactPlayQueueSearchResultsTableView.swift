//
//  CompactPlayQueueSearchResultsTableView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayQueueSearchResultsTableView: AuralTableView {
    
    @IBOutlet weak var btnPlay: NSButton!
    
    private var cellShowingPlayButton: CompactPlayQueueSearchResultIndexCell?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        colorSchemesManager.registerSchemeObserver(self)
    }
    
    func reset() {
        
        btnPlay.hide()
        cellShowingPlayButton = nil
        stopTracking()
    }
    
    override func scrollWheel(with event: NSEvent) {
        
        super.scrollWheel(with: event)
        btnPlay.hide()
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        super.mouseMoved(with: event)
        
        cellShowingPlayButton = nil
        btnPlay.hide()
        
        // If no results displayed, do nothing
        guard numberOfRows > 0 else {return}
        
        let row = row(at: self.convert(event.locationInWindow, from: nil))
        guard let cell = cellForRow(row),
              let rowView = view(atColumn: 0, row: row, makeIfNecessary: false) else {return}
        
        let rowHeight = rowView.height / 2
        let btnHeight = btnPlay.height / 2
        let firstColumnWidth = tableColumns.first!.width / 2
        let btnWidth = btnPlay.width / 2
        
        guard let containerView = self.enclosingScrollView?.superview else {return}
        
        let btnLocationInContainerView = containerView.convert(NSMakePoint(rowView.frame.minX + firstColumnWidth - btnWidth - 2,
                                                                           rowView.frame.minY + rowHeight - btnHeight - 3),
                                                               from: rowView)
        
        btnPlay.contentTintColor = systemColorScheme.activeControlColor
        btnPlay.setFrameOrigin(btnLocationInContainerView)
        btnPlay.bringToFront()
        btnPlay.show()
        
        cellShowingPlayButton = cell
    }
    
    @IBAction func playResultAction(_ sender: NSButton) {
        cellShowingPlayButton?.playSearchResult()
    }
    
    private func cellForRow(_ row: Int) -> CompactPlayQueueSearchResultIndexCell? {
        
        guard row >= 0,
              let cell = view(atColumn: 0, row: row, makeIfNecessary: false) as? CompactPlayQueueSearchResultIndexCell else {
            
            return nil
        }
        
        return cell
    }
}

extension CompactPlayQueueSearchResultsTableView: ColorSchemeObserver {
    
    override func colorSchemeChanged() {
        btnPlay.contentTintColor = systemColorScheme.activeControlColor
    }
}
