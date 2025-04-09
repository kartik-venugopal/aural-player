//
//  ReplayGainUnitViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class ReplayGainUnitViewController: EffectsUnitViewController {
    
    override var nibName: NSNib.Name? {"ReplayGainUnit"}
    
    // ------------------------------------------------------------------------
    
    @IBOutlet weak var replayGainUnitView: ReplayGainUnitView!
    
    var replayGainUnit: ReplayGainUnitProtocol = audioGraph.replayGainUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        fxUnitStateObserverRegistry.registerObservers(replayGainUnitView.unitStateObservers, forFXUnit: replayGainUnit)
    }
    
    override func initControls() {
        
        super.initControls()
        
        replayGainUnitView.initialize(modeDescription: replayGainUnit.mode.description,
                                      preAmp: replayGainUnit.preAmp,
                                      isScanning: replayGainUnit.isScanning,
                                      preventClipping: replayGainUnit.preventClipping,
                                      appliedGain: replayGainUnit.appliedGain,
                                      appliedGainType: replayGainUnit.appliedGainType)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: initControls)
        messenger.subscribeAsync(to: .Effects.ReplayGainUnit.scanInitiated, handler: scanInitiated)
        messenger.subscribeAsync(to: .Effects.ReplayGainUnit.scanCompleted, handler: scanCompleted)
    }
    
    private func scanInitiated() {
        replayGainUnitView.scanInitiated(scanStatus: replayGainUnit.scanStatus)
    }
    
    private func scanCompleted() {
        
        replayGainUnitView.scanCompleted(appliedGain: replayGainUnit.appliedGain,
                                         appliedGainType: replayGainUnit.appliedGainType)
    }
}

extension ReplayGainUnitViewController {
    
    override func menuNeedsUpdate(_ menu: NSMenu) {
        
        super.menuNeedsUpdate(menu)
        
        replayGainUnitView.updateMenu(dataSource: replayGainUnit.dataSource,
                                      maxPeakLevel: replayGainUnit.maxPeakLevel)
    }
}
