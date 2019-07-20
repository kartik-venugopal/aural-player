import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterViewController: FXUnitViewController {
    
    @IBOutlet weak var filterView: FilterView!
    
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var btnScrollLeft: NSButton!
    @IBOutlet weak var btnScrollRight: NSButton!
    
    @IBOutlet weak var tabsBox: NSBox!
    private var tabButtons: [NSButton] = []
    private var bandControllers: [FilterBandViewController] = []
    private var numTabs: Int {return bandControllers.count}
    
    private var selTab: Int = -1
    
    override var nibName: String? {return "Filter"}
    
    var filterUnit: FilterUnitDelegateProtocol {return graph.filterUnit}
    
    var tabsShown: ClosedRange<Int> = (-1)...(-1)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .filter
        fxUnit = filterUnit
        unitStateFunction = filterStateFunction
        presetsWrapper = PresetsWrapper<FilterPreset, FilterPresets>(filterUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()

        let bandsDataFunction = {() -> [FilterBand] in return self.filterUnit.bands}
        filterView.initialize(filterStateFunction, bandsDataFunction, AudioGraphFilterBandsDataSource(filterUnit))
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
        
        btnScrollLeft.showIf_elseHide(numTabs > 7 && tabsShown.lowerBound > 0)
        btnScrollRight.showIf_elseHide(numTabs > 7 && tabsShown.upperBound < numTabs - 1)
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
        
        let btnWidth = bandCon.tabButton.frame.width
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
        bandCon.band = filterUnit.getBand(index)
        initBandController(bandCon, index)
        
        let btnWidth = bandCon.tabButton.frame.width
        bandCon.tabButton.setFrameOrigin(NSPoint(x: btnWidth * CGFloat(index), y: 0))
        
        // Button state
        bandCon.tabButton.state = UIConstants.offState
    }
    
    private func initBandController(_ bandCon: FilterBandViewController, _ index: Int) {
        
        bandCon.bandChangedCallback = {() -> Void in self.bandChanged()}
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
        tabButtons.forEach({$0.displaceLeft($0.frame.width)})
    }
    
    private func moveTabButtonsRight() {
        tabButtons.forEach({$0.displaceRight($0.frame.width)})
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
            tabButtons.forEach({$0.state = $0.tag == selTab ? UIConstants.onState : UIConstants.offState})
        }
    }
    
    override func changeTextSize() {

        // Need to recompute functionLabels because the view is dynamic (bands are added/removed)
        functionLabels = findFunctionLabels(self.view)
        
        bandControllers.forEach({$0.changeTextSize()})
        
        // Redraw the add/remove band buttons
        btnAdd.redraw()
        btnRemove.redraw()
        
        // Redraw the frequency chart
        filterView.changeTextSize()
        
        super.changeTextSize()
    }
    
    override func changeColorScheme() {
        
        // Need to recompute functionLabels because the view is dynamic (bands are added/removed)
        functionLabels = findFunctionLabels(self.view)
        super.changeColorScheme()

        bandControllers.forEach({$0.changeColorScheme()})
        
        btnAdd.redraw()
        btnRemove.redraw()
        
        filterView.changeColorScheme()
    }
}
