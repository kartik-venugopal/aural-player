//
//  FilterUnitViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterUnitViewController: EffectsUnitViewController {
    
    override var nibName: String? {"FilterUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var filterUnitView: FilterUnitView!
    
    private var bandControllers: [FilterBandViewController] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var filterUnit: FilterUnitDelegateProtocol = objectGraph.audioGraphDelegate.filterUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = filterUnit
        presetsWrapper = PresetsWrapper<FilterPreset, FilterPresets>(filterUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()

        let bandsDataFunction = {[weak self] in self?.filterUnit.bands ?? []}
        filterUnitView.initialize(stateFunction: unitStateFunction, bandsDataFunction: bandsDataFunction)
    }
 
    override func initControls() {

        super.initControls()
        
        bandControllers = filterUnit.bands.enumerated().map {
            
            FilterBandViewController.create(band: $1, at: $0,
                                            withButtonAction: #selector(self.showBandAction(_:)),
                                            andTarget: self)
        }
        
        filterUnitView.setBands(bandControllers.map {$0.bandView})
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func addBandAction(_ sender: AnyObject) {
        
        let newBandInfo: (band: FilterBand, index: Int) = filterUnit.addBand()
        
        let bandController = FilterBandViewController.create(band: newBandInfo.band, at: newBandInfo.index,
                                                      withButtonAction: #selector(self.showBandAction(_:)),
                                                      andTarget: self)

        bandControllers.append(bandController)
        filterUnitView.addBand(bandController.bandView, selectNewTab: true)
    }
    
    @IBAction func removeBandAction(_ sender: AnyObject) {
        
        let selectedTab = filterUnitView.selectedTab
        filterUnit.removeBand(at: selectedTab)
        
        // Remove the selected band's controller and view
        filterUnitView.removeSelectedBand()
        bandControllers.remove(at: selectedTab)
    }
    
    @IBAction func showBandAction(_ sender: NSButton) {
        filterUnitView.selectTab(at: sender.tag)
    }
    
    @IBAction func scrollTabsLeftAction(_ sender: AnyObject) {
        filterUnitView.scrollLeft()
    }
    
    @IBAction func scrollTabsRightAction(_ sender: AnyObject) {
        filterUnitView.scrollRight()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribe(to: .changeBackgroundColor, handler: filterUnitView.changeBackgroundColor(_:))
        messenger.subscribe(to: .changeTextButtonMenuColor, handler: filterUnitView.changeTextButtonMenuColor(_:))
        messenger.subscribe(to: .changeSelectedTabButtonColor, handler: filterUnitView.changeSelectedTabButtonColor(_:))
        messenger.subscribe(to: .changeTabButtonTextColor, handler: filterUnitView.changeTabButtonTextColor(_:))
        messenger.subscribe(to: .changeButtonMenuTextColor, handler: filterUnitView.changeButtonMenuTextColor(_:))
        messenger.subscribe(to: .changeSelectedTabButtonTextColor, handler: filterUnitView.changeSelectedTabButtonTextColor(_:))
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        filterUnitView.stateChanged()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    override func applyFontScheme(_ fontScheme: FontScheme) {

        super.applyFontScheme(fontScheme)
        filterUnitView.applyFontScheme(fontScheme)
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        // Need to do this to avoid multiple redundant redraw() calls
        
        changeMainCaptionTextColor(scheme.general.mainCaptionTextColor)
        
        super.changeFunctionButtonColor(scheme.general.functionButtonColor)
        super.changeFunctionCaptionTextColor(scheme.effects.functionCaptionTextColor)
        super.changeFunctionValueTextColor(scheme.effects.functionValueTextColor)
        
        super.changeActiveUnitStateColor(scheme.effects.activeUnitStateColor)
        super.changeBypassedUnitStateColor(scheme.effects.bypassedUnitStateColor)
        super.changeSuppressedUnitStateColor(scheme.effects.suppressedUnitStateColor)
        
        filterUnitView.applyColorScheme(scheme)
    }
    
    override func changeSliderColors() {
        filterUnitView.changeSliderColors()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        filterUnitView.changeActiveUnitStateColor(color)
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        filterUnitView.changeBypassedUnitStateColor(color)
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        filterUnitView.changeSuppressedUnitStateColor(color)
    }
    
    override func changeFunctionCaptionTextColor(_ color: NSColor) {
        
        super.changeFunctionCaptionTextColor(color)
        filterUnitView.changeFunctionCaptionTextColor(color)
    }
    
    override func changeFunctionValueTextColor(_ color: NSColor) {
        
        super.changeFunctionValueTextColor(color)
        filterUnitView.changeFunctionValueTextColor(color)
    }
    
    override func changeFunctionButtonColor(_ color: NSColor) {
        
        super.changeFunctionButtonColor(color)
        filterUnitView.changeFunctionButtonColor(color)
    }
}
