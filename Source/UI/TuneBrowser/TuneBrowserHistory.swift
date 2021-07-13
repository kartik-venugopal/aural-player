//
//  TuneBrowserHistory.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class TuneBrowserHistory {
    
    var backStack: Stack<URL> = Stack()
    var forwardStack: Stack<URL> = Stack()
    
    func notePreviousLocation(_ location: URL) {
        
        if backStack.peek() != location {
            backStack.push(location)
        }
    }
    
    func back(from currentLocation: URL) -> URL? {
        
        if let location = backStack.pop() {
            
            forwardStack.push(currentLocation)
            return location
        }
        
        return nil
    }
    
    var canGoBack: Bool {!backStack.isEmpty}
    
    func forward(from currentLocation: URL) -> URL? {
        
        if let location = forwardStack.pop() {
            
            backStack.push(currentLocation)
            return location
        }
        
        return nil
    }
    
    var canGoForward: Bool {!forwardStack.isEmpty}
}
