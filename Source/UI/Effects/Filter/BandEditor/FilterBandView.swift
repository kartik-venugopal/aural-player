//
//  FilterBandView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class FilterBandView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var lblFilterTypeCaption: NSTextField!
    @IBOutlet weak var filterTypeMenu: NSPopUpButton!
    
    @IBOutlet weak var freqRangeSlider: FilterBandSlider!
    @IBOutlet weak var cutoffSlider: FilterCutoffFrequencySlider!
    @IBOutlet weak var cutoffSliderCell: FilterCutoffFrequencySliderCell!
    
    @IBOutlet weak var lblRangeCaption: NSTextField!
    @IBOutlet weak var presetRangesMenu: NSPopUpButton!
    @IBOutlet weak var presetRangesIconMenuItem: NSMenuItem!
    
    @IBOutlet weak var lblCutoffCaption: NSTextField!
    @IBOutlet weak var presetCutoffsMenu: NSPopUpButton!
    @IBOutlet weak var presetCutoffsIconMenuItem: NSMenuItem!
    
    @IBOutlet weak var lbl20Hz: NSTextField!
    @IBOutlet weak var lbl20KHz: NSTextField!
    
    @IBOutlet weak var lblFrequencies: NSTextField!
    
    private var functionCaptionLabels: [NSTextField] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    private var filterUnit: FilterUnitDelegateProtocol = audioGraphDelegate.filterUnit
    
    private(set) var band: FilterBand = .bandPassBand(minFreq: SoundConstants.audibleRangeMin,
                                                      maxFreq: SoundConstants.audibleRangeMax) {
        
        didSet {updateFields()}
    }
    
    var bandIndex: Int = -1 {
        
        didSet {
            
            freqRangeSlider.bandIndex = bandIndex
            cutoffSlider.bandIndex = bandIndex
        }
    }
    
    private lazy var bandChangedCallback: (() -> Void) = {
        self.messenger.publish(.Effects.FilterUnit.bandUpdated, payload: self.bandIndex)
    }
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    func initialize(band: FilterBand, at index: Int) {
        
        self.band = band
        self.bandIndex = index
    }
    
    override func awakeFromNib() {
        
        oneTimeSetup()
        updateFields()
        
        fontSchemeChanged()
        colorSchemeChanged()
    }
    
    private func oneTimeSetup() {
        
        functionCaptionLabels = findFunctionCaptionLabels(under: self)
        
        freqRangeSlider.onControlChanged = {[weak self] slider in self?.freqRangeChanged()}
        
        fxUnitStateObserverRegistry.registerObserver(freqRangeSlider, forFXUnit: filterUnit)
        fxUnitStateObserverRegistry.registerObserver(cutoffSlider, forFXUnit: filterUnit)
        
        //fontSchemesManager.registerObservers([lblFilterTypeCaption, lblRangeCaption, lblCutoffCaption, lblFrequencies, lbl20Hz, lbl20KHz], forProperty: \.normalFont)
        
        //fontSchemesManager.registerObserver(filterTypeMenu, forProperty: \.normalFont)
        
//        colorSchemesManager.registerObservers([lblFilterTypeCaption, lblRangeCaption, lblCutoffCaption, lbl20Hz, lbl20KHz], forProperty: \.secondaryTextColor)
//        colorSchemesManager.registerObserver(lblFrequencies, forProperty: \.primaryTextColor)
//        
//        colorSchemesManager.registerSchemeObserver(filterTypeMenu, forProperties: [\.buttonColor, \.primaryTextColor])
//        colorSchemesManager.registerObservers([presetRangesIconMenuItem, presetCutoffsIconMenuItem], forProperty: \.buttonColor)
        
        messenger.subscribe(to: .Effects.FilterUnit.bandBypassStateUpdated, handler: bandBypassStateUpdated(bandIndex:),
                            filter: {[weak self] bandIndex in (self?.bandIndex ?? -1) == bandIndex})
        
//        presetRangesIconMenuItem.tintFunction = {Colors.functionButtonColor}
//        presetCutoffsIconMenuItem.tintFunction = {Colors.functionButtonColor}
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
    
    private func bandBypassStateUpdated(bandIndex: Int) {

        if filterUnit[bandIndex].type.equalsOneOf(.bandStop, .bandPass) {
            freqRangeSlider.redraw()
        } else {
            cutoffSlider.redraw()
        }
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
    
    func initTheme() {
        
        let smallFont = systemFontScheme.smallFont
        
        functionCaptionLabels.forEach {$0.font = smallFont}
        
        filterTypeMenu.font = smallFont
        presetRangesMenu.font = smallFont
        lblFrequencies.font = smallFont
        
        colorSchemeChanged()
    }
    
    func fontSchemeChanged() {
        
        let smallFont = systemFontScheme.smallFont
        
        functionCaptionLabels.forEach {$0.font = smallFont}
        
        filterTypeMenu.font = smallFont
        filterTypeMenu.redraw()
        
        presetRangesMenu.font = smallFont
        lblFrequencies.font = smallFont
    }
    
    func colorSchemeChanged() {

        buttonColorChanged(systemColorScheme.buttonColor)
        primaryTextColorChanged(systemColorScheme.primaryTextColor)
        secondaryTextColorChanged(systemColorScheme.secondaryTextColor)
        redrawSliders()
    }
    
    func buttonColorChanged(_ newColor: NSColor) {
        [presetCutoffsMenu, presetRangesMenu].forEach {$0?.colorChanged(newColor)}
    }

    func primaryTextColorChanged(_ newColor: NSColor) {
        
        if let popupMenuCell = filterTypeMenu.cell as? EffectsUnitPopupMenuCell {
            
            popupMenuCell.tintColor = systemColorScheme.primaryTextColor
            filterTypeMenu.redraw()
        }
        
        lblFrequencies.textColor = newColor
    }
    
    func secondaryTextColorChanged(_ newColor: NSColor) {
        functionCaptionLabels.forEach {$0.textColor = newColor}
    }
    
    func redrawSliders() {
        [cutoffSlider, freqRangeSlider].forEach {$0?.redraw()}
    }
}
