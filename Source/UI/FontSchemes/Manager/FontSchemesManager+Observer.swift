//
//  FontSchemesManager+Observer.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol FontSchemeObserver {
    
    func fontSchemeChanged()
    
    var hashValue: Int {get}
}

extension FontSchemesManager {
    
    func stopObserving() {
        schemeObservers.removeAll()
    }
    
    func registerObserver(_ observer: FontSchemeObserver) {
        
        schemeObservers[observer.hashValue] = observer
    
        // Set initial value.
        if !(observer is ThemeInitialization) {
            observer.fontSchemeChanged()
        }
    }
    
    func removeObserver(_ observer: FontSchemeObserver) {
        schemeObservers.removeValue(forKey: observer.hashValue)
    }
    
    func removeAllObservers() {
        schemeObservers.removeAll()
    }
}
