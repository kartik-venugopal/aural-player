//
//  TimeStretchUnitViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Time effects unit
 */
class TimeStretchUnitViewController: EffectsUnitViewController {
    
    override var nibName: String? {"TimeStretchUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var timeStretchUnitView: TimeStretchUnitView!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var timeStretchUnit: TimeStretchUnitDelegateProtocol = objectGraph.audioGraphDelegate.timeStretchUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = graph.timeStretchUnit
        presetsWrapper = PresetsWrapper<TimeStretchPreset, TimeStretchPresets>(timeStretchUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        timeStretchUnitView.initialize(stateFunction: unitStateFunction)
    }

    override func initControls() {

        super.initControls()
        
        timeStretchUnitView.setState(rate: timeStretchUnit.rate, rateString: timeStretchUnit.formattedRate,
                                 shiftPitch: timeStretchUnit.shiftPitch, shiftPitchString: timeStretchUnit.formattedPitch)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions

    // Activates/deactivates the Time stretch effects unit
    @IBAction override func bypassAction(_ sender: AnyObject) {

        super.bypassAction(sender)
        
        // The playback rate may have changed, send out a notification
        messenger.publish(.effects_playbackRateChanged, payload: timeStretchUnit.effectiveRate)
    }

    // Updates the playback rate value
    @IBAction func timeStretchAction(_ sender: AnyObject) {

        timeStretchUnit.rate = timeStretchUnitView.rate
        timeStretchUnitView.setRate(timeStretchUnit.rate, rateString: timeStretchUnit.formattedRate,
                                shiftPitchString: timeStretchUnit.formattedPitch)

        // If the unit is active, publish a notification that the playback rate has changed. Other UI elements may need to be updated as a result.
        if timeStretchUnit.isActive {
            messenger.publish(.effects_playbackRateChanged, payload: timeStretchUnit.rate)
        }
    }
    
    // Toggles the "Shift pitch" option of the Time stretch effects unit
    @IBAction func shiftPitchAction(_ sender: AnyObject) {

        timeStretchUnit.shiftPitch = timeStretchUnitView.shiftPitch
        timeStretchUnitView.updatePitchShift(shiftPitchString: timeStretchUnit.formattedPitch)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribe(to: .timeEffectsUnit_decreaseRate, handler: decreaseRate)
        messenger.subscribe(to: .timeEffectsUnit_increaseRate, handler: increaseRate)
        messenger.subscribe(to: .timeEffectsUnit_setRate, handler: setRate(_:))
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        timeStretchUnitView.stateChanged()
    }

    // Sets the playback rate to a specific value
    private func setRate(_ rate: Float) {

        timeStretchUnit.rate = rate
        timeStretchUnit.ensureActive()
        rateChange((rate, timeStretchUnit.formattedRate))
    }

    // Increases the playback rate by a certain preset increment
    private func increaseRate() {
        rateChange(timeStretchUnit.increaseRate())
    }

    // Decreases the playback rate by a certain preset decrement
    private func decreaseRate() {
        rateChange(timeStretchUnit.decreaseRate())
    }

    // Changes the playback rate to a specific value
    private func rateChange(_ rateInfo: (rate: Float, rateString: String)) {

        messenger.publish(.effects_unitStateChanged)

        timeStretchUnitView.setRate(rateInfo.rate, rateString: rateInfo.rateString,
                                shiftPitchString: timeStretchUnit.formattedPitch)
        stateChanged()

        showThisTab()

        messenger.publish(.effects_playbackRateChanged, payload: rateInfo.rate)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        
        super.applyFontScheme(fontScheme)
        timeStretchUnitView.applyFontScheme(fontScheme)
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        timeStretchUnitView.applyColorScheme(scheme)
    }
    
    override func changeSliderColors() {
        timeStretchUnitView.redrawSliders()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        
        if timeStretchUnit.isActive {
            timeStretchUnitView.redrawSliders()
        }
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        
        if timeStretchUnit.state == .bypassed {
            timeStretchUnitView.redrawSliders()
        }
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        
        if timeStretchUnit.state == .suppressed {
            timeStretchUnitView.redrawSliders()
        }
    }
    
    override func changeFunctionCaptionTextColor(_ color: NSColor) {
        
        super.changeFunctionCaptionTextColor(color)
        timeStretchUnitView.changeFunctionCaptionTextColor()
    }
}
