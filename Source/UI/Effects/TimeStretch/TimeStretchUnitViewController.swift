//
//  TimeStretchUnitViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Time effects unit
 */
class TimeStretchUnitViewController: EffectsUnitViewController {
    
    override var nibName: NSNib.Name? {"TimeStretchUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var timeStretchUnitView: TimeStretchUnitView!
    @IBOutlet weak var slider: CircularSlider!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    private var timeStretchUnit: TimeStretchUnitProtocol = audioGraph.timeStretchUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = self.timeStretchUnit
        presetsWrapper = PresetsWrapper<TimeStretchPreset, TimeStretchPresets>(timeStretchUnit.presets)
    }

    override func initControls() {

        super.initControls()
        
        timeStretchUnitView.setState(rate: timeStretchUnit.rate, rateString: ValueFormatter.formatTimeStretchRate(timeStretchUnit.rate),
                                 shiftPitch: timeStretchUnit.shiftPitch, shiftPitchString: ValueFormatter.formatPitch(timeStretchUnit.pitch))
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions

    // Activates/deactivates the Time stretch effects unit
    @IBAction override func bypassAction(_ sender: AnyObject) {

        super.bypassAction(sender)
        
        // The playback rate may have changed, send out a notification
        messenger.publish(.Effects.playbackRateChanged, payload: timeStretchUnit.effectiveRate)
    }

    // Updates the playback rate value
    @IBAction func timeStretchAction(_ sender: AnyObject) {
        
        timeStretchUnit.rate = timeStretchUnitView.rate
        timeStretchUnitView.setRate(timeStretchUnit.rate, rateString: ValueFormatter.formatTimeStretchRate(timeStretchUnit.rate),
                                shiftPitchString: ValueFormatter.formatPitch(timeStretchUnit.pitch))

        // If the unit is active, publish a notification that the playback rate has changed. Other UI elements may need to be updated as a result.
        if timeStretchUnit.isActive {
            messenger.publish(.Effects.playbackRateChanged, payload: timeStretchUnit.rate)
        }
    }
    
    private let oneTenth: Float = 1.0 / 10.0
    private let oneHundredth: Float = 1.0 / 100.0
    
    @IBAction func increaseRateByTenthAction(_ sender: AnyObject) {
        
        _ = timeStretchUnit.increaseRate(by: oneTenth, ensureActive: false)
        timeStretchUnitView.setRate(timeStretchUnit.rate, rateString: ValueFormatter.formatTimeStretchRate(timeStretchUnit.rate),
                                shiftPitchString: ValueFormatter.formatPitch(timeStretchUnit.pitch))

        // If the unit is active, publish a notification that the playback rate has changed. Other UI elements may need to be updated as a result.
        if timeStretchUnit.isActive {
            messenger.publish(.Effects.playbackRateChanged, payload: timeStretchUnit.rate)
        }
    }
    
    @IBAction func increaseRateByHundredthAction(_ sender: AnyObject) {
        
        _ = timeStretchUnit.increaseRate(by: oneHundredth, ensureActive: false)
        timeStretchUnitView.setRate(timeStretchUnit.rate, rateString: ValueFormatter.formatTimeStretchRate(timeStretchUnit.rate),
                                shiftPitchString: ValueFormatter.formatPitch(timeStretchUnit.pitch))

        // If the unit is active, publish a notification that the playback rate has changed. Other UI elements may need to be updated as a result.
        if timeStretchUnit.isActive {
            messenger.publish(.Effects.playbackRateChanged, payload: timeStretchUnit.rate)
        }
    }
    
    @IBAction func decreaseRateByTenthAction(_ sender: AnyObject) {
        
        _ = timeStretchUnit.decreaseRate(by: oneTenth, ensureActive: false)
        timeStretchUnitView.setRate(timeStretchUnit.rate, rateString: ValueFormatter.formatTimeStretchRate(timeStretchUnit.rate),
                                shiftPitchString: ValueFormatter.formatPitch(timeStretchUnit.pitch))

        // If the unit is active, publish a notification that the playback rate has changed. Other UI elements may need to be updated as a result.
        if timeStretchUnit.isActive {
            messenger.publish(.Effects.playbackRateChanged, payload: timeStretchUnit.rate)
        }
    }
    
    @IBAction func decreaseRateByHundredthAction(_ sender: AnyObject) {
        
        _ = timeStretchUnit.decreaseRate(by: oneHundredth, ensureActive: false)
        timeStretchUnitView.setRate(timeStretchUnit.rate, rateString: ValueFormatter.formatTimeStretchRate(timeStretchUnit.rate),
                                shiftPitchString: ValueFormatter.formatPitch(timeStretchUnit.pitch))

        // If the unit is active, publish a notification that the playback rate has changed. Other UI elements may need to be updated as a result.
        if timeStretchUnit.isActive {
            messenger.publish(.Effects.playbackRateChanged, payload: timeStretchUnit.rate)
        }
    }
    
    // Toggles the "Shift pitch" option of the Time stretch effects unit
    @IBAction func shiftPitchAction(_ sender: AnyObject) {
        timeStretchUnit.shiftPitch.toggle()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        messenger.subscribe(to: .Effects.TimeStretchUnit.rateUpdated, handler: rateUpdated)
    }

    // Changes the playback rate to a specific value
    private func rateUpdated() {
        
        messenger.publish(.Effects.unitStateChanged)
        
        let rate = timeStretchUnit.rate
        
        timeStretchUnitView.setRate(rate,
                                    rateString: ValueFormatter.formatTimeStretchRate(timeStretchUnit.rate),
                                    shiftPitchString: ValueFormatter.formatPitch(timeStretchUnit.pitch))
        stateChanged()

        showThisTab()

        messenger.publish(.Effects.playbackRateChanged, payload: rate)
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        timeStretchUnitView.colorChanged(forUnitState: timeStretchUnit.state)
    }
    
    override func activeControlColorChanged(_ newColor: NSColor) {
        
        super.activeControlColorChanged(newColor)
        
        if timeStretchUnit.state == .active {
            timeStretchUnitView.colorChanged(forUnitState: .active)
        }
    }
    
    override func inactiveControlColorChanged(_ newColor: NSColor) {
        
        super.inactiveControlColorChanged(newColor)
        
        if timeStretchUnit.state == .bypassed {
            timeStretchUnitView.colorChanged(forUnitState: .bypassed)
        }
    }
    
    override func suppressedControlColorChanged(_ newColor: NSColor) {
        
        super.suppressedControlColorChanged(newColor)
        
        if timeStretchUnit.state == .suppressed {
            timeStretchUnitView.colorChanged(forUnitState: .suppressed)
        }
    }
}
