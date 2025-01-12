//
//  TuneBrowserHistory.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class TuneBrowserHistory {
    
    var backStack: Stack<FileSystemFolderLocation> = Stack()
    var forwardStack: Stack<FileSystemFolderLocation> = Stack()
    
    func notePreviousLocation(_ location: FileSystemFolderLocation) {
        
        if backStack.peek() != location {
            backStack.push(location)
        }
        
        forwardStack.clear()
    }
    
    func back(from currentLocation: FileSystemFolderLocation) -> FileSystemFolderLocation? {
        
        if let location = backStack.pop() {
            
            forwardStack.push(currentLocation)
            return location
        }
        
        return nil
    }
    
    func back(from currentLocation: FileSystemFolderLocation, to previousLocation: FileSystemFolderLocation) {
        
        var poppedLocation: FileSystemFolderLocation? = nil
        
        repeat {
            
            guard let thePoppedLocation = backStack.pop() else {break}
            
            if thePoppedLocation != previousLocation {
                forwardStack.push(thePoppedLocation)
            }
            
            poppedLocation = thePoppedLocation
            
        } while poppedLocation != previousLocation
    }
    
    var canGoBack: Bool {!backStack.isEmpty}
    
    func forward(from currentLocation: FileSystemFolderLocation) -> FileSystemFolderLocation? {
        
        if let location = forwardStack.pop() {
            
            backStack.push(currentLocation)
            return location
        }
        
        return nil
    }
    
    func forward(to forwardLocation: FileSystemFolderLocation) {
        
        var poppedLocation: FileSystemFolderLocation? = nil
        
        repeat {
            
            guard let thePoppedLocation = forwardStack.pop() else {break}
            
            if thePoppedLocation != forwardLocation {
                backStack.push(thePoppedLocation)
            }
            
            poppedLocation = thePoppedLocation
            
        } while poppedLocation != forwardLocation
    }
    
    var canGoForward: Bool {
        !forwardStack.isEmpty
    }
}
