//
//  DelayUnitViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Delay effects unit
 */
class DelayUnitViewController: EffectsUnitViewController {
    
    override var nibName: String? {"DelayUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var delayUnitView: DelayUnitView!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var delayUnit: DelayUnitDelegateProtocol = objectGraph.audioGraphDelegate.delayUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = delayUnit
        presetsWrapper = PresetsWrapper<DelayPreset, DelayPresets>(delayUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        delayUnitView.initialize(stateFunction: self.unitStateFunction)
    }

    override func initControls() {

        super.initControls()
        
        delayUnitView.setState(time: delayUnit.time, timeString: delayUnit.formattedTime,
                               amount: delayUnit.amount, amountString: delayUnit.formattedAmount,
                               feedback: delayUnit.feedback, feedbackString: delayUnit.formattedFeedback,
                               cutoff: delayUnit.lowPassCutoff, cutoffString: delayUnit.formattedLowPassCutoff)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions

    // Updates the Delay amount parameter
    @IBAction func delayAmountAction(_ sender: AnyObject) {

        delayUnit.amount = delayUnitView.amount
        delayUnitView.setAmount(delayUnit.amount, amountString: delayUnit.formattedAmount)
    }

    // Updates the Delay time parameter
    @IBAction func delayTimeAction(_ sender: AnyObject) {

        delayUnit.time = delayUnitView.time
        delayUnitView.setTime(delayUnit.time, timeString: delayUnit.formattedTime)
    }

    // Updates the Delay feedback parameter
    @IBAction func delayFeedbackAction(_ sender: AnyObject) {

        delayUnit.feedback = delayUnitView.feedback
        delayUnitView.setFeedback(delayUnit.feedback, feedbackString: delayUnit.formattedFeedback)
    }

    // Updates the Delay low pass cutoff parameter
    @IBAction func delayCutoffAction(_ sender: AnyObject) {

        delayUnit.lowPassCutoff = delayUnitView.cutoff
        delayUnitView.setCutoff(delayUnit.lowPassCutoff, cutoffString: delayUnit.formattedLowPassCutoff)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func stateChanged() {
        
        super.stateChanged()
        delayUnitView.stateChanged()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        changeSliderColors()
    }
    
    override func changeSliderColors() {
        delayUnitView.redrawSliders()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        delayUnitView.redrawSliders()
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        delayUnitView.redrawSliders()
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        delayUnitView.redrawSliders()
    }
}
