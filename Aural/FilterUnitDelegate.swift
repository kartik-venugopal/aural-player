import AVFoundation

class FilterUnitDelegate: FXUnitDelegate<FilterUnit> {

    var presets: FilterPresets {return unit.presets}
    
    override init(_ unit: FilterUnit) {
        super.init(unit)
    }
    
    var bands: [FilterBand] {
        
        get {return unit.bands}
        set(newValue) {unit.bands = newValue}
    }
    
    func addFilterBand(_ band: FilterBand) -> Int {
        return unit.addFilterBand(band)
    }
    
    func updateFilterBand(_ index: Int, _ band: FilterBand) {
        unit.updateFilterBand(index, band)
    }
    
    func removeFilterBands(_ indexSet: IndexSet) {
        unit.removeFilterBands(indexSet)
    }
    
    func removeAllFilterBands() {
        unit.removeAllFilterBands()
    }
    
    func getFilterBand(_ index: Int) -> FilterBand {
        return unit.getFilterBand(index)
    }
    
    func saveFilterPreset(_ presetName: String) {
        unit.saveFilterPreset(presetName)
    }
    
    func applyFilterPreset(_ presetName: String) {
        unit.applyFilterPreset(presetName)
    }
}
