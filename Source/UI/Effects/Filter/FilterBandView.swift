//
//  FilterBandView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class FilterBandView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var filterTypeMenu: NSPopUpButton!
    
    @IBOutlet weak var freqRangeSlider: FilterBandSlider!
    @IBOutlet weak var cutoffSlider: CutoffFrequencySlider!
    @IBOutlet weak var cutoffSliderCell: FilterCutoffFrequencySliderCell!
    
    @IBOutlet weak var lblRangeCaption: NSTextField!
    @IBOutlet weak var presetRangesMenu: NSPopUpButton!
    @IBOutlet weak var presetRangesIconMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var lblCutoffCaption: NSTextField!
    @IBOutlet weak var presetCutoffsMenu: NSPopUpButton!
    @IBOutlet weak var presetCutoffsIconMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var lblFrequencies: NSTextField!
    
    @IBOutlet weak var tabButton: NSButton!
    
    private var functionCaptionLabels: [NSTextField] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    private var filterUnit: FilterUnitDelegateProtocol = objectGraph.audioGraphDelegate.filterUnit
    
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    private(set) var band: FilterBand = .bandPassBand(minFreq: SoundConstants.audibleRangeMin,
                                                      maxFreq: SoundConstants.audibleRangeMax) {
        
        didSet {updateFields()}
    }
    
    private(set) var bandIndex: Int = -1
    
    var bandChangedCallback: (() -> Void) = {
        // Do nothing
    }
    
    var buttonWidth: CGFloat {
        tabButton.width
    }
    
    var buttonPosition: NSPoint {
        
        get {tabButton.frame.origin}
        set {tabButton.setFrameOrigin(newValue)}
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    func initialize(band: FilterBand, at index: Int, withButtonAction action: Selector, andTarget target: AnyObject) {
        
        self.band = band
        self.bandIndex = index
        
        tabButton.title = "#\(index + 1)"
        tabButton.tag = index
        tabButton.action = action
        tabButton.target = target
    }
    
    override func awakeFromNib() {
        
        oneTimeSetup()
        updateFields()
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    private func oneTimeSetup() {
        
        freqRangeSlider.onControlChanged = {[weak self] slider in self?.freqRangeChanged()}
        freqRangeSlider.stateFunction = filterUnit.stateFunction
        cutoffSlider.stateFunction = filterUnit.stateFunction
        
        functionCaptionLabels = findFunctionCaptionLabels(under: self)
        
        presetRangesIconMenuItem.tintFunction = {Colors.functionButtonColor}
        presetCutoffsIconMenuItem.tintFunction = {Colors.functionButtonColor}
    }
    
    private func updateFields() {
        
        let filterType = band.type
        
        filterTypeMenu.selectItem(withTitle: filterType.description)
        
        let filterTypeIsBandPassOrStop: Bool = filterType.equalsOneOf(.bandStop, .bandPass)
        
        [freqRangeSlider, lblRangeCaption, presetRangesMenu].forEach {$0?.showIf(filterTypeIsBandPassOrStop)}
        [cutoffSlider, lblCutoffCaption, presetCutoffsMenu].forEach {$0?.hideIf(filterTypeIsBandPassOrStop)}
        
        if filterTypeIsBandPassOrStop {
            
            freqRangeSlider.filterType = filterType
            
            if let minFreq = band.minFreq, let maxFreq = band.maxFreq {
                
                freqRangeSlider.setFrequencyRange(minFreq, maxFreq)
                lblFrequencies.stringValue = "[ \(formatFrequency(minFreq)) - \(formatFrequency(maxFreq)) ]"
                
                cutoffSlider.setFrequency(SoundConstants.audibleRangeMin)
            }
            
        } else {
            
            if filterType == .lowPass, let maxFreq = band.maxFreq {
                cutoffSlider.setFrequency(maxFreq)
                
            } else if filterType == .highPass, let minFreq = band.minFreq {
                cutoffSlider.setFrequency(minFreq)
            }
            
            cutoffSliderCell.filterType = filterType
            cutoffSlider.redraw()
            lblFrequencies.stringValue = formatFrequency(cutoffSlider.frequency)
            
            freqRangeSlider.setFrequencyRange(SoundConstants.audibleRangeMin, SoundConstants.subBass_max)
        }
        
        freqRangeSlider.updateState()
        cutoffSlider.updateState()
        
        presetCutoffsMenu.deselect()
        presetRangesMenu.deselect()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    func changeBandType(_ filterType: FilterBandType) {
        
        band.type = filterType
        
        let filterTypeIsBandPassOrStop: Bool = filterType.equalsOneOf(.bandStop, .bandPass)
        
        [freqRangeSlider, lblRangeCaption, presetRangesMenu].forEach {$0?.showIf(filterTypeIsBandPassOrStop)}
        [cutoffSlider, lblCutoffCaption, presetCutoffsMenu].forEach {$0?.hideIf(filterTypeIsBandPassOrStop)}
        
        if filterTypeIsBandPassOrStop {
            
            freqRangeSlider.filterType = filterType
            freqRangeChanged()
            
            band.minFreq = freqRangeSlider.startFrequency
            band.maxFreq = freqRangeSlider.endFrequency
            
        } else {
            
            cutoffSliderCell.filterType = filterType
            cutoffSlider.redraw()
            cutoffFrequencyChanged()
            
            band.minFreq = filterType == .lowPass ? nil : cutoffSlider.frequency
            band.maxFreq = filterType == .lowPass ? cutoffSlider.frequency : nil
        }
        
        filterUnit[bandIndex] = band
        
        bandChangedCallback()
    }
    
    // Action for the frequency range slider.
    private func freqRangeChanged() {
        
        band.minFreq = freqRangeSlider.startFrequency
        band.maxFreq = freqRangeSlider.endFrequency
        
        filterUnit[bandIndex] = band
        
        lblFrequencies.stringValue = String(format: "[ %@ - %@ ]", formatFrequency(freqRangeSlider.startFrequency),
                                            formatFrequency(freqRangeSlider.endFrequency))
        
        bandChangedCallback()
    }
    
    func cutoffFrequencyChanged() {
        
        band.minFreq = band.type == .lowPass ? nil : cutoffSlider.frequency
        band.maxFreq = band.type == .lowPass ? cutoffSlider.frequency : nil
        
        filterUnit[bandIndex] = band
        
        lblFrequencies.stringValue = formatFrequency(cutoffSlider.frequency)
        
        bandChangedCallback()
    }
    
    func setFrequencyRange(minFreq: Float, maxFreq: Float) {
        
        freqRangeSlider.setFrequencyRange(minFreq, maxFreq)
        freqRangeChanged()
        
        presetRangesMenu.deselect()
    }
    
    func setCutoffFrequency(_ freq: Float) {
        
        cutoffSlider.setFrequency(freq)
        cutoffFrequencyChanged()
        
        presetCutoffsMenu.deselect()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Helper functions
    
    private func formatFrequency(_ freq: Float) -> String {
        
        let rounded = freq.roundedInt
        
        if rounded % 1000 == 0 {
            return String(format: "%d KHz", rounded / 1000)
        } else {
            return String(format: "%d Hz", rounded)
        }
    }
    
    func stateChanged() {
        
        freqRangeSlider.updateState()
        cutoffSlider.updateState()
    }
    
    private func findFunctionCaptionLabels(under view: NSView) -> [NSTextField] {
        
        var labels: [NSTextField] = []
        
        for subview in view.subviews {
            
            if let label = subview as? NSTextField, !(label is FunctionValueLabel) {
                
                labels.append(label)
                continue
            }
            
            // Recursive call
            let subviewLabels = findFunctionCaptionLabels(under: subview)
            labels.append(contentsOf: subviewLabels)
        }
        
        return labels
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        tabButton.redraw()
        
        functionCaptionLabels.forEach {$0.font = fontSchemesManager.systemScheme.effects.unitFunctionFont}
        
        filterTypeMenu.font = fontSchemesManager.systemScheme.effects.unitFunctionFont
        filterTypeMenu.redraw()
        
        presetRangesMenu.font = fontSchemesManager.systemScheme.effects.unitFunctionFont
        lblFrequencies.font = fontSchemesManager.systemScheme.effects.unitFunctionFont
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        changeFunctionButtonColor()
        changeTextButtonMenuColor()
        changeFunctionCaptionTextColor(scheme.effects.functionCaptionTextColor)
        changeFunctionValueTextColor(scheme.effects.functionValueTextColor)
        redrawSliders()
        tabButton.redraw()
    }
    
    func changeFunctionButtonColor() {
        [presetCutoffsIconMenuItem, presetRangesIconMenuItem].forEach {$0?.reTint()}
    }

    func changeTextButtonMenuColor() {
        filterTypeMenu.redraw()
    }
    
    func changeButtonMenuTextColor() {
        filterTypeMenu.redraw()
    }
    
    func changeFunctionCaptionTextColor(_ color: NSColor) {
        functionCaptionLabels.forEach {$0.textColor = color}
    }
    
    func changeFunctionValueTextColor(_ color: NSColor) {
        lblFrequencies.textColor = color
    }
    
    func redrawSliders() {
        [cutoffSlider, freqRangeSlider].forEach {$0?.redraw()}
    }
}
