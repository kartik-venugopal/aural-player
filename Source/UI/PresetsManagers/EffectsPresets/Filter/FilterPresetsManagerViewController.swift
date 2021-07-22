//
//  FilterPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    @IBOutlet weak var filterView: FilterUnitView!
    private var bandsDataSource: PresetFilterBandsDataSource = PresetFilterBandsDataSource()
    
    @IBOutlet weak var bandsTable: NSTableView!
    @IBOutlet weak var tableViewDelegate: FilterBandsViewDelegate!
    
    override var nibName: String? {"FilterPresetsManager"}
    
    var filterUnit: FilterUnitDelegateProtocol = objectGraph.audioGraphDelegate.filterUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .filter
        effectsUnit = filterUnit
        presetsWrapper = PresetsWrapper<FilterPreset, FilterPresets>(filterUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let bandsDataFunction = {[weak self] in self?.filterChartBands ?? []}
        
        filterView.initialize(stateFunction: {.active}, bandsDataFunction: bandsDataFunction)
        
        tableViewDelegate.dataSource = bandsDataSource
        tableViewDelegate.allowSelection = false
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = filterUnit.presets.preset(named: presetName) {
            
            bandsDataSource.preset = preset
            filterView.refresh()
            bandsTable.reloadData()
        }
    }
    
    private var filterChartBands: [FilterBand] {
        
        if let preset = firstSelectedPreset as? FilterPreset {
            return preset.bands
        }
        
        return []
    }
}

class PresetFilterBandsDataSource: FilterBandsDataSource {
    
    var preset: FilterPreset?
    
    func countFilterBands() -> Int {
        preset?.bands.count ?? 0
    }
    
    func getFilterBand(_ index: Int) -> FilterBand {
        preset!.bands[index]
    }
}
