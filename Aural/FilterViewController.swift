import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterViewController: FXUnitViewController {
    
    @IBOutlet weak var filterView: FilterView!
    
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
        
//        if editor.showDialog() == .ok {
//            filterView.bandsAddedOrRemoved()
//        }
        
        let bandCon = FilterBandViewController()
        let index = filterUnit.addBand(bandCon.band)
        bandCon.bandIndex = index
        
        filterView.addBandView(bandCon.view)
    }
    
    @IBAction func removeBandAction(_ sender: AnyObject) {
        
//        if filterView.numberOfSelectedRows > 0 {
//
//            filterUnit.removeBands(filterView.selectedRows)
//            filterView.bandsRemoved()
//        }
    }
    
    @IBAction func removeAllBandsAction(_ sender: AnyObject) {
        
        filterUnit.removeAllBands()
        filterView.bandsAddedOrRemoved()
    }
}
