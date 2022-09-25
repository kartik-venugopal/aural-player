//
//  AUParameterControlViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa
import AudioToolbox

class AUParameterControlViewController: NSViewController {
    
    override var nibName: String? {"AUParameterControl"}
    
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblMinValue: NSTextField!
    @IBOutlet weak var lblMaxValue: NSTextField!
    @IBOutlet weak var lblCurrentValue: NSTextField!
    @IBOutlet weak var lblUnit: NSTextField!
    @IBOutlet weak var valueSlider: NSSlider!
    
    var paramControlDelegate: AUParameterControlViewDelegate! {
        
        didSet {
            
            guard let delegate = paramControlDelegate else {return}
            
            lblName.stringValue = delegate.name
            lblMinValue.stringValue = String(delegate.minValue)
            lblMaxValue.stringValue = String(delegate.maxValue)
            lblCurrentValue.stringValue = String(delegate.currentValue)
            lblUnit.stringValue = delegate.unitName
            
            valueSlider.minValue = Double(delegate.minValue)
            valueSlider.maxValue = Double(delegate.maxValue)
            valueSlider.floatValue = delegate.currentValue
        }
    }
    
    @IBAction func updateParamValueAction(_ sender: NSSlider) {
        
        paramControlDelegate.setValue(valueSlider.floatValue)
        lblCurrentValue.stringValue = String(paramControlDelegate.currentValue)
    }
}

class AUParameterControlViewDelegate {
    
    let audioUnit: HostedAudioUnitDelegateProtocol
    let parameter: AUParameter

    var name: String {parameter.displayName}
    var unitName: String {parameter.unitName ?? ""}
    var minValue: Float {parameter.minValue}
    var maxValue: Float {parameter.maxValue}
    var currentValue: Float {parameter.value}
    
    init(audioUnit: HostedAudioUnitDelegateProtocol, parameter: AUParameter) {
        
        self.audioUnit = audioUnit
        self.parameter = parameter
    }
    
    func setValue(_ value: Float) {
        audioUnit.setValue(value, forParameterWithAddress: parameter.address)
    }
}
