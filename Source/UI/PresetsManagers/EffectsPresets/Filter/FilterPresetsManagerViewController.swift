//
//  FilterPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    @IBOutlet weak var filterView: FilterPresetView!
    
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
        
        tableViewDelegate.allowSelection = false
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = filterUnit.presets.object(named: presetName) {
            
            tableViewDelegate.preset = preset
            filterView.refresh()
            bandsTable.reloadData()
        }
    }
    
    private var filterChartBands: [FilterBand] {
        (firstSelectedPreset as? FilterPreset)?.bands ?? []
    }
}
