import Cocoa

class ColorSchemesWindowController: NSWindowController, ModalDialogDelegate, StringInputClient, NSWindowDelegate {
    
    @IBOutlet weak var tabView: AuralTabView!
    @IBOutlet weak var btnSave: NSButton!
    
    @IBOutlet weak var btnUndo: NSButton!
    @IBOutlet weak var btnRedo: NSButton!

    private lazy var generalSchemeView: ColorSchemesViewProtocol = ViewFactory.generalColorSchemeView
    private lazy var playerSchemeView: ColorSchemesViewProtocol = ViewFactory.playerColorSchemeView
    private lazy var playlistSchemeView: ColorSchemesViewProtocol = ViewFactory.playlistColorSchemeView
    private lazy var effectsSchemeView: ColorSchemesViewProtocol = ViewFactory.effectsColorSchemeView
    
    private var subViews: [ColorSchemesViewProtocol] = []
    
    lazy var userSchemesPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private var schemeRestorePoint: ColorScheme?
    private var history: ColorSchemeHistory = ColorSchemeHistory()
    
    override var windowNibName: NSNib.Name? {return "ColorSchemes"}
    
    override func windowDidLoad() {
        
        self.window?.isMovableByWindowBackground = true
        
        subViews = [generalSchemeView, playerSchemeView, playlistSchemeView, effectsSchemeView]
        tabView.addViewsForTabs(subViews.map {$0.colorSchemeView})
        
        NSColorPanel.shared.showsAlpha = false
        NSColorPanel.shared.delegate = self
        
        ObjectGraph.windowManager.registerModalComponent(self)
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = self.window!
        }
        
        history.clear()
        history.changeListener = {
            self.btnUndo.enableIf(self.history.canUndo)
            self.btnRedo.enableIf(self.history.canRedo)
        }
        
        // Select the first tab
        subViews.forEach({$0.resetFields(ColorSchemes.systemScheme, history)})
        tabView.selectTabViewItem(at: 0)
        
        [btnUndo, btnRedo].forEach({$0?.disable()})
        
        UIUtils.showDialog(self.window!)
        
        // Create a copy of the system scheme as a restore point (in case the user wants to undo changes)
        schemeRestorePoint = ColorSchemes.systemScheme.clone()
        
        return .ok
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
        NSColorPanel.shared.close()
        UIUtils.dismissDialog(self.window!)
    }
    
    @IBAction func saveSchemeAction(_ sender: Any) {
        userSchemesPopover.show(btnSave, NSRectEdge.minY)
    }
    
    @IBAction func undoAllChangesAction(_ sender: Any) {
        
        if let restorePoint = schemeRestorePoint {
            
            ColorSchemes.systemScheme.applyScheme(restorePoint)
            subViews.forEach({$0.resetFields(ColorSchemes.systemScheme, history)})
            
            SyncMessenger.publishActionMessage(ColorSchemeActionMessage(ColorSchemes.systemScheme))
            
            btnUndo.disable()
            btnRedo.enableIf(history.canRedo)
        }
        
        // TODO: First, store the "new" scheme so we can redo all changes
    }
    
    @IBAction func undoLastChangeAction(_ sender: Any) {
        
        for subView in subViews {
            
            if subView.undoLastChange() {
                
                print("Undo successful !", subView)
                
                btnUndo.enableIf(history.canUndo)
                btnRedo.enableIf(history.canRedo)
                
                break
            }
        }
    }
    
    @IBAction func redoLastChangeAction(_ sender: Any) {
        
        for subView in subViews {
            
            if subView.redoLastChange() {
                
                print("Redo successful !", subView)
                
                btnUndo.enableIf(history.canUndo)
                btnRedo.enableIf(history.canRedo)
                
                break
            }
        }
    }
    
    // MARK - StringInputClient functions
    // TODO: Refactor this into a ColorSchemesStringInputClient class to avoid duplication
    
    var inputPrompt: String {
        return "Enter a new color scheme name:"
    }
    
    var defaultValue: String? {
        return "<New color scheme>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        if ColorSchemes.schemeWithNameExists(string) {
            return (false, "Color scheme with this name already exists !")
        } else if string.trim().isEmpty {
            return (false, "Name must have at least 1 non-whitespace character.")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new color scheme name and saves the new scheme
    func acceptInput(_ string: String) {
        
        // Copy the current system scheme into the new scheme, and name it with the user's given scheme name
        let newScheme: ColorScheme = ColorScheme(string, false, ColorSchemes.systemScheme)
        ColorSchemes.addUserDefinedScheme(newScheme)
    }
    
    var inputFontSize: TextSize {
        return .normal
    }
}

class ColorSchemeHistory {
    
    private var undoStack: Stack<ColorSchemeChange> = Stack()
    private var redoStack: Stack<ColorSchemeChange> = Stack()
    
    var changeListener: () -> Void = {}
    
    func clear() {
        
        undoStack.clear()
        redoStack.clear()
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
        
        if let change = undoStack.pop() {
            
            redoStack.push(change)
            return change
        }
        
        return nil
    }
    
    func undoAll() {
        
        while let change = undoStack.pop() {
            redoStack.push(change)
        }
    }
    
    func redoLastChange() -> ColorSchemeChange? {
        
        if let change = redoStack.pop() {
            
            undoStack.push(change)
            return change
        }
        
        return nil
    }
    
    func redoAll() {
        
        while let change = redoStack.pop() {
            undoStack.push(change)
        }
    }
}

enum ColorSchemeChangeType {
    
    case changeColor, toggle, setIntValue
    
    // TODO: Add a case applyScheme for when presets are applied (value will be a ColorScheme object) ... undo / redo values will be restore points
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

protocol ColorSchemesViewProtocol {
    
    var colorSchemeView: NSView {get}
    
    func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory)
    
    func undoLastChange() -> Bool
    
    func redoLastChange() -> Bool
}
