//
//  PlaylistContainer.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PlaylistContainer: NSBox {
    
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    @IBOutlet weak var btnExportPlaylist: TintedImageButton!
    
    @IBOutlet weak var btnAddTracks: TintedImageButton!
    @IBOutlet weak var btnRemoveTracks: TintedImageButton!
    @IBOutlet weak var btnClear: TintedImageButton!
    
    @IBOutlet weak var btnMoveTracksUp: TintedImageButton!
    @IBOutlet weak var btnMoveTracksDown: TintedImageButton!
    
    @IBOutlet weak var btnSearch: TintedImageButton!
    @IBOutlet weak var btnSort: TintedImageButton!
    
    @IBOutlet weak var btnPageUp: TintedImageButton!
    @IBOutlet weak var btnPageDown: TintedImageButton!
    @IBOutlet weak var btnScrollToTop: TintedImageButton!
    @IBOutlet weak var btnScrollToBottom: TintedImageButton!
    
    private var viewsToShowOnMouseOver: [NSView] = []
    private var viewsToHideOnMouseOver: [NSView] = []
    
    override func awakeFromNib() {
        
        viewsToShowOnMouseOver = [btnExportPlaylist, btnAddTracks,
                                  btnRemoveTracks, btnClear, btnMoveTracksUp, btnMoveTracksDown, btnSearch, btnSort,
                                  btnPageUp, btnPageDown, btnScrollToTop, btnScrollToBottom]
        
        viewsToHideOnMouseOver = [lblTracksSummary, lblDurationSummary]
    }
    
    override func viewDidEndLiveResize() {
        
        super.viewDidEndLiveResize()
        
        self.removeAllTrackingAreas()
        self.updateTrackingAreas()

        viewsToShowOnMouseOver.forEach {$0.hide()}
        viewsToHideOnMouseOver.forEach {$0.show()}
    }
    
    // Signals the view to start tracking mouse movements.
    func startTracking() {
        
        self.removeAllTrackingAreas()
        self.updateTrackingAreas()
    }
    
    // Signals the view to stop tracking mouse movements.
    func stopTracking() {
        self.removeAllTrackingAreas()
    }
    
    override func updateTrackingAreas() {
        
        // Create a tracking area that covers the bounds of the view. It should respond whenever the mouse enters or exits.
        addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.activeAlways, .mouseEnteredAndExited],
                                       owner: self, userInfo: nil))
        
        super.updateTrackingAreas()
    }
    
    override func mouseEntered(with event: NSEvent) {
        
        viewsToShowOnMouseOver.forEach {$0.show()}
        viewsToHideOnMouseOver.forEach {$0.hide()}
    }
    
    override func mouseExited(with event: NSEvent) {
        
        viewsToShowOnMouseOver.forEach {$0.hide()}
        viewsToHideOnMouseOver.forEach {$0.show()}
    }
}
