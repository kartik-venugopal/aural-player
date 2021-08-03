//
//  EQUnitView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EQUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var eq10BandView: EQUnitSubview!
    @IBOutlet weak var eq15BandView: EQUnitSubview!
    
    @IBOutlet weak var btn10Band: NSButton!
    @IBOutlet weak var btn15Band: NSButton!
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var type: EQType {
        btn10Band.isOn ? .tenBand : .fifteenBand
    }
    
    private var activeView: EQUnitSubview {
        btn10Band.isOn ? eq10BandView : eq15BandView
    }
    
    private var activeViewTabIndex: Int {
        btn10Band.isOn ? 0 : 1
    }
    
    var globalGain: Float {
        activeView.globalGainSlider.floatValue
    }
    
    var functionCaptionLabels: [NSTextField] {
        eq10BandView.functionCaptionLabels + eq15BandView.functionCaptionLabels
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View initialization
    
    override func awakeFromNib() {
        
        for (index, view) in [eq10BandView, eq15BandView].compactMap({$0}).enumerated() {
            
            tabView.tabViewItem(at: index).view?.addSubview(view)
            view.positionAtZeroPoint()
        }
    }
    
    func initialize(eqStateFunction: @escaping EffectsUnitStateFunction,
                    sliderAction: Selector?, sliderActionTarget: AnyObject?) {
        
        eq10BandView.initialize(stateFunction: eqStateFunction,
                                sliderAction: sliderAction, sliderActionTarget: sliderActionTarget)
        
        eq15BandView.initialize(stateFunction: eqStateFunction,
                                sliderAction: sliderAction, sliderActionTarget: sliderActionTarget)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func setState(eqType: EQType, bands: [Float], globalGain: Float) {

        eqType == .tenBand ? btn10Band.on() : btn15Band.on()
        typeChanged(bands: bands, globalGain: globalGain)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        activeView.setState(state)
    }

    func typeChanged(bands: [Float], globalGain: Float) {
        
        activeView.stateChanged()
        activeView.updateBands(bands, globalGain: globalGain)
        
        tabView.selectTabViewItem(at: activeViewTabIndex)
    }
    
    func bandsUpdated(_ bands: [Float], globalGain: Float) {
        activeView.updateBands(bands, globalGain: globalGain)
    }
    
    func stateChanged() {
        activeView.stateChanged()
    }
    
    func chooseType(_ eqType: EQType) {
        
        eqType == .tenBand ? btn10Band.on() : btn15Band.on()
        
        activeView.stateChanged()
        tabView.selectTabViewItem(at: activeViewTabIndex)
    }
    
    func applyPreset(_ preset: EQPreset) {
    
        setUnitState(preset.state)
        bandsUpdated(preset.bands, globalGain: preset.globalGain)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        btn10Band.redraw()
        btn15Band.redraw()
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        
        eq10BandView.changeActiveUnitStateColor(color)
        eq15BandView.changeActiveUnitStateColor(color)
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        
        eq10BandView.changeBypassedUnitStateColor(color)
        eq15BandView.changeBypassedUnitStateColor(color)
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        eq10BandView.changeSuppressedUnitStateColor(color)
        eq15BandView.changeSuppressedUnitStateColor(color)
    }
    
    func changeSelectedTabButtonColor() {
        btn10Band.isOn ? btn10Band.redraw() : btn15Band.redraw()
    }
    
    func changeTabButtonTextColor() {
        btn10Band.isOff ? btn10Band.redraw() : btn15Band.redraw()
    }
    
    func changeSelectedTabButtonTextColor() {
        btn10Band.isOn ? btn10Band.redraw() : btn15Band.redraw()
    }
    
    func changeSliderColor() {
        
        eq10BandView.changeSliderColor()
        eq15BandView.changeSliderColor()
    }
}
