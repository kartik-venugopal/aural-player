//
//  MasterUnitView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MasterUnitView: NSView {
    
    @IBOutlet weak var btnFuseBoxMenu: NSButton!
    @IBOutlet weak var fuseBoxMenuButtonCell: FuseBoxPopupMenuCell!
    @IBOutlet weak var btnRememberSettings: EffectsUnitToggle!
    
    private lazy var messenger = Messenger(for: self)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        fxUnitStateObserverRegistry.registerObserver(fuseBoxMenuButtonCell, forFXUnit: audioGraphDelegate.masterUnit)
        fxUnitStateObserverRegistry.registerObserver(btnRememberSettings, forFXUnit: audioGraphDelegate.masterUnit)
        
        for fxUnit in audioGraphDelegate.allUnits.filter({$0.unitType != .master}) {
            doAddFuseBoxMenuItemForEffectsUnit(fxUnit)
        }
        
        messenger.subscribe(to: .Effects.audioUnitAdded, handler: doAddFuseBoxMenuItemForEffectsUnit(_:))
        messenger.subscribe(to: .Effects.audioUnitsRemoved, handler: audioUnitsRemoved(_:))
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: updateRememberSettingsButtonState)
        
        updateRememberSettingsButtonState()
    }
    
    private func updateRememberSettingsButtonState() {
        
        if let playingTrack = playbackInfoDelegate.playingTrack {
            btnRememberSettings.onIf(audioGraphDelegate.soundProfiles.hasFor(playingTrack))
        } else {
            btnRememberSettings.off()
        }
    }
    
    private func doAddFuseBoxMenuItemForEffectsUnit(_ unit: EffectsUnitDelegateProtocol) {
        
        let item = NSMenuItem(title: "")
        
        let vc = FuseViewController()
        vc.effectsUnit = unit
        
        item.view = vc.view
        btnFuseBoxMenu.menu?.addItem(item)
    }
    
    private func audioUnitsRemoved(_ indexes: IndexSet) {
        
        for index in indexes.sorted(by: {$0 > $1}) {
            
            // Adjust index for icon menu item + 6 built-in FX units.
            let adjustedIndex = index + 7
            btnFuseBoxMenu.menu?.removeItem(at: adjustedIndex)
        }
    }
    
    func redrawMenuAndToggle() {
        
        redrawFuseBoxMenu()
        redrawToggle()
    }
    
    func redrawFuseBoxMenu() {
        
        fuseBoxMenuButtonCell.unitStateChanged(to: audioGraphDelegate.masterUnit.state)
        btnFuseBoxMenu.redraw()
    }
    
    func redrawToggle() {
        btnRememberSettings.redraw(forState: audioGraphDelegate.masterUnit.state)
    }
    
    func applyPreset(_ preset: MasterPreset) {
        
//        btnEQBypass.onIf(preset.eq.state == .active)
//        btnPitchBypass.onIf(preset.pitch.state == .active)
//        btnTimeBypass.onIf(preset.time.state == .active)
//        btnReverbBypass.onIf(preset.reverb.state == .active)
//        btnDelayBypass.onIf(preset.delay.state == .active)
//        btnFilterBypass.onIf(preset.filter.state == .active)
//        
//        imgEQBypass.onIf(preset.eq.state == .active)
//        imgPitchBypass.onIf(preset.pitch.state == .active)
//        imgTimeBypass.onIf(preset.time.state == .active)
//        imgReverbBypass.onIf(preset.reverb.state == .active)
//        imgDelayBypass.onIf(preset.delay.state == .active)
//        imgFilterBypass.onIf(preset.filter.state == .active)
//        
//        lblEQ.onIf(preset.eq.state == .active)
//        lblPitch.onIf(preset.pitch.state == .active)
//        lblTime.onIf(preset.time.state == .active)
//        lblReverb.onIf(preset.reverb.state == .active)
//        lblDelay.onIf(preset.delay.state == .active)
//        lblFilter.onIf(preset.filter.state == .active)
    }
}
