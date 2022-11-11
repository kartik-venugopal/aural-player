//
//  FilterBandViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterBandViewController: NSViewController {
    
    override var nibName: String? {"FilterBand"}
    
    static func create(band: FilterBand, at index: Int, withButtonAction action: Selector, andTarget target: AnyObject) -> FilterBandViewController {
        
        let controller = FilterBandViewController()
        controller.forceLoadingOfView()
        
        controller.initialize(band: band, at: index, withButtonAction: action, andTarget: target)
        return controller
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var bandView: FilterBandView!
    
    var band: FilterBand {bandView.band}
    
    private func initialize(band: FilterBand, at index: Int, withButtonAction action: Selector, andTarget target: AnyObject) {
        bandView.initialize(band: band, at: index, withButtonAction: action, andTarget: target)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func bandTypeAction(_ sender: NSPopUpButton) {
        
        if let selectedItemTitle = sender.titleOfSelectedItem {
            bandView.changeBandType(FilterBandType.fromDescription(selectedItemTitle))
        }
    }
    
    @IBAction func cutoffSliderAction(_ sender: EffectsUnitSlider) {
        bandView.cutoffFrequencyChanged()
    }
    
    @IBAction func presetRangeAction(_ sender: NSPopUpButton) {
        
        if let rangeItem = sender.selectedItem as? FrequencyRangeMenuItem {
            bandView.setFrequencyRange(minFreq: rangeItem.minFreq, maxFreq: rangeItem.maxFreq)
        }
    }
    
    @IBAction func presetCutoffAction(_ sender: NSPopUpButton) {
        
        if let selectedItem = sender.selectedItem {
            bandView.setCutoffFrequency(Float(selectedItem.tag))
        }
    }
}

@IBDesignable
class FrequencyRangeMenuItem: NSMenuItem {
    
    @IBInspectable var minFreq: Float = SoundConstants.audibleRangeMin
    @IBInspectable var maxFreq: Float = SoundConstants.audibleRangeMax
}
