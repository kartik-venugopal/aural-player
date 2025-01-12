//
//  AUParameterControlViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa
import AudioToolbox

class AUParameterControlViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"AUParameterControl"}
    
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblMinValue: NSTextField!
    @IBOutlet weak var lblMaxValue: NSTextField!
    @IBOutlet weak var lblCurrentValue: NSTextField!
    @IBOutlet weak var lblUnit: NSTextField!
    @IBOutlet weak var valueSlider: NSSlider!
    
    var useLogScale: Bool = false
    lazy var maxMinusMin: Double = valueSlider.maxValue - valueSlider.minValue
    lazy var maxDivMin: Double = valueSlider.minValue == 0 ? 0 : valueSlider.maxValue / valueSlider.minValue
    lazy var numIntervals: Double = log10(maxDivMin)
    
    var paramControlDelegate: AUParameterControlViewDelegate! {
        
        didSet {
            
            guard let delegate = paramControlDelegate else {return}
            
            lblName.stringValue = delegate.name
            lblMinValue.stringValue = String(delegate.minValue)
            lblMaxValue.stringValue = String(delegate.maxValue)
            lblCurrentValue.stringValue = String(format: "%.3f", delegate.currentValue)
            lblUnit.stringValue = delegate.unitName
            useLogScale = delegate.unitName.lowerCasedAndTrimmed() == "hz"
            
            valueSlider.minValue = Double(delegate.minValue)
            valueSlider.maxValue = Double(delegate.maxValue)
            
            if useLogScale {
                logScaleValue = delegate.currentValue
                
            } else {
                valueSlider.floatValue = delegate.currentValue
            }
        }
    }
    
    @IBAction func updateParamValueAction(_ sender: NSSlider) {
        
        paramControlDelegate.setValue(useLogScale ? logScaleValue : valueSlider.floatValue)
        lblCurrentValue.stringValue = String(format: "%.3f", paramControlDelegate.currentValue)
    }
    
    /// Called when a preset has been applied.
    func refreshControls() {
        
        if useLogScale {
            logScaleValue = paramControlDelegate.currentValue
            
        } else {
            valueSlider.floatValue = paramControlDelegate.currentValue
        }

        lblCurrentValue.stringValue = String(format: "%.3f", paramControlDelegate.currentValue)
    }
    
    private var logScaleValue: Float {
        
        get {
            
            let min = valueSlider.minValue == 0 ? 0.0001 : valueSlider.minValue
            let cur = valueSlider.doubleValue
            
            let power = numIntervals * (cur - min) / maxMinusMin
            return Float(min * (pow(10, power)))
        }
        
        set {
            
            let min = valueSlider.minValue
            let logV = log10(Double(newValue) / min)
            valueSlider.doubleValue = (maxMinusMin * logV / numIntervals) + min
        }
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
