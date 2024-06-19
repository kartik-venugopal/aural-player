//
//  ChangeHistory.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A utility that maintains a chronological record of changes made to an arbitrary object,
/// using LIFO stacks. Provides undo/redo capabilities.
///
/// For an example of usage:
/// - SeeAlso: `FontSchemeHistory`
///
/// - Parameter T:      The type of object for which changes are to be recorded.
///
/// - Parameter C:      The type of an object representing a change to an object of type T.
///
class ChangeHistory<T: Any, C: Any> {
    
    // Stack used to store changes that can be undone (i.e. LIFO).
    private var undoStack: Stack<C> = Stack()
    
    // Stack used to store changes that can be redone (i.e. LIFO).
    private var redoStack: Stack<C> = Stack()
    
    // A snapshot of the system font scheme before any changes were made to it ... used when performing an "Undo all changes" operation.
    private var undoAllRestorePoint: T?
    
    // The latest snapshot of the system font scheme (i.e. after all changes were made to it) ... used when performing a "Redo all changes" operation.
    private var redoAllRestorePoint: T?
    
    // A callback mechanism to notify an observer that the history state has changed (i.e. a new record has been added)
    var changeListener: () -> Void = {}
    
    // Resets history.
    func begin() {
        
        undoStack.clear()
        redoStack.clear()
        
        // Capture a restore point before any changes are made.
        undoAllRestorePoint = captureSnapshotAsRestorePoint()
    }
    
    func captureSnapshotAsRestorePoint() -> T {
        fatalError("This function needs to be overriden by subclasses.")
    }
    
    //
    // Stores a record for a new change made to the system font scheme.
    //
    // - Parameter undoValue:   The font scheme that should be applied if/when an undo is performed.
    // - Parameter redoValue:   The font scheme that should be applied if/when a redo is performed.
    // - Parameter changeType:  The type of change that this record represents (i.e. a font change).
    //
    func noteChange(_ change: C) {
        
        // Any new record gets put on the undo stack for a potential undo.
        undoStack.push(change)
        
        // After a new change is noted, any redo changes are no longer relevant.
        redoStack.clear()
        
        // Notify the observer that a new record has been added.
        changeListener()
    }
    
    // Returns whether or not an undo operation is possible.
    var canUndo: Bool {
        !undoStack.isEmpty
    }
    
    // Returns whether or not a redo operation is possible.
    var canRedo: Bool {
        !redoStack.isEmpty
    }
    
    // Removes (pops) and returns the first possible undo operation, if one is available.
    func undoLastChange() -> C? {
        
        // Capture a snapshot of the system font scheme for a potential "Redo all" operation later.
        // Only do this if this is the first undo in the sequence (i.e. you want the latest restore point)
        if redoStack.isEmpty && !undoStack.isEmpty {
            redoAllRestorePoint = captureSnapshotAsRestorePoint()
        }
        
        // Try popping the undo stack. If a change is available, transfer it onto the redo stack.
        if let change = undoStack.pop() {
            
            redoStack.push(change)
            return change
        }
        
        // Undo not possible.
        return nil
    }
    
    // Undoes all changes, if any. Returns a font scheme representing the restore point from the time before changes were made (if any).
    func undoAll() -> T? {
        
        // Capture a snapshot of the system font scheme for a potential "Redo all" operation later.
        // Only do this if this is the first undo in the sequence (i.e. you want the latest restore point)
        if redoStack.isEmpty && !undoStack.isEmpty {
            redoAllRestorePoint = captureSnapshotAsRestorePoint()
        }
        
        // Transfer all records to the redo stack.
        while let change = undoStack.pop() {
            redoStack.push(change)
        }
        
        // Return the restore point.
        return undoAllRestorePoint
    }
    
    // Removes (pops) and returns the first possible redo operation, if one is available.
    func redoLastChange() -> C? {
        
        // Try popping the redo stack. If a change is available, transfer it onto the undo stack.
        if let change = redoStack.pop() {
            
            undoStack.push(change)
            return change
        }
        
        // Redo not possible.
        return nil
    }
    
    // Redoes all changes, if any. Returns a font scheme representing the restore point from the time after all changes were made (if any).
    func redoAll() -> T? {
        
        // Transfer all records to the undo stack.
        while let change = redoStack.pop() {
            undoStack.push(change)
        }
        
        // Return the restore point.
        return redoAllRestorePoint
    }
}
