import Cocoa

class ColorSchemeHistory {
    
    private var undoStack: Stack<ColorSchemeChange> = Stack()
    private var redoStack: Stack<ColorSchemeChange> = Stack()
    
    private var undoAllRestorePoint: ColorScheme?
    private var redoAllRestorePoint: ColorScheme?
    
    var changeListener: () -> Void = {}
    
    func begin() {
        
        undoStack.clear()
        redoStack.clear()
        undoAllRestorePoint = ColorSchemes.systemScheme.clone()
    }
    
    func noteChange(_ tag: Int, _ undoValue: Any, _ redoValue: Any, _ changeType: ColorSchemeChangeType) {
        
        undoStack.push(ColorSchemeChange(tag, undoValue, redoValue, changeType))
        
        // After a new change is noted, the redo changes are no longer relevant
        redoStack.clear()
        
        changeListener()
    }
    
    var changeToUndo: ColorSchemeChange? {
        return undoStack.peek()
    }
    
    var changeToRedo: ColorSchemeChange? {
        return redoStack.peek()
    }
    
    var canUndo: Bool {
        return !undoStack.isEmpty
    }
    
    var canRedo: Bool {
        return !redoStack.isEmpty
    }
    
    func undoLastChange() -> ColorSchemeChange? {
        
        // Only do this if this is the first undo in the sequence (i.e. you want the latest restore point)
        if redoStack.isEmpty && !undoStack.isEmpty {
            redoAllRestorePoint = ColorSchemes.systemScheme.clone()
        }
        
        if let change = undoStack.pop() {
            
            redoStack.push(change)
            return change
        }
        
        return nil
    }
    
    func undoAll() -> ColorScheme? {
        
        // Only do this if this is the first undo in the sequence (i.e. you want the latest restore point)
        if redoStack.isEmpty && !undoStack.isEmpty {
            redoAllRestorePoint = ColorSchemes.systemScheme.clone()
        }
        
        while let change = undoStack.pop() {
            redoStack.push(change)
        }
        
        return undoAllRestorePoint
    }
    
    func redoLastChange() -> ColorSchemeChange? {
        
        if let change = redoStack.pop() {
            
            undoStack.push(change)
            return change
        }
        
        return nil
    }
    
    func redoAll() -> ColorScheme? {
        
        while let change = redoStack.pop() {
            undoStack.push(change)
        }
        
        return redoAllRestorePoint
    }
}

enum ColorSchemeChangeType {
    
    case changeColor, changeGradient, applyScheme, toggle, setIntValue
}

struct ColorSchemeChange {
    
    let tag: Int
    let undoValue: Any
    let redoValue: Any
    let changeType: ColorSchemeChangeType
    
    init(_ tag: Int, _ undoValue: Any, _ redoValue: Any, _ changeType: ColorSchemeChangeType) {
        
        self.tag = tag
        self.undoValue = undoValue
        self.redoValue = redoValue
        self.changeType = changeType
    }
}

typealias ColorChangeAction = () -> Void

class ColorClipboard {
    
    var color: NSColor? {
        
        didSet {
            colorChangeCallback()
        }
    }
    
    var colorChangeCallback: () -> Void = {}
    
    var hasColor: Bool {
        return color != nil
    }
    
    func clear() {
        color = nil
    }
    
    func copy(_ color: NSColor) {
        self.color = color
    }
}
