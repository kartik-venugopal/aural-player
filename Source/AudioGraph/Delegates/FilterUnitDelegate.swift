import AVFoundation

class FilterUnitDelegate: FXUnitDelegate<FilterUnit>, FilterUnitDelegateProtocol {

    var presets: FilterPresets {return unit.presets}
    
    var bands: [FilterBand] {
        
        get {unit.bands}
        set {unit.bands = newValue}
    }
    
    func addBand(_ band: FilterBand) -> Int {
        return unit.addBand(band)
    }
    
    func updateBand(_ index: Int, _ band: FilterBand) {
        unit.updateBand(index, band)
    }
    
    func removeBands(_ indexSet: IndexSet) {
        unit.removeBands(indexSet)
    }
    
    func removeAllBands() {
        unit.removeAllBands()
    }
    
    func getBand(_ index: Int) -> FilterBand {
        return unit.getBand(index)
    }
}
