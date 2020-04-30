import Cocoa

class GeneralColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var containerView: NSView!
    
    @IBOutlet weak var appLogoColorPicker: NSColorWell!
    @IBOutlet weak var backgroundColorPicker: NSColorWell!
    
    @IBOutlet weak var viewControlButtonColorPicker: NSColorWell!
    @IBOutlet weak var functionButtonColorPicker: NSColorWell!
    @IBOutlet weak var textButtonMenuColorPicker: NSColorWell!
    @IBOutlet weak var toggleButtonOffStateColorPicker: NSColorWell!
    @IBOutlet weak var selectedTabButtonColorPicker: NSColorWell!
    
    @IBOutlet weak var mainCaptionTextColorPicker: NSColorWell!
    @IBOutlet weak var tabButtonTextColorPicker: NSColorWell!
    @IBOutlet weak var selectedTabButtonTextColorPicker: NSColorWell!
    @IBOutlet weak var buttonMenuTextColorPicker: NSColorWell!
    
    private var controlsMap: [Int: NSControl] = [:]
    private var actionsMap: [Int: ColorChangeAction] = [:]
    private var history: ColorSchemeHistory!
    
    override var nibName: NSNib.Name? {return "GeneralColorScheme"}
    
    override func viewDidLoad() {
        
        for aView in containerView.subviews {
            
            if let colPicker = aView as? NSColorWell {
                controlsMap[colPicker.tag] = colPicker
            }
        }
        
        actionsMap[appLogoColorPicker.tag] = self.changeAppLogoColor
        actionsMap[backgroundColorPicker.tag] = self.changeBackgroundColor
        actionsMap[viewControlButtonColorPicker.tag] = self.changeViewControlButtonColor
        actionsMap[functionButtonColorPicker.tag] = self.changeFunctionButtonColor
        actionsMap[textButtonMenuColorPicker.tag] = self.changeTextButtonMenuColor
        actionsMap[toggleButtonOffStateColorPicker.tag] = self.changeToggleButtonOffStateColor
        actionsMap[selectedTabButtonColorPicker.tag] = self.changeSelectedTabButtonColor
        actionsMap[mainCaptionTextColorPicker.tag] = self.changeMainCaptionTextColor
        actionsMap[tabButtonTextColorPicker.tag] = self.changeTabButtonTextColor
        actionsMap[selectedTabButtonTextColorPicker.tag] = self.changeSelectedTabButtonTextColor
        actionsMap[buttonMenuTextColorPicker.tag] = self.changeButtonMenuTextColor
    }
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory) {
        
        self.history = history
        
        appLogoColorPicker.color = scheme.general.appLogoColor
        backgroundColorPicker.color = scheme.general.backgroundColor
        
        viewControlButtonColorPicker.color = scheme.general.viewControlButtonColor
        functionButtonColorPicker.color = scheme.general.functionButtonColor
        textButtonMenuColorPicker.color = scheme.general.textButtonMenuColor
        toggleButtonOffStateColorPicker.color = scheme.general.toggleButtonOffStateColor
        selectedTabButtonColorPicker.color = scheme.general.selectedTabButtonColor
        
        mainCaptionTextColorPicker.color = scheme.general.mainCaptionTextColor
        tabButtonTextColorPicker.color = scheme.general.tabButtonTextColor
        selectedTabButtonTextColorPicker.color = scheme.general.selectedTabButtonTextColor
        buttonMenuTextColorPicker.color = scheme.general.buttonMenuTextColor
        
        // Only do this when the window is opening
        if !(self.view.window?.isVisible ?? true) {
            scrollToTop()
        }
    }
    
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
    
    func undoLastChange() -> Bool {
        
        if let lastChange = history.changeToUndo, let colPicker = controlsMap[lastChange.tag] as? NSColorWell,
            let undoColor = lastChange.undoValue as? NSColor, let undoAction = actionsMap[lastChange.tag] {
            
            print("Found change:", lastChange.tag)
            
            _ = history.undoLastChange()
            
            colPicker.color = undoColor
            undoAction()
            
            return true
        }
        
        return false
    }
    
    func redoLastChange() -> Bool {
        
        if let lastChange = history.changeToRedo, let colPicker = controlsMap[lastChange.tag] as? NSColorWell,
            let redoColor = lastChange.redoValue as? NSColor, let redoAction = actionsMap[lastChange.tag] {
            
            print("Found REDO change:", lastChange.tag)
            
            _ = history.redoLastChange()
            
            colPicker.color = redoColor
            redoAction()
            
            return true
        }
        
        return false
    }
    
    @IBAction func appLogoColorAction(_ sender: Any) {
        
        history.noteChange(appLogoColorPicker.tag, ColorSchemes.systemScheme.general.appLogoColor, appLogoColorPicker.color, .changeColor)
        changeAppLogoColor()
    }
    
    private func changeAppLogoColor() {
        
        ColorSchemes.systemScheme.general.appLogoColor = appLogoColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeAppLogoColor, appLogoColorPicker.color))
    }
    
    @IBAction func backgroundColorAction(_ sender: Any) {
        
        history.noteChange(backgroundColorPicker.tag, ColorSchemes.systemScheme.general.backgroundColor, backgroundColorPicker.color, .changeColor)
        changeBackgroundColor()
    }
    
    private func changeBackgroundColor() {
        
        ColorSchemes.systemScheme.general.backgroundColor = backgroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeBackgroundColor, backgroundColorPicker.color))
    }
    
    @IBAction func viewControlButtonColorAction(_ sender: Any) {
        
        history.noteChange(viewControlButtonColorPicker.tag, ColorSchemes.systemScheme.general.viewControlButtonColor, viewControlButtonColorPicker.color, .changeColor)
        changeViewControlButtonColor()
    }
    
    private func changeViewControlButtonColor() {
        
        ColorSchemes.systemScheme.general.viewControlButtonColor = viewControlButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeViewControlButtonColor, viewControlButtonColorPicker.color))
    }
    
    @IBAction func functionButtonColorAction(_ sender: Any) {
        
        history.noteChange(functionButtonColorPicker.tag, ColorSchemes.systemScheme.general.functionButtonColor, functionButtonColorPicker.color, .changeColor)
        changeFunctionButtonColor()
    }
    
    private func changeFunctionButtonColor() {
        
        ColorSchemes.systemScheme.general.functionButtonColor = functionButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeFunctionButtonColor, functionButtonColorPicker.color))
    }
    
    @IBAction func textButtonMenuColorAction(_ sender: Any) {
        
        history.noteChange(textButtonMenuColorPicker.tag, ColorSchemes.systemScheme.general.textButtonMenuColor, textButtonMenuColorPicker.color, .changeColor)
        changeTextButtonMenuColor()
    }
    
    private func changeTextButtonMenuColor() {
        
        ColorSchemes.systemScheme.general.textButtonMenuColor = textButtonMenuColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeTextButtonMenuColor, textButtonMenuColorPicker.color))
    }
    
    @IBAction func toggleButtonOffStateColorAction(_ sender: Any) {
        
        history.noteChange(toggleButtonOffStateColorPicker.tag, ColorSchemes.systemScheme.general.toggleButtonOffStateColor, toggleButtonOffStateColorPicker.color, .changeColor)
        changeToggleButtonOffStateColor()
    }
    
    private func changeToggleButtonOffStateColor() {
        
        ColorSchemes.systemScheme.general.toggleButtonOffStateColor = toggleButtonOffStateColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeToggleButtonOffStateColor, toggleButtonOffStateColorPicker.color))
    }
    
    @IBAction func selectedTabButtonColorAction(_ sender: Any) {
        
        history.noteChange(selectedTabButtonColorPicker.tag, ColorSchemes.systemScheme.general.selectedTabButtonColor, selectedTabButtonColorPicker.color, .changeColor)
        changeSelectedTabButtonColor()
    }
    
    private func changeSelectedTabButtonColor() {
        
        ColorSchemes.systemScheme.general.selectedTabButtonColor = selectedTabButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeSelectedTabButtonColor, selectedTabButtonColorPicker.color))
    }
    
    @IBAction func mainCaptionTextColorAction(_ sender: Any) {
        
        history.noteChange(mainCaptionTextColorPicker.tag, ColorSchemes.systemScheme.general.mainCaptionTextColor, mainCaptionTextColorPicker.color, .changeColor)
        changeMainCaptionTextColor()
    }
    
    private func changeMainCaptionTextColor() {
        
        ColorSchemes.systemScheme.general.mainCaptionTextColor = mainCaptionTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeMainCaptionTextColor, mainCaptionTextColorPicker.color))
    }
    
    @IBAction func tabButtonTextColorAction(_ sender: Any) {
        
        history.noteChange(tabButtonTextColorPicker.tag, ColorSchemes.systemScheme.general.tabButtonTextColor, tabButtonTextColorPicker.color, .changeColor)
        changeTabButtonTextColor()
    }
    
    private func changeTabButtonTextColor()	{
        
        ColorSchemes.systemScheme.general.tabButtonTextColor = tabButtonTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeTabButtonTextColor, tabButtonTextColorPicker.color))
    }
    
    @IBAction func selectedTabButtonTextColorAction(_ sender: Any) {
        
        history.noteChange(selectedTabButtonTextColorPicker.tag, ColorSchemes.systemScheme.general.selectedTabButtonTextColor, selectedTabButtonTextColorPicker.color, .changeColor)
        changeSelectedTabButtonTextColor()
    }
    
    private func changeSelectedTabButtonTextColor()    {
        
        ColorSchemes.systemScheme.general.selectedTabButtonTextColor = selectedTabButtonTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeSelectedTabButtonTextColor, selectedTabButtonTextColorPicker.color))
    }
    
    @IBAction func buttonMenuTextColorAction(_ sender: Any) {
        
        history.noteChange(buttonMenuTextColorPicker.tag, ColorSchemes.systemScheme.general.buttonMenuTextColor, buttonMenuTextColorPicker.color, .changeColor)
        changeButtonMenuTextColor()
    }
    
    private func changeButtonMenuTextColor() {
        
        ColorSchemes.systemScheme.general.buttonMenuTextColor = buttonMenuTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeButtonMenuTextColor, buttonMenuTextColorPicker.color))
    }
}
