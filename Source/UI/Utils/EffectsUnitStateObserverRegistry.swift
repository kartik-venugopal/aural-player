//
//  EffectsUnitStateObserverRegistry.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import Cocoa

class EffectsUnitStateObserverRegistry {
    
    static let shared: EffectsUnitStateObserverRegistry = .init()
    
    private var registry: [EffectsUnitType: [FXUnitStateObserver]] = [:]
    
    // AU ID -> Observer
    private var auRegistry: [String: [FXUnitStateObserver]] = [:]
    
    private var auCompositeStateObservers: [FXUnitStateObserver] = []
    private var reverseRegistry: [NSObject: EffectsUnitDelegateProtocol] = [:]
    
    private var auReverseRegistry: [NSObject: String] = [:]
    
    private var kvoTokens: KVOTokens<ColorScheme, PlatformColor> = KVOTokens()
    
    private init() {
        
        for unit in audioGraphDelegate.allUnits {
            
            // AUs are dealt with differently.
            guard unit.unitType != .au else {continue}
            
            _ = unit.observeState {[weak self] newState in
                
                for observer in self?.registry[unit.unitType] ?? [] {
                    observer.unitStateChanged(to: newState)
                }
            }
        }
        
        for au in audioGraphDelegate.audioUnits {
            observeAU(au)
        }
    }
    
    var compositeAUState: EffectsUnitState {
        audioGraphDelegate.audioUnitsStateFunction()
    }
    
    func observeAU(_ au: HostedAudioUnitDelegateProtocol) {
        
        _ = au.observeState {[weak self] newState in
            
            guard let strongSelf = self else {return}
            
            if let observers = strongSelf.auRegistry[au.id] {
                
                for observer in observers {
                    observer.unitStateChanged(to: newState)
                }
            }
            
            strongSelf.compositeAUStateUpdated()
        }
    }
    
    func compositeAUStateUpdated() {
        
        let newCompositeAUState = compositeAUState
        
        for observer in auCompositeStateObservers {
            observer.unitStateChanged(to: newCompositeAUState)
        }
    }
    
    func registerObserver(_ observer: FXUnitStateObserver, forFXUnit fxUnit: EffectsUnitDelegateProtocol) {
        
        let unitType = fxUnit.unitType
        
        if unitType != .au {
            
            if registry[unitType] == nil {
                registry[unitType] = []
            }
            
            registry[unitType]!.append(observer)
            
            if let object = observer as? NSObject {
                reverseRegistry[object] = fxUnit
            }
            
        } else {
            
            guard let auDelegate = fxUnit as? HostedAudioUnitDelegateProtocol else {return}
            
            if auRegistry[auDelegate.id] == nil {
                auRegistry[auDelegate.id] = []
            }
            
            auRegistry[auDelegate.id]!.append(observer)
            
            if let object = observer as? NSObject {
                auReverseRegistry[object] = auDelegate.id
            }
            
            // TODO: Reverse registry
        }
        
        // Set initial value.
        observer.unitStateChanged(to: fxUnit.state)
    }
    
    func registerAUObserver(_ observer: FXUnitStateObserver) {
        
        auCompositeStateObservers.append(observer)
        
        if let object = observer as? NSObject {
            auReverseRegistry[object] = "_composite_"
        }
        
        observer.unitStateChanged(to: compositeAUState)
    }
    
    func currentState(forObserver observer: FXUnitStateObserver) -> EffectsUnitState {
        
        guard let object = observer as? NSObject else {return .bypassed}
        
        if let state = reverseRegistry[object]?.state {
            return state
        }
        
        if let auID = auReverseRegistry[object] {
            
            if auID != "_composite_" {
                return audioGraphDelegate.audioUnits.first(where: {$0.id == auID})?.state ?? .bypassed
            } else {
                return compositeAUState
            }
        }
        
        return .bypassed
    }
    
    func removeAllObservers() {
        
        registry.removeAll()
        reverseRegistry.removeAll()
        
        auRegistry.removeAll()
        auReverseRegistry.removeAll()
        auCompositeStateObservers.removeAll()
    }
}

let fxUnitStateObserverRegistry: EffectsUnitStateObserverRegistry = .shared

protocol FXUnitStateObserver: AnyObject {
    
    func unitStateChanged(to newState: EffectsUnitState)
    
    func redraw()
}

extension FXUnitStateObserver {
    
    func unitStateChanged(to newState: EffectsUnitState) {
        redraw()
    }
}

protocol TintableFXUnitStateObserver: FXUnitStateObserver {
    
    var contentTintColor: NSColor? {get set}
}

extension TintableFXUnitStateObserver {
    
    func unitStateChanged(to newState: EffectsUnitState) {
        contentTintColor = systemColorScheme.colorForEffectsUnitState(newState)
    }
}

protocol TextualFXUnitStateObserver: FXUnitStateObserver {
    
    var textColor: NSColor? {get set}
}

extension TextualFXUnitStateObserver {
    
    func unitStateChanged(to newState: EffectsUnitState) {
        textColor = systemColorScheme.colorForEffectsUnitState(newState)
    }
    
    func colorForCurrentStateChanged(to newColor: PlatformColor) {
        textColor = newColor
    }
}
