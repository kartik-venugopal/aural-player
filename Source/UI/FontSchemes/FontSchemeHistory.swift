import Cocoa

/*
    A utility that maintains a chronological record of all changes made to a color scheme (used by the color scheme editor panel), using LIFO stacks.
    Provides undo/redo capabilities.
 */
class FontSchemeHistory {
    
    // Stack used to store changes that can be undone (i.e. LIFO).
    private var undoStack: Stack<FontSchemeChange> = Stack()
    
    // Stack used to store changes that can be redone (i.e. LIFO).
    private var redoStack: Stack<FontSchemeChange> = Stack()
    
    // A snapshot of the system color scheme before any changes were made to it ... used when performing an "Undo all changes" operation.
    private var undoAllRestorePoint: FontScheme?
    
    // The latest snapshot of the system color scheme (i.e. after all changes were made to it) ... used when performing a "Redo all changes" operation.
    private var redoAllRestorePoint: FontScheme?
    
    // A callback mechanism to notify an observer that the history state has changed (i.e. a new record has been added)
    var changeListener: () -> Void = {}
    
    // Resets history.
    func begin() {
        
        undoStack.clear()
        redoStack.clear()
        
        // Capture a snapshot of the system color scheme before any changes are made to it.
        undoAllRestorePoint = FontSchemes.systemScheme.clone()
    }
    
    // Stores a record for a new change made to the system color scheme.
    //
    // - Parameter undoValue:   The font scheme that should be applied if/when an undo is performed.
    // - Parameter redoValue:   The font scheme that should be applied if/when a redo is performed.
    // - Parameter changeType:  The type of change that this record represents (i.e. a color change or a gradient amount change).
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
        
        // Capture a snapshot of the system color scheme for a potential "Redo all" operation later.
        // Only do this if this is the first undo in the sequence (i.e. you want the latest restore point)
        if redoStack.isEmpty && !undoStack.isEmpty {
            redoAllRestorePoint = FontSchemes.systemScheme.clone()
        }
        
        // Try popping the undo stack. If a change is available, transfer it onto the redo stack.
        if let change = undoStack.pop() {
            
            redoStack.push(change)
            return change.undoValue
        }
        
        // Undo not possible.
        return nil
    }
    
    // Undoes all changes, if any. Returns a color scheme representing the restore point from the time before changes were made (if any).
    func undoAll() -> FontScheme? {
        
        // Capture a snapshot of the system color scheme for a potential "Redo all" operation later.
        // Only do this if this is the first undo in the sequence (i.e. you want the latest restore point)
        if redoStack.isEmpty && !undoStack.isEmpty {
            redoAllRestorePoint = FontSchemes.systemScheme.clone()
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
    
    // Redoes all changes, if any. Returns a color scheme representing the restore point from the time after all changes were made (if any).
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
