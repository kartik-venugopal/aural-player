//
//  EQUnitViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the EQ (Equalizer) effects unit
 */
class EQUnitViewController: EffectsUnitViewController {
    
    override var nibName: String? {"EQUnit"}
    
    @IBOutlet weak var eqView: EQView!
    
    private var eqUnit: EQUnitDelegateProtocol = objectGraph.audioGraphDelegate.eqUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.effectsUnit = graph.eqUnit
        self.presetsWrapper = PresetsWrapper<EQPreset, EQPresets>(eqUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        eqView.initialize(#selector(self.eqSliderAction(_:)), self, self.unitStateFunction)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribe(to: .eqEffectsUnit_decreaseBass, handler: decreaseBass)
        messenger.subscribe(to: .eqEffectsUnit_increaseBass, handler: increaseBass)
        
        messenger.subscribe(to: .eqEffectsUnit_decreaseMids, handler: decreaseMids)
        messenger.subscribe(to: .eqEffectsUnit_increaseMids, handler: increaseMids)
        
        messenger.subscribe(to: .eqEffectsUnit_decreaseTreble, handler: decreaseTreble)
        messenger.subscribe(to: .eqEffectsUnit_increaseTreble, handler: increaseTreble)

        messenger.subscribe(to: .changeTabButtonTextColor, handler: changeTabButtonTextColor(_:))
        messenger.subscribe(to: .changeSelectedTabButtonColor, handler: changeSelectedTabButtonColor(_:))
        messenger.subscribe(to: .changeSelectedTabButtonTextColor, handler: changeSelectedTabButtonTextColor(_:))
    }
    
    override func initControls() {
        
        super.initControls()
        eqView.setState(eqUnit.type, eqUnit.bands, eqUnit.globalGain)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func chooseEQTypeAction(_ sender: AnyObject) {
        
        eqUnit.type = eqView.type
        eqView.typeChanged(eqUnit.bands, eqUnit.globalGain)
    }
    
    @IBAction func eqGlobalGainAction(_ sender: EffectsUnitSlider) {
        eqUnit.globalGain = sender.floatValue
    }
    
    // Updates the gain value of a single frequency band (specified by the slider parameter) of the Equalizer
    @IBAction func eqSliderAction(_ sender: EffectsUnitSlider) {
        eqUnit[sender.tag] = sender.floatValue
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func stateChanged() {
        
        super.stateChanged()
        eqView.stateChanged()
    }
    
    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    private func increaseBass() {
        bandsUpdated(eqUnit.increaseBass())
    }
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    private func decreaseBass() {
        bandsUpdated(eqUnit.decreaseBass())
    }
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    private func increaseMids() {
        bandsUpdated(eqUnit.increaseMids())
    }
    
    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    private func decreaseMids() {
        bandsUpdated(eqUnit.decreaseMids())
    }
    
    // Decreases each of the EQ treble bands by a certain preset increment
    private func increaseTreble() {
        bandsUpdated(eqUnit.increaseTreble())
    }
    
    // Decreases each of the EQ treble bands by a certain preset decrement
    private func decreaseTreble() {
        bandsUpdated(eqUnit.decreaseTreble())
    }
    
    private func bandsUpdated(_ bands: [Float]) {
        
        stateChanged()
        eqView.bandsUpdated(bands, eqUnit.globalGain)
        
        messenger.publish(.effects_unitStateChanged)
        showThisTab()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        
        super.applyFontScheme(fontScheme)
        eqView.applyFontScheme(fontScheme)
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        
        changeSelectedTabButtonColor(scheme.general.selectedTabButtonColor)
        changeTabButtonTextColor(scheme.general.tabButtonTextColor)
        changeSelectedTabButtonTextColor(scheme.general.selectedTabButtonTextColor)
        changeSliderColors()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        
        if eqUnit.state == .active {
            eqView.changeActiveUnitStateColor(color)
        }
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        
        if eqUnit.state == .bypassed {
            eqView.changeBypassedUnitStateColor(color)
        }
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        
        if eqUnit.state == .suppressed {
            eqView.changeSuppressedUnitStateColor(color)
        }
    }
    
    func changeSelectedTabButtonColor(_ color: NSColor) {
        eqView.changeSelectedTabButtonColor()
    }
    
    func changeTabButtonTextColor(_ color: NSColor) {
        eqView.changeTabButtonTextColor()
    }
    
    func changeSelectedTabButtonTextColor(_ color: NSColor) {
        eqView.changeSelectedTabButtonTextColor()
    }
    
    override func changeSliderColors() {
        eqView.changeSliderColor()
    }
}
