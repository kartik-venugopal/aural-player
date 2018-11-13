import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterViewController: FXUnitViewController {
    
    @IBOutlet weak var filterView: FilterView!
    
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
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction override func bypassAction(_ sender: AnyObject) {
        
        super.bypassAction(sender)
        filterView.refresh()
    }
    
    @IBAction func addBandAction(_ sender: AnyObject) {
        
        let bandCon = FilterBandViewController()
        bandCon.bandChangedCallback = {() -> Void in self.bandChanged()}
        bandControllers.append(bandCon)
        
        let index = filterUnit.addBand(bandCon.band)
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
        
        let btn = tabButtons.remove(at: tabButtons.count - 1)
        btn.removeFromSuperview()
        
        for index in selTab..<(bandControllers.count) {
            
            let old = bandControllers[index].bandIndex
            bandControllers[index].bandIndex = index
            print(old!, bandControllers[index].bandIndex)
        }
        
        selTab = 0
        filterView.selectTab(selTab)
        
        tabButtons.forEach({$0.state = $0.tag == selTab ? UIConstants.onState : UIConstants.offState})
        
        filterView.redrawChart()
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
    }
    
    private func bandChanged() {
        filterView.redrawChart()
    }
}
