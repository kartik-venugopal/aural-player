//
//  StringInputPopoverViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    View controller for the popover that lets the user save an Equalizer preset
 */
import Cocoa

class StringInputPopoverViewController: NSViewController, ModalComponentProtocol, Destroyable {
    
    // The actual popover that is shown
    private var popover: NSPopover!
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    
    // Input fields
    @IBOutlet weak var lblPrompt: NSTextField!
    @IBOutlet weak var inputField: ColoredCursorTextField!
    
    // Error message fields
    @IBOutlet weak var errorBox: NSBox!
    @IBOutlet weak var lblError: NSTextField!
    
    @IBOutlet weak var saveBtn: NSButton!
    @IBOutlet weak var cancelBtn: NSButton!
    
    @IBOutlet weak var saveBtnCell: StringInputPopoverResponseButtonCell!
    @IBOutlet weak var cancelBtnCell: StringInputPopoverResponseButtonCell!
    
    // A callback object so that the string input can be validated without this class knowing the logic for doing so
    private var client: StringInputReceiver!
    
    override var nibName: String? {"StringInputPopover"}
    
    private static var createdInstances: [StringInputPopoverViewController] = []
    
    static func create(_ client: StringInputReceiver) -> StringInputPopoverViewController {
        
        let controller = StringInputPopoverViewController()
        controller.client = client
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller
        
        controller.popover = popover
        createdInstances.append(controller)
        
        return controller
    }
    
    static var isShowingAPopover: Bool {
        createdInstances.contains(where: {$0.isShown})
    }
    
    static func destroy() {
        createdInstances.removeAll()
    }
    
    var isModal: Bool {isShown}
    
    // Shows the popover
    func show(_ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        if !isShown {
            
            initFields()
            popover.show(relativeTo: positioningRect, of: relativeToView, preferredEdge: preferredEdge)
            initFields()
            
            errorBox.hide()
        }
    }
    
    private func initFields() {
        
        // TODO: Resize/realign fields and popover per input text length !!!
        let font = Fonts.stringInputPopoverFont
        lblPrompt?.font = font
        inputField?.font = font
        
        saveBtn?.redraw()
        cancelBtn?.redraw()
        
        lblError?.font = Fonts.stringInputPopoverErrorFont
        
        // Initialize the fields with information from the client
        lblPrompt?.stringValue = client.inputPrompt
        inputField?.stringValue = client.defaultValue ?? ""
        inputField?.currentEditor()?.selectedRange = NSMakeRange(0, 0)
    }
    
    // Closes the popover
    func close() {
        
        if isShown {
            popover.performClose(self)
        }
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        
        // Validate input by calling back to the client
        let validation = client.validate(inputField.stringValue)
        
        if !validation.valid {
            
            lblError.stringValue = validation.errorMsg ?? ""
            errorBox.show()
            
        } else {
            
            client.acceptInput(inputField.stringValue)
            self.close()
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.close()
    }
    
    var isShown: Bool {popover.isShown}
}
