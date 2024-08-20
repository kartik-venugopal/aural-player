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
    
    var replayGainUnit: ReplayGainUnitDelegateProtocol!
    
    var formattedDecibelString: String {
        String(format: "%.2f dB", decibelStepper.floatValue)
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

class TargetLoudnessSelectorView: DecibelSelectorView {
    
    override func prepareToAppear() {
        
        decibelStepper.floatValue = replayGainUnit.targetLoudness.decibels
        lblDecibel.stringValue = formattedDecibelString
    }
    
    @IBAction override func decibelStepperAction(_ sender: NSStepper) {

        super.decibelStepperAction(sender)
        
        replayGainUnit.targetLoudness = .custom(targetLoudness: decibelStepper.floatValue)
        Messenger.publish(.Effects.ReplayGainUnit.targetLoudnessChanged)
    }
}

class MaxPeakLevelSelectorView: DecibelSelectorView {
    
    override func prepareToAppear() {
        
        decibelStepper.floatValue = replayGainUnit.maxPeakLevel.decibels
        lblDecibel.stringValue = formattedDecibelString
    }
    
    @IBAction override func decibelStepperAction(_ sender: NSStepper) {

        super.decibelStepperAction(sender)
        
        replayGainUnit.maxPeakLevel = .custom(maxPeakLevel: decibelStepper.floatValue)
        Messenger.publish(.Effects.ReplayGainUnit.maxPeakLevelChanged)
    }
}
