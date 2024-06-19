//
//  FontSizeStepper.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

///
/// A specialized stepper control that makes it convenient to get / set a font size
/// based on the stepper's value.
///
class FontSizeStepper: NSStepper {
    
    @IBOutlet weak var lblValue: NSTextField!
    
    var fontSize: CGFloat {
        
        get {CGFloat(floatValue / 10)}
        
        set {
            floatValue = Float(newValue * 10)
            lblValue.stringValue = String(format: "%.1f", newValue)
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.action = #selector(self.stepperAction(_:))
        self.target = self
    }

    @IBAction func stepperAction(_ sender: NSStepper) {
        lblValue.stringValue = String(format: "%.1f", floatValue / 10)
    }
}

