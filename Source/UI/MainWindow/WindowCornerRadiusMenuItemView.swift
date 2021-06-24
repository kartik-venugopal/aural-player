//
//  WindowCornerRadiusMenuItemView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowCornerRadiusMenuItemView: NSView {
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    @IBAction func cornerRadiusStepperAction(_ sender: NSStepper) {
        
        WindowAppearanceState.cornerRadius = CGFloat(cornerRadiusStepper.integerValue)
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue) px"
        
        Messenger.publish(.windowAppearance_changeCornerRadius, payload: WindowAppearanceState.cornerRadius)
    }
}
