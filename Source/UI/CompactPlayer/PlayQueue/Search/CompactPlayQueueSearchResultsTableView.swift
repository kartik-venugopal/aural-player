//
//  CompactPlayQueueSearchResultsTableView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayQueueSearchResultsTableView: AuralTableView {
    
    @IBOutlet weak var btnPlay: NSButton!
    @IBOutlet weak var btnBox: NSBox!
    
    private var cellShowingPlayButton: CompactPlayQueueSearchResultIndexCell?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        colorSchemesManager.registerSchemeObserver(self)
    }
    
    func reset() {
        
        btnBox.hide()
        
        cellShowingPlayButton = nil
        stopTracking()
    }
    
    func searchUpdated() {
        btnBox.hide()
    }
    
    private var lastScrollEventTime: Double = 0
    private static let minTimeIntervalBetweenButtonHideAndShow: Double = 0.125
    
    override func scrollWheel(with event: NSEvent) {
        
        super.scrollWheel(with: event)
        
        btnBox.hide()
        
        lastScrollEventTime = CFAbsoluteTimeGetCurrent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.minTimeIntervalBetweenButtonHideAndShow) {
            
            let timePassedBetweenEvents = (CFAbsoluteTimeGetCurrent() - self.lastScrollEventTime) > Self.minTimeIntervalBetweenButtonHideAndShow
            
            if timePassedBetweenEvents, let window = self.window {
                self.showAtLocation(window.mouseLocationOutsideOfEventStream)
            }
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        super.mouseMoved(with: event)
        showAtLocation(event.locationInWindow)
    }
    
    private func showAtLocation(_ location: NSPoint) {
        
        cellShowingPlayButton = nil
        btnBox.hide()
        
        // If no results displayed, do nothing
        guard numberOfRows > 0 else {return}
        
        let row = row(at: self.convert(location, from: nil))
        
        guard let cell = cellForRow(row),
              let rowView = view(atColumn: 0, row: row, makeIfNecessary: false) else {return}
        
        let rowHeight = rowView.height / 2
        let btnHeight = btnBox.height / 2
        
        guard let containerView = self.enclosingScrollView?.superview else {return}
        
        let scrollViewX = self.enclosingScrollView!.frame.minX
        
        var btnLocationInContainerView = containerView.convert(NSMakePoint(rowView.frame.minX,
                                                                           rowView.frame.minY + rowHeight - btnHeight - 1),
                                                               from: rowView)
        
        btnLocationInContainerView.x -= scrollViewX
        
        let contViewFrame = enclosingScrollView!.frame
        let boxRect = NSRect(origin: btnLocationInContainerView, size: btnBox.size)
        
        guard NSContainsRect(contViewFrame, boxRect) else {return}
        
        btnBox.fillColor = systemColorScheme.backgroundColor
        btnPlay.contentTintColor = systemColorScheme.activeControlColor
        
        btnBox.setFrameOrigin(btnLocationInContainerView)
        btnBox.bringToFront()
        btnBox.show()
        
        cellShowingPlayButton = cell
    }
    
    @IBAction func playResultAction(_ sender: NSButton) {
        cellShowingPlayButton?.playSearchResult()
    }
    
    private func cellForRow(_ row: Int) -> CompactPlayQueueSearchResultIndexCell? {
        
        guard row >= 0 else {return nil}
        return view(atColumn: 0, row: row, makeIfNecessary: false) as? CompactPlayQueueSearchResultIndexCell
    }
}

extension CompactPlayQueueSearchResultsTableView: ColorSchemeObserver {
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        btnPlay.contentTintColor = systemColorScheme.activeControlColor
    }
}
