//
//  TrackPeekingButton.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

protocol TrackPeekingButtonProtocol {
    
    var toolTipFunction: (() -> String?)? {get set}
    
    var defaultTooltip: String! {get}
}

/*
    A "smart" button that determines and sets its own tool tip dynamically based on logic (closure) that can be set externally. Useful when tool tips need to change based on app state, e.g. to display the previous/next track name in a tool tip for the previous/next track control buttons.
 */
@IBDesignable
class TrackPeekingButton: TintedImageButton, TrackPeekingButtonProtocol, NSViewToolTipOwner {
    
    @IBInspectable var defaultTooltip: String!
    
    // This function will be invoked, on the fly (when the user hovers over the button), to determine the button's tool tip
    var toolTipFunction: (() -> String?)?
    
    private lazy var messenger: Messenger = .init(for: self)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        addToolTip(self.bounds, owner: self, userData: nil)
    }
    
    func view(_ view: NSView, stringForToolTip tag: NSView.ToolTipTag, point: NSPoint, userData data: UnsafeMutableRawPointer?) -> String {
        
        toolTipFunction?() ?? defaultTooltip
    }
}

@IBDesignable
class FillableImageTrackPeekingButton: FillableImageButton, TrackPeekingButtonProtocol {
    
    @IBInspectable var defaultTooltip: String!
    
    // This function will be invoked, on the fly (when the user hovers over the button), to determine the button's tool tip
    var toolTipFunction: (() -> String?)?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Create a tracking area that covers the bounds of the view. It should respond whenever the mouse enters or exits.
        addTrackingArea(NSTrackingArea(rect: self.bounds, options: [NSTrackingArea.Options.activeAlways, NSTrackingArea.Options.mouseEnteredAndExited], owner: self, userInfo: nil))
        
        self.updateTrackingAreas()
    }
    
    func updateTooltip() {
        self.toolTip = toolTipFunction?() ?? defaultTooltip
    }
    
    override func mouseEntered(with event: NSEvent) {
        
        super.mouseEntered(with: event)
        updateTooltip()
    }
}
