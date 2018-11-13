import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterViewController: FXUnitViewController {
    
    @IBOutlet weak var filterView: FilterView!
    
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    
    @IBOutlet weak var tabsBox: NSBox!
    private var tabButtons: [NSButton] = []
    private var bandControllers: [FilterBandViewController] = []
    
    private var selTab: Int = -1
    
    override var nibName: String? {return "Filter"}
    
    var filterUnit: FilterUnitDelegateProtocol {return graph.filterUnit}
    
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
        
        filterView.refresh()
        
        clearBands()
        for index in 0..<(filterUnit.bands.count) {
            addBandView(index)
        }
        
        if filterUnit.bands.count > 0 {
        
            tabButtons[0].state = UIConstants.onState
            filterView.selectTab(0)
            selTab = 0
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
    }
    
    private func updateCRUDButtonStates() {
        
        btnAdd.isEnabled = bandControllers.count < 31
        btnRemove.isEnabled = bandControllers.count > 0
        
        [btnAdd, btnRemove].forEach({$0?.redraw()})
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction override func bypassAction(_ sender: AnyObject) {
        
        super.bypassAction(sender)
        filterView.refresh()
    }
    
    @IBAction func addBandAction(_ sender: AnyObject) {
        
        let bandCon = FilterBandViewController()
        let index = filterUnit.addBand(bandCon.band)
        
        bandCon.bandChangedCallback = {() -> Void in self.bandChanged()}
        bandControllers.append(bandCon)
        bandCon.bandIndex = index
        
        filterView.addBandView(bandCon.view)
        bandCon.tabButton.title = String(format: "Band %d", (index + 1))
        
        tabsBox.addSubview(bandCon.tabButton)
        tabButtons.append(bandCon.tabButton)
        bandCon.tabButton.action = #selector(self.showBandAction(_:))
        bandCon.tabButton.target = self
        bandCon.tabButton.tag = index
        
        let btnWidth = bandCon.tabButton.frame.width
        bandCon.tabButton.setFrameOrigin(NSPoint(x: btnWidth * CGFloat(index), y: 0))
        
        // Button state
        tabButtons.forEach({$0.state = UIConstants.offState})
        bandCon.tabButton.state = UIConstants.onState
        
        // Button tag is the tab index
        filterView.selectTab(index)
        selTab = index
        
        filterView.redrawChart()
        updateCRUDButtonStates()
    }
    
    private func addBandView(_ index: Int) {
        
        let bandCon = FilterBandViewController()
        bandCon.band = filterUnit.getBand(index)
        
        bandCon.bandChangedCallback = {() -> Void in self.bandChanged()}
        bandControllers.append(bandCon)
        bandCon.bandIndex = index
        
        filterView.addBandView(bandCon.view)
        bandCon.tabButton.title = String(format: "Band %d", (index + 1))
        
        tabsBox.addSubview(bandCon.tabButton)
        tabButtons.append(bandCon.tabButton)
        
        bandCon.tabButton.action = #selector(self.showBandAction(_:))
        bandCon.tabButton.target = self
        bandCon.tabButton.tag = index
        
        let btnWidth = bandCon.tabButton.frame.width
        bandCon.tabButton.setFrameOrigin(NSPoint(x: btnWidth * CGFloat(index), y: 0))
        
        // Button state
        bandCon.tabButton.state = UIConstants.offState
    }
    
    @IBAction func showBandAction(_ sender: NSButton) {
        
        tabButtons.forEach({$0.state = UIConstants.offState})
        sender.state = UIConstants.onState
        
        filterView.selectTab(sender.tag)
        selTab = sender.tag
    }
    
    @IBAction func removeBandAction(_ sender: AnyObject) {
        
        filterUnit.removeBands(IndexSet([selTab]))
        filterView.removeTab(selTab)
        bandControllers.remove(at: selTab)
        tabButtons.remove(at: tabButtons.count - 1).removeFromSuperview()
        
        for index in selTab..<(bandControllers.count) {
            bandControllers[index].bandIndex = index
        }
        
        selTab = !bandControllers.isEmpty ? 0 : -1
        if !bandControllers.isEmpty {filterView.selectTab(selTab)}
        
        tabButtons.forEach({$0.state = $0.tag == selTab ? UIConstants.onState : UIConstants.offState})
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
}
