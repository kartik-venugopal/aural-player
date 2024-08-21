//
//  DecibelSelectorView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class DecibelSelectorView: NSView {
    
    @IBOutlet weak var decibelStepper: NSStepper!
    
    @IBOutlet weak var btnCustomDecibel: CheckBox!
    @IBOutlet weak var lblDecibel: NSTextField!
    
    lazy var replayGainUnit: ReplayGainUnitDelegateProtocol = audioGraphDelegate.replayGainUnit
    
    ///
    /// Stepper value is 10x target value, so divide by 10.
    ///
    var decibelValue: Float {
        
        get {
            decibelStepper.floatValue / 10.0
        }
        
        set {
            decibelStepper.floatValue = newValue * 10.0
        }
    }
    
    var formattedDecibelString: String {
        String(format: "%.2f dB", decibelValue)
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        lblDecibel.font = .menuFont
    }
    
    func setCustomCheckboxState(_ state: NSControl.StateValue) {
        
        btnCustomDecibel.state = state
        decibelStepper.enableIf(state == .on)
    }
    
    // Called externally (menu delegate).
    func prepareToAppear() {}
    
    @IBAction func decibelStepperAction(_ sender: NSStepper) {
        lblDecibel.stringValue = formattedDecibelString
    }
}

class MaxPeakLevelSelectorView: DecibelSelectorView {
    
    override func prepareToAppear() {
        
        switch replayGainUnit.maxPeakLevel {
            
        case .zero:
            
            btnCustomDecibel.off()
            decibelStepper.disable()
            
        case .custom(_):
            
            btnCustomDecibel.on()
            decibelStepper.enable()
        }
        
        decibelValue = replayGainUnit.maxPeakLevel.decibels
        lblDecibel.stringValue = formattedDecibelString
    }
    
    @IBAction override func decibelStepperAction(_ sender: NSStepper) {

        super.decibelStepperAction(sender)
        
        replayGainUnit.maxPeakLevel = .custom(maxPeakLevel: decibelValue)
        Messenger.publish(.Effects.ReplayGainUnit.maxPeakLevelChanged)
    }
}
