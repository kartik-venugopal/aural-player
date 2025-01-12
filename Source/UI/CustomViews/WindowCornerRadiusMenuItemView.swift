//
//  WindowCornerRadiusMenuItemView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowCornerRadiusMenuItemView: NSView {
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    
    @IBOutlet weak var lblCornerRadiusCaption: NSTextField!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        [lblCornerRadius, lblCornerRadiusCaption].forEach {$0?.font = .menuFont}
    }
    
    @IBAction func cornerRadiusStepperAction(_ sender: NSStepper) {
        
        playerUIState.cornerRadius = CGFloat(cornerRadiusStepper.integerValue)
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
        
        Messenger.publish(.View.changeWindowCornerRadius, payload: playerUIState.cornerRadius)
    }
}
