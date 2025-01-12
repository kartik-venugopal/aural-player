//
//  FilterBandViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterBandViewController: NSViewController {
    
    // MARK: UI fields
    
    @IBOutlet weak var bandView: FilterBandView!
    
    var band: FilterBand {bandView.band}
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    private func initialize(band: FilterBand, at index: Int, withButtonAction action: Selector, andTarget target: AnyObject) {
        bandView.initialize(band: band, at: index)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.activeControlColor, \.inactiveControlColor, \.suppressedControlColor],
                                                     handler: unitStateColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, handler: bandView.buttonColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primaryTextColor, handler: bandView.primaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: bandView.secondaryTextColorChanged(_:))
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func bandTypeAction(_ sender: NSPopUpButton) {
        
        if let selectedItemTitle = sender.titleOfSelectedItem {
            
            bandView.changeBandType(FilterBandType.fromDescription(selectedItemTitle))
            messenger.publish(.Effects.FilterUnit.bandUpdated, payload: bandView.bandIndex)
        }
    }
    
    @IBAction func cutoffSliderAction(_ sender: EffectsUnitSlider) {
        
        bandView.cutoffFrequencyChanged()
        messenger.publish(.Effects.FilterUnit.bandUpdated, payload: bandView.bandIndex)
    }
    
    @IBAction func presetRangeAction(_ sender: NSPopUpButton) {
        
        if let rangeItem = sender.selectedItem as? FrequencyRangeMenuItem {
            
            bandView.setFrequencyRange(minFreq: rangeItem.minFreq, maxFreq: rangeItem.maxFreq)
            messenger.publish(.Effects.FilterUnit.bandUpdated, payload: bandView.bandIndex)
        }
    }
    
    @IBAction func presetCutoffAction(_ sender: NSPopUpButton) {
        
        if let selectedItem = sender.selectedItem {
            
            bandView.setCutoffFrequency(Float(selectedItem.tag))
            messenger.publish(.Effects.FilterUnit.bandUpdated, payload: bandView.bandIndex)
        }
    }
}

extension FilterBandViewController: ThemeInitialization {
    
    func initTheme() {
        bandView.initTheme()
    }
}

extension FilterBandViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        bandView.fontSchemeChanged()
    }
}

extension FilterBandViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        bandView.colorSchemeChanged()
    }
    
    func unitStateColorChanged(_ newColor: NSColor) {
        bandView.redrawSliders()
    }
}

@IBDesignable
class FrequencyRangeMenuItem: NSMenuItem {
    
    @IBInspectable var minFreq: Float = SoundConstants.audibleRangeMin
    @IBInspectable var maxFreq: Float = SoundConstants.audibleRangeMax
}
