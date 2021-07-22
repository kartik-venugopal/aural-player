//
//  TimeViewController.swift
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
class TimeStretchViewController: EffectsUnitViewController {
    
    @IBOutlet weak var timeStretchView: TimeStretchView!
    
    @IBOutlet weak var lblRate: VALabel!
    @IBOutlet weak var lblRateMin: VALabel!
    @IBOutlet weak var lblRateMax: VALabel!
    @IBOutlet weak var lblRateValue: VALabel!
    
    @IBOutlet weak var lblOverlap: VALabel!
    @IBOutlet weak var lblOverlapMin: VALabel!
    @IBOutlet weak var lblOverlapMax: VALabel!
    @IBOutlet weak var lblOverlapValue: VALabel!
    
    @IBOutlet weak var lblPitchShiftValue: VALabel!
    @IBOutlet weak var btnShiftPitch: NSButton!
    
    override var nibName: String? {"TimeStretch"}
    
    var timeStretchUnit: TimeStretchUnitDelegateProtocol = objectGraph.audioGraphDelegate.timeStretchUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = graph.timeStretchUnit
        presetsWrapper = PresetsWrapper<TimeStretchPreset, TimeStretchPresets>(timeStretchUnit.presets)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribe(to: .timeEffectsUnit_decreaseRate, handler: decreaseRate)
        messenger.subscribe(to: .timeEffectsUnit_increaseRate, handler: increaseRate)
        messenger.subscribe(to: .timeEffectsUnit_setRate, handler: setRate(_:))
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        timeStretchView.initialize(self.unitStateFunction)
    }

    override func initControls() {

        super.initControls()
        timeStretchView.setState(timeStretchUnit.rate, timeStretchUnit.formattedRate, timeStretchUnit.overlap, timeStretchUnit.formattedOverlap, timeStretchUnit.shiftPitch, timeStretchUnit.formattedPitch)
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        timeStretchView.stateChanged()
    }

    // Activates/deactivates the Time stretch effects unit
    @IBAction override func bypassAction(_ sender: AnyObject) {

        super.bypassAction(sender)
        
        // The playback rate may have changed, send out a notification
        messenger.publish(.effects_playbackRateChanged, payload: timeStretchUnit.effectiveRate)
    }

    // Toggles the "pitch shift" option of the Time stretch effects unit
    @IBAction func shiftPitchAction(_ sender: AnyObject) {

        timeStretchUnit.shiftPitch = timeStretchView.shiftPitch
        updatePitchShift()
    }

    // Updates the playback rate value
    @IBAction func timeStretchAction(_ sender: AnyObject) {

        timeStretchUnit.rate = timeStretchView.rate
        timeStretchView.setRate(timeStretchUnit.rate, timeStretchUnit.formattedRate, timeStretchUnit.formattedPitch)

        // If the unit is active, publish a notification that the playback rate has changed. Other UI elements may need to be updated as a result.
        if timeStretchUnit.isActive {
            messenger.publish(.effects_playbackRateChanged, payload: timeStretchUnit.rate)
        }
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

        timeStretchView.setRate(rateInfo.rate, rateInfo.rateString, timeStretchUnit.formattedPitch)
        stateChanged()

        showThisTab()

        messenger.publish(.effects_playbackRateChanged, payload: rateInfo.rate)
    }

    // Updates the Overlap parameter of the Time stretch effects unit
    @IBAction func timeOverlapAction(_ sender: Any) {
        
        timeStretchUnit.overlap = timeStretchView.overlap
        timeStretchView.setOverlap(timeStretchUnit.overlap, timeStretchUnit.formattedOverlap)
    }

    // Updates the label that displays the pitch shift value
    private func updatePitchShift() {
        timeStretchView.updatePitchShift(timeStretchUnit.formattedPitch)
    }
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        
        super.applyFontScheme(fontScheme)
        btnShiftPitch.redraw()
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        changeSliderColors()
        
        btnShiftPitch.attributedTitle = NSAttributedString(string: btnShiftPitch.title,
                                                           attributes: [.foregroundColor: scheme.effects.functionCaptionTextColor])
        
        btnShiftPitch.attributedAlternateTitle = NSAttributedString(string: btnShiftPitch.title,
                                                                    attributes: [.foregroundColor: scheme.effects.functionCaptionTextColor])
    }
    
    override func changeSliderColors() {
        timeStretchView.redrawSliders()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        
        if timeStretchUnit.isActive {
            timeStretchView.redrawSliders()
        }
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        
        if timeStretchUnit.state == .bypassed {
            timeStretchView.redrawSliders()
        }
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        
        if timeStretchUnit.state == .suppressed {
            timeStretchView.redrawSliders()
        }
    }
    
    override func changeFunctionCaptionTextColor(_ color: NSColor) {
        
        super.changeFunctionCaptionTextColor(color)
        timeStretchView.changeFunctionCaptionTextColor()
    }
}
