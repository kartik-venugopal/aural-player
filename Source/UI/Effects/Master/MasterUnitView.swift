//
//  MasterUnitView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
    
    private var fuseVCs: [FuseViewController] = []
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        fxUnitStateObserverRegistry.registerObservers([fuseBoxMenuButtonCell, btnRememberSettings], forFXUnit: audioGraph.masterUnit)
        
        for fxUnit in audioGraph.allUnits.filter({$0.unitType != .master}) {
            doAddFuseBoxMenuItemForEffectsUnit(fxUnit)
        }
        
        messenger.subscribe(to: .Effects.audioUnitAdded, handler: doAddFuseBoxMenuItemForEffectsUnit(_:))
        messenger.subscribe(to: .Effects.audioUnitsRemoved, handler: audioUnitsRemoved(_:))
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: updateRememberSettingsButtonState)
        
        updateRememberSettingsButtonState()
    }
    
    private func updateRememberSettingsButtonState() {
        
        if let playingTrack = player.playingTrack {
            btnRememberSettings.onIf(audioGraph.soundProfiles.hasFor(playingTrack))
        } else {
            btnRememberSettings.off()
        }
    }
    
    private func doAddFuseBoxMenuItemForEffectsUnit(_ unit: EffectsUnitProtocol) {
        
        let item = NSMenuItem(title: "")
        
        let vc = FuseViewController()
        fuseVCs.append(vc)
        vc.effectsUnit = unit
        
        item.view = vc.view
        btnFuseBoxMenu.menu?.addItem(item)
    }
    
    private func audioUnitsRemoved(_ indexes: IndexSet) {
        
        for index in indexes.sorted(by: >) {
            
            // TODO: Replay Gain has been disabled, so now it's 6 built-in units.
            // // Adjust index for icon menu item + 7 built-in FX units.
            
            // Adjust index for icon menu item + 6 built-in FX units.
            let adjustedIndex = index + 6
            btnFuseBoxMenu.menu?.removeItem(at: adjustedIndex)
            fuseVCs.remove(at: adjustedIndex).destroy()
        }
    }
    
    func redrawMenuAndToggle() {
        
        redrawFuseBoxMenu()
        redrawToggle()
    }
    
    func redrawFuseBoxMenu() {
        
        fuseBoxMenuButtonCell.unitStateChanged(to: audioGraph.masterUnit.state)
        btnFuseBoxMenu.redraw()
    }
    
    func redrawToggle() {
        btnRememberSettings.redraw(forState: audioGraph.masterUnit.state)
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
