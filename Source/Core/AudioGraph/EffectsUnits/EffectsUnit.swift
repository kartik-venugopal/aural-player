//
//  EffectsUnit.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An abstract representation of (base class for) an effects unit that processes audio. It contains
/// properties and functions common to all effects units - eg. unit state.
///
/// No instances of this type are to be used directly, as this class is only intended to be used as a base
/// class for concrete effects unit classes.
///
class EffectsUnit: NSObject {
    
    var unitType: EffectsUnitType
    
    var masterUnit: MasterUnit {
        audioGraph.masterUnit
    }
    
    @objc dynamic var state: EffectsUnitState {
        didSet {stateChanged()}
    }
    
    var stateFunction: EffectsUnitStateFunction {
        {self.state}
    }
    
    private var stateChangeRequiresNotification: Bool = true
    
    // Intended to be overriden by subclasses.
    var avNodes: [AVAudioNode] {[]}
    
    var renderQuality: Int {
        
        get {avNodes.first?.auAudioUnit.renderQuality ?? 0}
        
        set {
            
            avNodes.compactMap {$0.auAudioUnit}.forEach {
                $0.renderQuality = newValue
            }
        }
    }
    
    var renderQualityPersistentState: Int? {
        self.renderQuality
    }
    
    var isActive: Bool {state == .active}
    
    lazy var messenger = Messenger(for: self)
    
    var unitInitialized: Bool = false
    
    init(unitType: EffectsUnitType, unitState: EffectsUnitState, renderQuality: Int? = nil) {
        
        self.unitType = unitType
        self.state = unitState
        
        super.init()
        stateChanged()
        
        self.renderQuality = renderQuality ?? AudioGraphDefaults.renderQuality
    }
    
    func stateChanged() {
        
        if stateChangeRequiresNotification, isActive, unitType != .master {
            messenger.publish(.Effects.unitActivated)
        }
    }
    
    // Toggles the state of the effects unit, and returns its new state
    func toggleState() -> EffectsUnitState {
        
        state = state == .active ? .bypassed : .active
        
        // If this is the Master unit, toggling state does not invalidate its own current preset.
        if self.unitType != .master {
            masterUnit.currentPreset = nil
        }
        
        return state
    }
    
    func ensureActive() {
        
        if !isActive {
            _ = toggleState()
        }
    }
    
    func suppress() {
        
        if state == .active {
            
            // FIXME - Must call stateChanged() here, but somehow prevent the message
            // from being published.
            changeStateWithoutNotifying(to: .suppressed)
        }
    }
    
    func unsuppress() {
        
        if state == .suppressed {
            
            // FIXME - Must call stateChanged() here, but somehow prevent the message
            // from being published.
            changeStateWithoutNotifying(to: .active)
        }
    }
    
    private func changeStateWithoutNotifying(to newState: EffectsUnitState) {
        
        stateChangeRequiresNotification = false
        state = newState
        stateChangeRequiresNotification = true
    }
    
    // Intended to be overriden by subclasses.
    func reset() {}
    
    // Intended to be overriden by subclasses.
    func savePreset(named presetName: String) {}
    
    // Intended to be overriden by subclasses.
    func applyPreset(named presetName: String) {}
}
