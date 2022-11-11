//
//  DelayUnitView.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class DelayUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var timeSlider: EffectsUnitSlider!
    @IBOutlet weak var amountSlider: EffectsUnitSlider!
    @IBOutlet weak var cutoffSlider: CutoffFrequencySlider!
    @IBOutlet weak var feedbackSlider: EffectsUnitSlider!
    
    private var sliders: [EffectsUnitSlider] = []
    
    @IBOutlet weak var lblTime: NSTextField!
    @IBOutlet weak var lblAmount: NSTextField!
    @IBOutlet weak var lblFeedback: NSTextField!
    @IBOutlet weak var lblCutoff: NSTextField!
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var time: Double {
        timeSlider.doubleValue
    }
    
    var amount: Float {
        amountSlider.floatValue
    }
    
    var cutoff: Float {
        cutoffSlider.frequency
    }
    
    var feedback: Float {
        feedbackSlider.floatValue
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View initialization
    
    override func awakeFromNib() {
        sliders = [timeSlider, amountSlider, cutoffSlider, feedbackSlider]
    }
    
    func initialize(stateFunction: @escaping EffectsUnitStateFunction) {
        
        sliders.forEach {
            $0.stateFunction = stateFunction
        }
        
        (cutoffSlider.cell as? CutoffFrequencySliderCell)?.filterType = .lowPass
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func setState(time: Double, timeString: String,
                  amount: Float, amountString: String,
                  feedback: Float, feedbackString: String,
                  cutoff: Float, cutoffString: String) {
        
        setTime(time, timeString: timeString)
        setAmount(amount, amountString: amountString)
        setFeedback(feedback, feedbackString: feedbackString)
        setCutoff(cutoff, cutoffString: cutoffString)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        sliders.forEach {$0.setUnitState(state)}
    }
    
    func setTime(_ time: Double, timeString: String) {
        
        timeSlider.doubleValue = time
        lblTime.stringValue = timeString
    }
    
    func setAmount(_ amount: Float, amountString: String) {
        
        amountSlider.floatValue = amount
        lblAmount.stringValue = amountString
    }
    
    func setFeedback(_ feedback: Float, feedbackString: String) {
        
        feedbackSlider.floatValue = feedback
        lblFeedback.stringValue = feedbackString
    }
    
    func setCutoff(_ cutoff: Float, cutoffString: String) {
        
        cutoffSlider.setFrequency(cutoff)
        lblCutoff.stringValue = cutoffString
    }
    
    func stateChanged() {
        sliders.forEach {$0.updateState()}
    }
    
    func applyPreset(_ preset: DelayPreset) {
        
        amountSlider.floatValue = preset.amount
        lblAmount.stringValue = ValueFormatter.formatDelayAmount(preset.amount)
        
        timeSlider.doubleValue = preset.time
        lblTime.stringValue = ValueFormatter.formatDelayTime(preset.time)
        
        feedbackSlider.floatValue = preset.feedback
        lblFeedback.stringValue = ValueFormatter.formatDelayFeedback(preset.feedback)
        
        cutoffSlider.setFrequency(preset.lowPassCutoff)
        lblCutoff.stringValue = ValueFormatter.formatDelayLowPassCutoff(preset.lowPassCutoff)
        
        sliders.forEach {$0.setUnitState(preset.state)}
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func redrawSliders() {
        sliders.forEach {$0.redraw()}
    }
}
