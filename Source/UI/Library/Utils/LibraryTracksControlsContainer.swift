//
//  LibraryTracksControlsContainer.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryTracksControlsContainer: ControlsContainerView, ColorSchemeObserver {
    
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    @IBOutlet weak var btnImportTracks: TintedImageButton!
    
    @IBOutlet weak var btnRemoveTracks: TintedImageButton!
    @IBOutlet weak var btnCropTracks: TintedImageButton!
    @IBOutlet weak var btnRemoveAllTracks: TintedImageButton!
    
    @IBOutlet weak var btnClearSelection: TintedImageButton!
    @IBOutlet weak var btnInvertSelection: TintedImageButton!
    
    @IBOutlet weak var btnSearch: TintedImageButton!
    @IBOutlet weak var btnSort: NSPopUpButton!
    @IBOutlet weak var sortTintedIconMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var btnExport: TintedImageButton!
    
    @IBOutlet weak var btnPageUp: TintedImageButton!
    @IBOutlet weak var btnPageDown: TintedImageButton!
    @IBOutlet weak var btnScrollToTop: TintedImageButton!
    @IBOutlet weak var btnScrollToBottom: TintedImageButton!
    
    fileprivate lazy var buttonsToColor: [ColorSchemePropertyChangeReceiver] = [btnImportTracks, btnRemoveTracks, btnCropTracks, btnRemoveAllTracks,
                                                                                btnClearSelection, btnInvertSelection,
                                                                                btnSearch, sortTintedIconMenuItem,
                                                                                btnExport,
                                                                                btnPageUp, btnPageDown, btnScrollToTop, btnScrollToBottom]
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        viewsToShowOnMouseOver = [btnImportTracks,
                                  btnRemoveTracks, btnCropTracks, btnRemoveAllTracks,
                                  btnClearSelection, btnInvertSelection,
                                  btnSearch, btnSort,
                                  btnExport,
                                  btnPageUp, btnPageDown, btnScrollToTop, btnScrollToBottom]
        
        viewsToHideOnMouseOver = [lblTracksSummary, lblDurationSummary]
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: buttonsToColor)
    }
    
    func colorSchemeChanged() {
        
        buttonsToColor.forEach {
            $0.colorChanged(systemColorScheme.buttonColor)
        }
    }
}

class LibraryGroupedListControlsContainer: LibraryTracksControlsContainer {
    
    @IBOutlet weak var btnExpandAll: TintedImageButton!
    @IBOutlet weak var btnCollapseAll: TintedImageButton!
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var hoverControls: LibraryHoverControlsBox!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        viewsToShowOnMouseOver.append(contentsOf: [btnExpandAll, btnCollapseAll])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: [btnExpandAll, btnCollapseAll])
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        super.mouseMoved(with: event)
        
        // Show hover controls box (overlay).
        
        let row = outlineView.row(at: outlineView.convert(event.locationInWindow, from: nil))
        
        guard row >= 0,
              let rowView = outlineView.view(atColumn: 0, row: row, makeIfNecessary: false) else {
            
            hoverControls.hide()
            return
        }

        if let group = outlineView.item(atRow: row) as? Group {
            hoverControls.group = group
            
        } else if let playlist = outlineView.item(atRow: row) as? ImportedPlaylist {
            hoverControls.playlist = playlist
            
        } else {
            
            // Track
            hoverControls.hide()
            return
        }
        
        let boxHeight = hoverControls.height / 2
        let rowHeight = rowView.height / 2
        let lastColumnWidth = outlineView!.tableColumns.last!.width
        
        let conv = self.convert(NSMakePoint(rowView.frame.maxX, rowView.frame.minY + rowHeight - boxHeight - 5), from: rowView)
        hoverControls.setFrameOrigin(NSMakePoint(outlineView.frame.maxX - lastColumnWidth - hoverControls.width - 20, conv.y))
        hoverControls.show()
    }
    
    override func mouseExited(with event: NSEvent) {
        
        super.mouseExited(with: event)
        hoverControls.hide()
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        [btnExpandAll, btnCollapseAll].forEach {
            $0.colorChanged(systemColorScheme.buttonColor)
        }
    }
}
