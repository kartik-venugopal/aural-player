//
//  ColorSchemeHistory.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A utility that maintains a chronological record of all changes made to a color scheme (used by the color scheme editor panel), using LIFO stacks.
    Provides undo/redo capabilities.
 */
class ColorSchemeHistory {
    
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    // Stack used to store changes that can be undone (i.e. LIFO).
    private var undoStack: Stack<ColorSchemeChange> = Stack()
    
    // Stack used to store changes that can be redone (i.e. LIFO).
    private var redoStack: Stack<ColorSchemeChange> = Stack()
    
    // A snapshot of the system color scheme before any changes were made to it ... used when performing an "Undo all changes" operation.
    private var undoAllRestorePoint: ColorScheme?
    
    // The latest snapshot of the system color scheme (i.e. after all changes were made to it) ... used when performing a "Redo all changes" operation.
    private var redoAllRestorePoint: ColorScheme?
    
    // A callback mechanism to notify an observer that the history state has changed (i.e. a new record has been added)
    var changeListener: () -> Void = {}
    
    // Resets history.
    func begin() {
        
        undoStack.clear()
        redoStack.clear()
        
        // Capture a snapshot of the system color scheme before any changes are made to it.
        undoAllRestorePoint = colorSchemesManager.systemScheme.clone()
    }
    
    // Stores a record for a new change made to the system color scheme.
    //
    // - Parameter tag:         The tag of the control whose value changed (used to later identify the control).
    // - Parameter undoValue:   The value that should be assigned to the changed control if/when an undo is performed on this field.
    // - Parameter redoValue:   The value that should be assigned to the changed control if/when a redo is performed on this field.
    // - Parameter changeType:  The type of change that this record represents (i.e. a color change or a gradient amount change).
    func noteChange(_ tag: Int, _ undoValue: Any, _ redoValue: Any, _ changeType: ColorSchemeChangeType) {
        
        // Any new record gets put on the undo stack for a potential undo.
        undoStack.push(ColorSchemeChange(tag, undoValue, redoValue, changeType))
        
        // After a new change is noted, any redo changes are no longer relevant.
        redoStack.clear()
        
        // Notify the observer that a new record has been added.
        changeListener()
    }
    
    // Returns details of the first possible undo operation, if one is available.
    var changeToUndo: ColorSchemeChange? {
        return undoStack.peek()
    }
    
    // Returns details of the first possible redo operation, if one is available.
    var changeToRedo: ColorSchemeChange? {
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
    func undoLastChange() -> ColorSchemeChange? {
        
        // Capture a snapshot of the system color scheme for a potential "Redo all" operation later.
        // Only do this if this is the first undo in the sequence (i.e. you want the latest restore point)
        if redoStack.isEmpty && !undoStack.isEmpty {
            redoAllRestorePoint = colorSchemesManager.systemScheme.clone()
        }
        
        // Try popping the undo stack. If a change is available, transfer it onto the redo stack.
        if let change = undoStack.pop() {
            
            redoStack.push(change)
            return change
        }
        
        // Undo not possible.
        return nil
    }
    
    // Undoes all changes, if any. Returns a color scheme representing the restore point from the time before changes were made (if any).
    func undoAll() -> ColorScheme? {
        
        // Capture a snapshot of the system color scheme for a potential "Redo all" operation later.
        // Only do this if this is the first undo in the sequence (i.e. you want the latest restore point)
        if redoStack.isEmpty && !undoStack.isEmpty {
            redoAllRestorePoint = colorSchemesManager.systemScheme.clone()
        }
        
        // Transfer all records to the redo stack.
        while let change = undoStack.pop() {
            redoStack.push(change)
        }
        
        // Return the restore point.
        return undoAllRestorePoint
    }
    
    // Removes (pops) and returns the first possible redo operation, if one is available.
    func redoLastChange() -> ColorSchemeChange? {
        
        // Try popping the redo stack. If a change is available, transfer it onto the undo stack.
        if let change = redoStack.pop() {
            
            undoStack.push(change)
            return change
        }
        
        // Redo not possible.
        return nil
    }
    
    // Redoes all changes, if any. Returns a color scheme representing the restore point from the time after all changes were made (if any).
    func redoAll() -> ColorScheme? {
        
        // Transfer all records to the undo stack.
        while let change = redoStack.pop() {
            undoStack.push(change)
        }
        
        // Return the restore point.
        return redoAllRestorePoint
    }
}

/*
    A single historical record of a change made to the system color scheme.
 */
struct ColorSchemeChange {
    
    // The tag of the control whose value was changed
    let tag: Int
    
    // The value that should be assigned to the changed control if/when an undo is performed on this field.
    let undoValue: Any
    
    // The value that should be assigned to the changed control if/when a redo is performed on this field.
    let redoValue: Any
    
    // The type of change that this record represents (i.e. a color change or a gradient amount change).
    let changeType: ColorSchemeChangeType
    
    init(_ tag: Int, _ undoValue: Any, _ redoValue: Any, _ changeType: ColorSchemeChangeType) {
        
        self.tag = tag
        self.undoValue = undoValue
        self.redoValue = redoValue
        self.changeType = changeType
    }
}

// Enumeration of all possible color scheme changes that can be recorded in history.
enum ColorSchemeChangeType {
    
    case
    
    /*
        A single color scheme element has changed (eg. window background color).
     */
    changeColor,
    
    /*
        The gradient for a single color scheme element has changed (eg. seek slider foreground).
     */
    changeGradient,
    
    /*
        An entire color scheme has been applied to the system color scheme.
     */
    applyScheme,
    
    /*
        A boolean field has been toggled (eg. enable/disable slider foreground gradient)
     */
    toggle,
    
    /*
        An Int value field has been changed. (eg. gradient amount)
     */
    setIntValue
}

// An action that is performed as part of an undo/redo operation.
typealias ColorChangeAction = () -> Void
