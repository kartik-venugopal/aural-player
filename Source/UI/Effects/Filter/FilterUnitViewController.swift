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
    
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var btnScrollLeft: TintedImageButton!
    @IBOutlet weak var btnScrollRight: TintedImageButton!
    
    @IBOutlet weak var tabsBox: NSBox!
    private var tabButtons: [NSButton] = []
    private var bandControllers: [FilterBandViewController] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var filterUnit: FilterUnitDelegateProtocol = objectGraph.audioGraphDelegate.filterUnit
    
    private var numTabs: Int {bandControllers.count}
    private var selTab: Int = -1
    private var tabsShown: ClosedRange<Int> = (-1)...(-1)
    
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
        
        clearBands()
        let numBands = filterUnit.bands.count
        
        for index in 0..<numBands {
            addBandView(at: index)
        }
        
        if numBands > 0 {
            
            selectTab(at: 0)
            tabsShown = 0...(min(numTabs - 1, 6))
        }
        
        updateCRUDButtonStates()
    }
    
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
        
        filterUnitView.refresh()
        bandControllers.forEach {$0.stateChanged()}
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func addBandAction(_ sender: AnyObject) {
        
        let bandCon = FilterBandViewController()
        let index = filterUnit.addBand(bandCon.band)
        initBandController(bandCon, at: index)
        
        let btnWidth = bandCon.tabButton.width
        let prevBtnX = index == 0 ? 0 : tabButtons[index - 1].frame.minX + btnWidth
        bandCon.tabButton.setFrameOrigin(NSPoint(x: prevBtnX, y: 0))
        
        // Button tag is the tab index
        selectTab(at: index)
        filterUnitView.redrawChart()
        updateCRUDButtonStates()
        
        // Show new tab
        if index >= maxShownBands {
            
            for _ in 0..<(index - tabsShown.upperBound) {
                scrollRight()
            }
            
        } else {
            tabsShown = 0...index
        }
    }
    
    @IBAction func removeBandAction(_ sender: AnyObject) {
        
        filterUnit.removeBands(atIndices: IndexSet([selTab]))
        
        // Remove the selected band's controller and view
        filterUnitView.removeTab(at: selTab)
        bandControllers.remove(at: selTab)
        
        // Remove the last tab button (bands count has decreased by 1)
        tabButtons.remove(at: tabButtons.lastIndex).removeFromSuperview()
        
        for index in selTab..<numTabs {
            
            // Reassign band indexes to controllers
            bandControllers[index].bandIndex = index
            
            // Reassign tab buttons to controllers
            bandControllers[index].tabButton = tabButtons[index]
        }
        
        selectTab(at: !bandControllers.isEmpty ? 0 : -1)
        
        // Show tab 0
        for _ in 0..<tabsShown.lowerBound {
            scrollLeft()
        }
        
        filterUnitView.redrawChart()
        updateCRUDButtonStates()
    }
    
    @IBAction func showBandAction(_ sender: NSButton) {
        selectTab(at: sender.tag)
    }
    
    @IBAction func scrollTabsLeftAction(_ sender: AnyObject) {
        
        scrollLeft()
        
        if !tabsShown.contains(selTab) {
            selectTab(at: tabsShown.lowerBound)
        }
    }
    
    @IBAction func scrollTabsRightAction(_ sender: AnyObject) {
        
        scrollRight()
        
        if !tabsShown.contains(selTab) {
            selectTab(at: tabsShown.lowerBound)
        }
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Helper functions
    
    private let maxNumBands: Int = 31
    private let maxShownBands: Int = 7
    
    private func clearBands() {
        
        bandControllers.removeAll()
        
        tabButtons.forEach {$0.removeFromSuperview()}
        tabButtons.removeAll()
        
        filterUnitView.removeAllTabs()
        selTab = -1
        
        updateCRUDButtonStates()
        tabsShown = (-1)...(-1)
    }
    
    private func updateCRUDButtonStates() {
        
        btnAdd.isEnabled = numTabs < maxNumBands
        btnRemove.isEnabled = numTabs > 0
        
        [btnAdd, btnRemove].forEach {$0?.redraw()}
        
        let overflow: Bool = numTabs > maxShownBands
        btnScrollLeft.showIf(overflow && tabsShown.lowerBound > 0)
        btnScrollRight.showIf(overflow && tabsShown.upperBound < numTabs - 1)
    }
    
    private func addBandView(at index: Int) {
        
        let bandCon = FilterBandViewController()
        bandCon.band = filterUnit[index]
        initBandController(bandCon, at: index)
        
        let btnWidth = bandCon.tabButton.width
        bandCon.tabButton.setFrameOrigin(NSPoint(x: btnWidth * CGFloat(index), y: 0))
        
        // Button state
        bandCon.tabButton.state = .off
    }
    
    private func initBandController(_ bandCon: FilterBandViewController, at index: Int) {
        
        bandCon.bandChangedCallback = bandChanged
        bandControllers.append(bandCon)
        bandCon.bandIndex = index
        
        filterUnitView.addBandView(bandCon.view)
        bandCon.tabButton.title = String(format: "#%d", (index + 1))
        
        tabsBox.addSubview(bandCon.tabButton)
        tabButtons.append(bandCon.tabButton)
        
        bandCon.tabButton.action = #selector(self.showBandAction(_:))
        bandCon.tabButton.target = self
        bandCon.tabButton.tag = index
    }
    
    private func moveTabButtonsLeft() {
        tabButtons.forEach {$0.moveLeft(distance: $0.width)}
    }
    
    private func moveTabButtonsRight() {
        tabButtons.forEach {$0.moveRight(distance: $0.width)}
    }
    
    private func bandChanged() {
        filterUnitView.redrawChart()
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
    
    private func selectTab(at index: Int) {
        
        if index >= 0 {
            
            selTab = index
            filterUnitView.selectTab(at: index)
            tabButtons.forEach {$0.state = $0.tag == selTab ? .on : .off}
        }
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        
        bandControllers.forEach {$0.applyFontScheme(fontScheme)}
        
        // Redraw the add/remove band buttons
        btnAdd.redraw()
        btnRemove.redraw()
        
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
        
        [btnAdd, btnRemove].forEach {$0?.redraw()}
        [btnScrollLeft, btnScrollRight].forEach {$0?.reTint()}
        
        bandControllers.forEach {$0.applyColorScheme(scheme)}
    }
    
    func changeBackgroundColor(_ color: NSColor) {
        filterUnitView.redrawChart()
    }
    
    override func changeSliderColors() {
        bandControllers.forEach {$0.redrawSliders()}
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        bandControllers.forEach {$0.redrawSliders()}
        filterUnitView.redrawChart()
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        bandControllers.forEach {$0.redrawSliders()}
        filterUnitView.redrawChart()
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        bandControllers.forEach {$0.redrawSliders()}
        filterUnitView.redrawChart()
    }
    
    override func changeFunctionCaptionTextColor(_ color: NSColor) {
        
        super.changeFunctionCaptionTextColor(color)
        bandControllers.forEach {$0.changeFunctionCaptionTextColor(color)}
    }
    
    override func changeFunctionValueTextColor(_ color: NSColor) {
        
        super.changeFunctionValueTextColor(color)
        bandControllers.forEach {$0.changeFunctionValueTextColor(color)}
    }
    
    override func changeFunctionButtonColor(_ color: NSColor) {
        
        super.changeFunctionButtonColor(color)
        
        [btnScrollLeft, btnScrollRight].forEach {$0?.reTint()}
        bandControllers.forEach {$0.changeFunctionButtonColor()}
    }
    
    func changeTextButtonMenuColor(_ color: NSColor) {
        
        [btnAdd, btnRemove].forEach {$0?.redraw()}
        bandControllers.forEach {$0.changeTextButtonMenuColor()}
    }

    func changeButtonMenuTextColor(_ color: NSColor) {
        
        [btnAdd, btnRemove].forEach {$0?.redraw()}
        bandControllers.forEach {$0.changeButtonMenuTextColor()}
    }
    
    func changeSelectedTabButtonColor(_ color: NSColor) {
        
        if (0..<numTabs).contains(selTab) {
            tabButtons[selTab].redraw()
        }
    }
    
    func changeTabButtonTextColor(_ color: NSColor) {
        tabButtons.forEach {$0.redraw()}
    }
    
    func changeSelectedTabButtonTextColor(_ color: NSColor) {
        
        if (0..<numTabs).contains(selTab) {
            tabButtons[selTab].redraw()
        }
    }
}
