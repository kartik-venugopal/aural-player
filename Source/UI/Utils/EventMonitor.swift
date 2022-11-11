//
//  EventMonitor.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

typealias EventType = NSEvent.EventType
typealias EventTypeMask = NSEvent.EventTypeMask
typealias EventHandler = (NSEvent) -> NSEvent?

///
/// An object that monitors user input events such as keyboard presses, mouse movements, scrolls, or swipes.
///
class EventMonitor {
    
    private var handlers: [EventType: EventHandler] = [:]
    
    private var monitor: Any?
    
    func registerHandler(forEventType eventType: EventType, _ handler: @escaping EventHandler) {
        handlers[eventType] = handler
    }
    
    func startMonitoring() {
        
        // Combine the event masks from all registered handlers.
        let allEventMasks = handlers.keys.reduce([], {(maskSoFar: EventTypeMask, eventType: EventType) -> EventTypeMask in
                                                    maskSoFar.union(eventType.toMask())})

        monitor = NSEvent.addLocalMonitorForEvents(matching: allEventMasks, handler: {[weak self] (event: NSEvent) -> NSEvent? in
            
            if let theSelf = self {
                return theSelf.handleEvent(event)
            }
            
            return event
        })
    }
    
    private func handleEvent(_ event: NSEvent) -> NSEvent? {
        
        if let handler = handlers[event.type] {
            return handler(event)
        }
        
        return event
    }
    
    func stopMonitoring() {
        
        if let theMonitor = monitor {
            
            NSEvent.removeMonitor(theMonitor)
            monitor = nil
        }
    }
    
    deinit {
        stopMonitoring()
    }
}

extension EventType {
    
    func toMask() -> EventTypeMask {
        
        switch self {
        
        case .keyDown:  return .keyDown
        
        case .keyUp:    return .keyUp
        
        case .scrollWheel:     return .scrollWheel
            
        case .swipe:    return .swipe
            
        case .mouseEntered:     return .mouseEntered
            
        case .mouseMoved:     return .mouseMoved
            
        case .mouseExited:      return .mouseExited
            
        case .leftMouseDown:    return .leftMouseDown
            
        case .leftMouseDragged:     return .leftMouseDragged
            
        case .leftMouseUp:      return .leftMouseUp
            
        case .rightMouseDown:   return .rightMouseDown
            
        case .rightMouseDragged:   return .rightMouseDragged
            
        case .rightMouseUp:     return .rightMouseUp
            
        default:    return .any
            
        }
    }
}
