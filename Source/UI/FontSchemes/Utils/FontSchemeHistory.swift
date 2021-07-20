//
//  FontSchemeHistory.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A utility that maintains a chronological record of all changes made to a font scheme (used by the font scheme editor panel), using LIFO stacks.
    Provides undo/redo capabilities.
 */

// TODO: Factor out this class and ColorSchemeHistory into a common generic-typed class History<T>.

class FontSchemeHistory {
    
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    
    // Stack used to store changes that can be undone (i.e. LIFO).
    private var undoStack: Stack<FontSchemeChange> = Stack()
    
    // Stack used to store changes that can be redone (i.e. LIFO).
    private var redoStack: Stack<FontSchemeChange> = Stack()
    
    // A snapshot of the system font scheme before any changes were made to it ... used when performing an "Undo all changes" operation.
    private var undoAllRestorePoint: FontScheme?
    
    // The latest snapshot of the system font scheme (i.e. after all changes were made to it) ... used when performing a "Redo all changes" operation.
    private var redoAllRestorePoint: FontScheme?
    
    // A callback mechanism to notify an observer that the history state has changed (i.e. a new record has been added)
    var changeListener: () -> Void = {}
    
    // Resets history.
    func begin() {
        
        undoStack.clear()
        redoStack.clear()
        
        // Capture a snapshot of the system font scheme before any changes are made to it.
        undoAllRestorePoint = fontSchemesManager.systemScheme.clone()
    }
    
    //
    // Stores a record for a new change made to the system font scheme.
    //
    // - Parameter undoValue:   The font scheme that should be applied if/when an undo is performed.
    // - Parameter redoValue:   The font scheme that should be applied if/when a redo is performed.
    // - Parameter changeType:  The type of change that this record represents (i.e. a font change).
    //
    func noteChange(_ undoValue: FontScheme, _ redoValue: FontScheme) {
        
        // Any new record gets put on the undo stack for a potential undo.
        undoStack.push(FontSchemeChange(undoValue, redoValue))
        
        // After a new change is noted, any redo changes are no longer relevant.
        redoStack.clear()
        
        // Notify the observer that a new record has been added.
        changeListener()
    }
    
    // Returns details of the first possible undo operation, if one is available.
    var changeToUndo: FontSchemeChange? {
        return undoStack.peek()
    }
    
    // Returns details of the first possible redo operation, if one is available.
    var changeToRedo: FontSchemeChange? {
        return redoStack.peek()
    }
    
    // Returns whether or not an undo operation is possible.
    var canUndo: Bool {
        return !undoStack.isEmpty
    }
    
    // Returns whether or not a redo operation is possible.
    var canRedo: Bool {
        return !redoStack.isEmpty
    }
    
    // Removes (pops) and returns the first possible undo operation, if one is available.
    func undoLastChange() -> FontScheme? {
        
        // Capture a snapshot of the system font scheme for a potential "Redo all" operation later.
        // Only do this if this is the first undo in the sequence (i.e. you want the latest restore point)
        if redoStack.isEmpty && !undoStack.isEmpty {
            redoAllRestorePoint = fontSchemesManager.systemScheme.clone()
        }
        
        // Try popping the undo stack. If a change is available, transfer it onto the redo stack.
        if let change = undoStack.pop() {
            
            redoStack.push(change)
            return change.undoValue
        }
        
        // Undo not possible.
        return nil
    }
    
    // Undoes all changes, if any. Returns a font scheme representing the restore point from the time before changes were made (if any).
    func undoAll() -> FontScheme? {
        
        // Capture a snapshot of the system font scheme for a potential "Redo all" operation later.
        // Only do this if this is the first undo in the sequence (i.e. you want the latest restore point)
        if redoStack.isEmpty && !undoStack.isEmpty {
            redoAllRestorePoint = fontSchemesManager.systemScheme.clone()
        }
        
        // Transfer all records to the redo stack.
        while let change = undoStack.pop() {
            redoStack.push(change)
        }
        
        // Return the restore point.
        return undoAllRestorePoint
    }
    
    // Removes (pops) and returns the first possible redo operation, if one is available.
    func redoLastChange() -> FontScheme? {
        
        // Try popping the redo stack. If a change is available, transfer it onto the undo stack.
        if let change = redoStack.pop() {
            
            undoStack.push(change)
            return change.redoValue
        }
        
        // Redo not possible.
        return nil
    }
    
    // Redoes all changes, if any. Returns a font scheme representing the restore point from the time after all changes were made (if any).
    func redoAll() -> FontScheme? {
        
        // Transfer all records to the undo stack.
        while let change = redoStack.pop() {
            undoStack.push(change)
        }
        
        // Return the restore point.
        return redoAllRestorePoint
    }
}

/*
    A single historical record of a change made to the system font scheme.
 */
struct FontSchemeChange {
    
    // The font scheme that should be applied if/when an undo is performed.
    let undoValue: FontScheme
    
    // The font scheme that should be applied if/when a redo is performed.
    let redoValue: FontScheme
    
    init(_ undoValue: FontScheme, _ redoValue: FontScheme) {
        
        self.undoValue = undoValue
        self.redoValue = redoValue
    }
}
