//
//  FilterUnitViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
        addBandView(for: newBandInfo.band, at: newBandInfo.index)
    }
    
    @IBAction func removeBandAction(_ sender: AnyObject) {
        
        let selectedTab = filterUnitView.selectedTab
        filterUnit.removeBands(atIndices: IndexSet([selectedTab]))
        
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
    
    // MARK: Helper functions
    
    private func addBandView(for band: FilterBand, at index: Int) {
        
        let bandCon = FilterBandViewController.create(band: band, at: index,
                                                      withButtonAction: #selector(self.showBandAction(_:)),
                                                      andTarget: self)
        
        filterUnitView.addBand(bandCon.bandView, selectNewTab: true)
        bandControllers.append(bandCon)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribe(to: .changeBackgroundColor, handler: changeBackgroundColor(_:))
        messenger.subscribe(to: .changeTextButtonMenuColor, handler: changeTextButtonMenuColor(_:))
        messenger.subscribe(to: .changeSelectedTabButtonColor, handler: changeSelectedTabButtonColor(_:))
        messenger.subscribe(to: .changeTabButtonTextColor, handler: changeTabButtonTextColor(_:))
        messenger.subscribe(to: .changeButtonMenuTextColor, handler: changeButtonMenuTextColor(_:))
        messenger.subscribe(to: .changeSelectedTabButtonTextColor, handler: changeSelectedTabButtonTextColor(_:))
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        filterUnitView.stateChanged()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        
//        bandControllers.forEach {$0.applyFontScheme(fontScheme)}
      
        // Redraw the frequency chart
        filterUnitView.applyFontScheme(fontScheme)
        
        super.applyFontScheme(fontScheme)
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
        
        filterUnitView.redrawChart()
//        bandControllers.forEach {$0.applyColorScheme(scheme)}
    }
    
    func changeBackgroundColor(_ color: NSColor) {
        filterUnitView.redrawChart()
    }
    
    override func changeSliderColors() {
//        bandControllers.forEach {$0.redrawSliders()}
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
//        bandControllers.forEach {$0.redrawSliders()}
        filterUnitView.redrawChart()
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
//        bandControllers.forEach {$0.redrawSliders()}
        filterUnitView.redrawChart()
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
//        bandControllers.forEach {$0.redrawSliders()}
        filterUnitView.redrawChart()
    }
    
    override func changeFunctionCaptionTextColor(_ color: NSColor) {
        
        super.changeFunctionCaptionTextColor(color)
//        bandControllers.forEach {$0.changeFunctionCaptionTextColor(color)}
    }
    
    override func changeFunctionValueTextColor(_ color: NSColor) {
        
        super.changeFunctionValueTextColor(color)
//        bandControllers.forEach {$0.changeFunctionValueTextColor(color)}
    }
    
    override func changeFunctionButtonColor(_ color: NSColor) {
        
        super.changeFunctionButtonColor(color)
        
//        [btnScrollLeft, btnScrollRight].forEach {$0?.reTint()}
//        bandControllers.forEach {$0.changeFunctionButtonColor()}
    }
    
    func changeTextButtonMenuColor(_ color: NSColor) {
        
//        [btnAdd, btnRemove].forEach {$0?.redraw()}
//        bandControllers.forEach {$0.changeTextButtonMenuColor()}
    }

    func changeButtonMenuTextColor(_ color: NSColor) {
        
//        [btnAdd, btnRemove].forEach {$0?.redraw()}
//        bandControllers.forEach {$0.changeButtonMenuTextColor()}
    }
    
    func changeSelectedTabButtonColor(_ color: NSColor) {
        
//        if (0..<numTabs).contains(selTab) {
//            tabButtons[selTab].redraw()
//        }
    }
    
    func changeTabButtonTextColor(_ color: NSColor) {
//        tabButtons.forEach {$0.redraw()}
    }
    
    func changeSelectedTabButtonTextColor(_ color: NSColor) {
        
//        if (0..<numTabs).contains(selTab) {
//            tabButtons[selTab].redraw()
//        }
    }
}
