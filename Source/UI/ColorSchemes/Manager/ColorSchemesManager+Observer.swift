
//
//  ColorSchemesManager+Observer.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import AppKit

protocol ColorSchemeObserver: ColorSchemePropertyObserver {
    
    func colorSchemeChanged()
}

protocol ColorSchemePropertyObserver where Self: NSObject {
}

protocol ColorSchemePropertyChangeReceiver {
    
    func colorChanged(_ newColor: NSColor)
}

typealias ColorSchemePropertyChangeHandler = (NSColor) -> Void
typealias ColorSchemeProperty = KeyPath<ColorScheme, NSColor>

extension ColorSchemesManager {
    
    func stopObserving() {
        
        for (_, var map) in propertyObservers {
            map.removeAll()
        }
        
        propertyObservers.removeAll()
        schemeObservers.removeAll()
    }
    
    func registerSchemeObserver(_ observer: ColorSchemeObserver) {
        
        schemeObservers[observer.hashValue] = observer
        
        if let themeInitialingObserver = observer as? ThemeInitialization {
            themeInitialingObserver.initTheme()
        } else {
            observer.colorSchemeChanged()
        }
    }
    
    func registerSchemeObservers(_ observers: ColorSchemeObserver...) {
        
        observers.forEach {
            registerSchemeObserver($0)
        }
    }
    
    func registerPropertyObserver(_ observer: ColorSchemePropertyObserver, forProperty property: ColorSchemeProperty, 
                                  handler: @escaping ColorSchemePropertyChangeHandler) {
        
        if propertyObservers[property] == nil {
            propertyObservers[property] = [:]
        }
        
        if propertyObservers[property]![observer.hashValue] == nil {
            propertyObservers[property]![observer.hashValue] = []
        }
        
        propertyObservers[property]![observer.hashValue]!.append(handler)
    }
    
    func registerPropertyObserver(_ observer: ColorSchemePropertyObserver, forProperties properties: [ColorSchemeProperty],
                                  handler: @escaping ColorSchemePropertyChangeHandler) {
        
        for property in properties {
            registerPropertyObserver(observer, forProperty: property, handler: handler)
        }
    }
    
    func registerPropertyObserver(_ observer: ColorSchemePropertyObserver, forProperty property: ColorSchemeProperty,
                                  changeReceiver: ColorSchemePropertyChangeReceiver) {
        
        if propertyObservers[property] == nil {
            propertyObservers[property] = [:]
        }
        
        if propertyObservers[property]![observer.hashValue] == nil {
            propertyObservers[property]![observer.hashValue] = []
        }
        
        propertyObservers[property]![observer.hashValue]!.append(changeReceiver.colorChanged(_:))
    }
    
    func registerPropertyObserver(_ observer: ColorSchemePropertyObserver, forProperty property: ColorSchemeProperty,
                                  changeReceivers: [ColorSchemePropertyChangeReceiver]) {
        
        if propertyObservers[property] == nil {
            propertyObservers[property] = [:]
        }
        
        if propertyObservers[property]![observer.hashValue] == nil {
            propertyObservers[property]![observer.hashValue] = []
        }
        
        for receiver in changeReceivers {
            propertyObservers[property]![observer.hashValue]!.append(receiver.colorChanged(_:))
        }
    }
    
    func registerPropertyObserver(_ observer: ColorSchemePropertyObserver, forProperties properties: [ColorSchemeProperty],
                                  changeReceiver: ColorSchemePropertyChangeReceiver) {
        
        for property in properties {
            registerPropertyObserver(observer, forProperty: property, changeReceiver: changeReceiver)
        }
    }
    
    func registerPropertyObserver(_ observer: ColorSchemePropertyObserver, forProperties properties: [ColorSchemeProperty],
                                  changeReceivers: [ColorSchemePropertyChangeReceiver]) {
        
        for property in properties {
            registerPropertyObserver(observer, forProperty: property, changeReceivers: changeReceivers)
        }
    }
    
    func removePropertyObserver(_ observer: ColorSchemePropertyObserver, forProperty property: ColorSchemeProperty) {
        propertyObservers[property]?.removeValue(forKey: observer.hashValue)
    }
    
    func removePropertyObservers(_ observer: ColorSchemePropertyObserver, forProperties properties: ColorSchemeProperty...) {
        
        for property in properties {
            propertyObservers[property]?.removeValue(forKey: observer.hashValue)
        }
    }
    
    func removeSchemeObserver(_ observer: ColorSchemeObserver) {
        schemeObservers.removeValue(forKey: observer.hashValue)
    }
    
    // MARK: Broadcasting change notifications
    
    func propertyChanged(_ property: ColorSchemeProperty) {
        
        let newColor = systemColorScheme[keyPath: property]
        
        for handlers in (propertyObservers[property] ?? [:]).values {
            
            for handler in handlers {
                handler(newColor)
            }
        }
    }
    
//    func registerObserver(_ observer: ColorSchemeObserver, forProperties properties: [ColorSchemeProperty]) {
//        doRegisterObservers(properties.map {(observer, $0)})
//    }
//    
//    func registerObservers(_ observers: [ColorSchemeObserver], forProperty property: ColorSchemeProperty) {
//        doRegisterObservers(observers.map {($0, property)})
//    }
    
//    func registerObservers(_ observers: [ColorSchemeObserver], forProperties properties: [ColorSchemeProperty]) {
//        
//        var tuples: [SchemePropertyObserver] = []
//        
//        for observer in observers {
//            
//            for property in properties {
//                tuples.append((observer, property))
//            }
//        }
//        
//        doRegisterObservers(tuples)
//    }
    
//    private func doRegisterObservers(_ observers: [SchemePropertyObserver]) {
//        
//        for (observer, property) in observers {
//            
//            if propertyObservers[property] == nil {
//                propertyObservers[property] = []
//            }
//            
//            propertyObservers[property]!.append(observer)
//            
//            if let observerObject = observer as? NSObject {
//                reverseRegistry[observerObject] = property
//            }
//            
//            // Set initial value.
//            observer.colorChanged(to: systemScheme[keyPath: property], forProperty: property)
//        }
//    }
}
