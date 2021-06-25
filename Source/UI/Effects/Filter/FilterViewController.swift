//
//  FilterViewController.swift
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
class FilterViewController: EffectsUnitViewController {
    
    @IBOutlet weak var filterView: FilterView!
    
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var btnScrollLeft: TintedImageButton!
    @IBOutlet weak var btnScrollRight: TintedImageButton!
    
    @IBOutlet weak var tabsBox: NSBox!
    private var tabButtons: [NSButton] = []
    private var bandControllers: [FilterBandViewController] = []
    private var numTabs: Int {bandControllers.count}
    
    private var selTab: Int = -1
    
    override var nibName: String? {"Filter"}
    
    var filterUnit: FilterUnitDelegateProtocol {graph.filterUnit}
    
    var tabsShown: ClosedRange<Int> = (-1)...(-1)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .filter
        effectsUnit = filterUnit
        presetsWrapper = PresetsWrapper<FilterPreset, FilterPresets>(filterUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()

        let bandsDataFunction = {[weak self] () -> [FilterBand] in return self?.filterUnit.bands ?? []}
        filterView.initialize(self.unitStateFunction, bandsDataFunction, AudioGraphFilterBandsDataSource(filterUnit))
    }
 
    override func initControls() {

        super.initControls()
        
        clearBands()
        let numBands = filterUnit.bands.count
        
        for index in 0..<numBands {
            addBandView(index)
        }
        
        if numBands > 0 {
            selectTab(0)
            tabsShown = 0...(min(numTabs - 1, 6))
        }
        
        updateCRUDButtonStates()
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        Messenger.subscribe(self, .changeBackgroundColor, self.changeBackgroundColor(_:))
        Messenger.subscribe(self, .changeTextButtonMenuColor, self.changeTextButtonMenuColor(_:))
        Messenger.subscribe(self, .changeSelectedTabButtonColor, self.changeSelectedTabButtonColor(_:))
        Messenger.subscribe(self, .changeTabButtonTextColor, self.changeTabButtonTextColor(_:))
        Messenger.subscribe(self, .changeButtonMenuTextColor, self.changeButtonMenuTextColor(_:))
        Messenger.subscribe(self, .changeSelectedTabButtonTextColor, self.changeSelectedTabButtonTextColor(_:))
    }
    
    private func clearBands() {
        
        bandControllers.removeAll()
        
        tabButtons.forEach({$0.removeFromSuperview()})
        tabButtons.removeAll()
        
        filterView.removeAllTabs()
        selTab = -1
        
        updateCRUDButtonStates()
        tabsShown = (-1)...(-1)
    }
    
    private func updateCRUDButtonStates() {
        
        btnAdd.isEnabled = numTabs < 31
        btnRemove.isEnabled = numTabs > 0
        
        [btnAdd, btnRemove].forEach({$0?.redraw()})
        
        btnScrollLeft.showIf(numTabs > 7 && tabsShown.lowerBound > 0)
        btnScrollRight.showIf(numTabs > 7 && tabsShown.upperBound < numTabs - 1)
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        filterView.refresh()
        bandControllers.forEach({$0.stateChanged()})
    }
    
    @IBAction func addBandAction(_ sender: AnyObject) {
        
        let bandCon = FilterBandViewController()
        let index = filterUnit.addBand(bandCon.band)
        initBandController(bandCon, index)
        
        let btnWidth = bandCon.tabButton.width
        let prevBtnX = index == 0 ? 0 : tabButtons[index - 1].frame.origin.x + btnWidth
        bandCon.tabButton.setFrameOrigin(NSPoint(x: prevBtnX, y: 0))
        
        // Button tag is the tab index
        selectTab(index)
        filterView.redrawChart()
        updateCRUDButtonStates()
        
        // Show new tab
        if index >= 7 {
            
            for _ in 0..<(index - tabsShown.upperBound) {
                scrollRight()
            }
            
        } else {
            tabsShown = 0...index
        }
    }
    
    private func addBandView(_ index: Int) {
        
        let bandCon = FilterBandViewController()
        bandCon.band = filterUnit[index]
        initBandController(bandCon, index)
        
        let btnWidth = bandCon.tabButton.width
        bandCon.tabButton.setFrameOrigin(NSPoint(x: btnWidth * CGFloat(index), y: 0))
        
        // Button state
        bandCon.tabButton.state = .off
    }
    
    private func initBandController(_ bandCon: FilterBandViewController, _ index: Int) {
        
        bandCon.bandChangedCallback = {[weak self] () -> Void in self?.bandChanged()}
        bandControllers.append(bandCon)
        bandCon.bandIndex = index
        
        filterView.addBandView(bandCon.view)
        bandCon.tabButton.title = String(format: "#%d", (index + 1))
        
        tabsBox.addSubview(bandCon.tabButton)
        tabButtons.append(bandCon.tabButton)
        
        bandCon.tabButton.action = #selector(self.showBandAction(_:))
        bandCon.tabButton.target = self
        bandCon.tabButton.tag = index
    }
    
    @IBAction func showBandAction(_ sender: NSButton) {
        selectTab(sender.tag)
    }
    
    @IBAction func removeBandAction(_ sender: AnyObject) {
        
        filterUnit.removeBands(IndexSet([selTab]))
        
        // Remove the selected band's controller and view
        filterView.removeTab(selTab)
        bandControllers.remove(at: selTab)
        
        // Remove the last tab button (bands count has decreased by 1)
        tabButtons.remove(at: tabButtons.count - 1).removeFromSuperview()
        
        for index in selTab..<numTabs {
            
            // Reassign band indexes to controllers
            bandControllers[index].bandIndex = index
            
            // Reassign tab buttons to controllers
            bandControllers[index].tabButton = tabButtons[index]
        }
        
        selectTab(!bandControllers.isEmpty ? 0 : -1)
        
        // Show tab 0
        for _ in 0..<tabsShown.lowerBound {
            scrollLeft()
        }
        
        filterView.redrawChart()
        updateCRUDButtonStates()
    }
    
    private func moveTabButtonsLeft() {
        tabButtons.forEach({$0.displaceLeft($0.width)})
    }
    
    private func moveTabButtonsRight() {
        tabButtons.forEach({$0.displaceRight($0.width)})
    }
    
    @IBAction func removeAllBandsAction(_ sender: AnyObject) {
        
        filterUnit.removeAllBands()
        filterView.bandsAddedOrRemoved()
        updateCRUDButtonStates()
    }
    
    private func bandChanged() {
        filterView.redrawChart()
    }
    
    @IBAction func scrollTabsLeftAction(_ sender: AnyObject) {
        
        scrollLeft()
        
        if !tabsShown.contains(selTab) {
            selectTab(tabsShown.lowerBound)
        }
    }
    
    @IBAction func scrollTabsRightAction(_ sender: AnyObject) {
        
        scrollRight()
        
        if !tabsShown.contains(selTab) {
            selectTab(tabsShown.lowerBound)
        }
    }
    
    private func scrollLeft() {
        
        if tabsShown.lowerBound > 0 {
            moveTabButtonsRight()
            tabsShown = (tabsShown.lowerBound - 1)...(tabsShown.upperBound - 1)
            updateCRUDButtonStates()
        }
    }
    
    private func scrollRight() {
        
        if tabsShown.upperBound < numTabs - 1 {
            moveTabButtonsLeft()
            tabsShown = (tabsShown.lowerBound + 1)...(tabsShown.upperBound + 1)
            updateCRUDButtonStates()
        }
    }
    
    private func selectTab(_ index: Int) {
        
        if index >= 0 {
            
            selTab = index
            filterView.selectTab(index)
            tabButtons.forEach {$0.state = $0.tag == selTab ? .on : .off}
        }
    }
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        
        bandControllers.forEach {$0.applyFontScheme(fontScheme)}
        
        // Redraw the add/remove band buttons
        btnAdd.redraw()
        btnRemove.redraw()
        
        // Redraw the frequency chart
        filterView.applyFontScheme(fontScheme)
        
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
        
        filterView.redrawChart()
        
        [btnAdd, btnRemove].forEach({$0?.redraw()})
        [btnScrollLeft, btnScrollRight].forEach({$0?.reTint()})
        
        bandControllers.forEach({$0.applyColorScheme(scheme)})
    }
    
    func changeBackgroundColor(_ color: NSColor) {
        filterView.redrawChart()
    }
    
    override func changeSliderColors() {
        bandControllers.forEach({$0.redrawSliders()})
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        bandControllers.forEach({$0.redrawSliders()})
        filterView.redrawChart()
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        bandControllers.forEach({$0.redrawSliders()})
        filterView.redrawChart()
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        bandControllers.forEach({$0.redrawSliders()})
        filterView.redrawChart()
    }
    
    override func changeFunctionCaptionTextColor(_ color: NSColor) {
        
        super.changeFunctionCaptionTextColor(color)
        bandControllers.forEach({$0.changeFunctionCaptionTextColor(color)})
    }
    
    override func changeFunctionValueTextColor(_ color: NSColor) {
        
        super.changeFunctionValueTextColor(color)
        bandControllers.forEach({$0.changeFunctionValueTextColor(color)})
    }
    
    override func changeFunctionButtonColor(_ color: NSColor) {
        
        super.changeFunctionButtonColor(color)
        
        [btnScrollLeft, btnScrollRight].forEach({$0?.reTint()})
        bandControllers.forEach({$0.changeFunctionButtonColor()})
    }
    
    func changeTextButtonMenuColor(_ color: NSColor) {
        
        [btnAdd, btnRemove].forEach({$0?.redraw()})
        bandControllers.forEach({$0.changeTextButtonMenuColor()})
    }

    func changeButtonMenuTextColor(_ color: NSColor) {
        
        [btnAdd, btnRemove].forEach({$0?.redraw()})
        bandControllers.forEach({$0.changeButtonMenuTextColor()})
    }
    
    func changeSelectedTabButtonColor(_ color: NSColor) {
        
        if selTab >= 0 && selTab < numTabs {
            tabButtons[selTab].redraw()
        }
    }
    
    func changeTabButtonTextColor(_ color: NSColor) {
        tabButtons.forEach({$0.redraw()})
    }
    
    func changeSelectedTabButtonTextColor(_ color: NSColor) {
        
        if selTab >= 0 && selTab < numTabs {
            tabButtons[selTab].redraw()
        }
    }
}
