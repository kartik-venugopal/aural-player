//
//  EffectsUnitDelegate.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// An abstract delegate representing an effects unit.
///
/// Acts as a middleman between the Effects UI and an effects unit,
/// providing a simplified interface / facade for the UI layer to control an effects unit.
///
/// No instances of this type are to be used directly, as this class is only intended to be used as a base
/// class for concrete effects units delegates.
///
/// - SeeAlso: `EffectsUnitDelegateProtocol`
/// - SeeAlso: `EffectsUnit`
///
class EffectsUnitDelegate<T: EffectsUnitProtocol>: EffectsUnitDelegateProtocol {
    
    var unit: T
    
    private var kvoTokens: Set<NSKeyValueObservation> = Set()
    
    init(for unit: T) {
        self.unit = unit
    }
    
    deinit {
        
        kvoTokens.forEach {$0.invalidate()}
        kvoTokens.removeAll()
    }
    
    var unitType: EffectsUnitType {unit.unitType}
    
    var state: EffectsUnitState {unit.state}
    
    var stateFunction: EffectsUnitStateFunction {unit.stateFunction}
    
    var isActive: Bool {unit.isActive}
    
    @discardableResult func toggleState() -> EffectsUnitState {
        unit.toggleState()
    }
    
    func ensureActive() {
        unit.ensureActive()
    }
    
    var renderQuality: Int {
        
        get {unit.renderQuality}
        set {unit.renderQuality = newValue}
    }
    
    func savePreset(named presetName: String) {
        unit.savePreset(named: presetName)
    }
    
    // FIXME: Ensure unit active.
    func applyPreset(named presetName: String) {
        
        unit.applyPreset(named: presetName)
//        unit.ensureActive()
    }
    
    func observeState(handler: @escaping EffectsUnitStateChangeHandler) -> NSKeyValueObservation {
        
        let newToken = (unit as! EffectsUnit).observe(\.state, options: [.initial, .new]) {unit,_ in
            handler(unit.state)
        }
        
        kvoTokens.insert(newToken)
        return newToken
    }
    
    func removeObserver(_ observer: NSKeyValueObservation) {
        kvoTokens.remove(observer)?.invalidate()
    }
}
