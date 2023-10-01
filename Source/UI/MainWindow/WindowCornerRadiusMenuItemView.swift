//
//  WindowCornerRadiusMenuItemView.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowCornerRadiusMenuItemView: NSView {
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    
    @IBOutlet weak var lblCornerRadiusCaption: NSTextField!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    private lazy var messenger = Messenger(for: self)
    
    private lazy var uiState: WindowAppearanceState = objectGraph.windowAppearanceState
    
    override func awakeFromNib() {
        
        if lblCornerRadiusCaption != nil {
            [lblCornerRadius, lblCornerRadiusCaption].forEach {$0.font = .menuFont}
        }
    }
    
    @IBAction func cornerRadiusStepperAction(_ sender: NSStepper) {
        
        uiState.cornerRadius = CGFloat(cornerRadiusStepper.integerValue)
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue) px"
        
        messenger.publish(.windowAppearance_changeCornerRadius, payload: uiState.cornerRadius)
    }
}
