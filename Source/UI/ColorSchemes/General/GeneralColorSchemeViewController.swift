import Cocoa

/*
    Controller for the view that allows the user to edit general color scheme elements.
 */
class GeneralColorSchemeViewController: ColorSchemeViewController {
    
    @IBOutlet weak var appLogoColorPicker: AuralColorPicker!
    @IBOutlet weak var backgroundColorPicker: AuralColorPicker!
    
    @IBOutlet weak var viewControlButtonColorPicker: AuralColorPicker!
    @IBOutlet weak var functionButtonColorPicker: AuralColorPicker!
    @IBOutlet weak var textButtonMenuColorPicker: AuralColorPicker!
    @IBOutlet weak var toggleButtonOffStateColorPicker: AuralColorPicker!
    @IBOutlet weak var selectedTabButtonColorPicker: AuralColorPicker!
    
    @IBOutlet weak var mainCaptionTextColorPicker: AuralColorPicker!
    @IBOutlet weak var tabButtonTextColorPicker: AuralColorPicker!
    @IBOutlet weak var selectedTabButtonTextColorPicker: AuralColorPicker!
    @IBOutlet weak var buttonMenuTextColorPicker: AuralColorPicker!
    
    override var nibName: NSNib.Name? {return "GeneralColorScheme"}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Map control tags to their corresponding undo/redo actions
        
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
    
    override func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard!) {
        
        super.resetFields(scheme, history, clipboard)
        
        // Update the UI to reflect the current system color scheme
        
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
    }
    
    @IBAction func appLogoColorAction(_ sender: Any) {
        
        history.noteChange(appLogoColorPicker.tag, ColorSchemes.systemScheme.general.appLogoColor, appLogoColorPicker.color, .changeColor)
        changeAppLogoColor()
    }
    
    private func changeAppLogoColor() {
        
        ColorSchemes.systemScheme.general.appLogoColor = appLogoColorPicker.color
        Messenger.publish(.changeAppLogoColor, payload: appLogoColorPicker.color)
    }
    
    @IBAction func backgroundColorAction(_ sender: Any) {
        
        history.noteChange(backgroundColorPicker.tag, ColorSchemes.systemScheme.general.backgroundColor, backgroundColorPicker.color, .changeColor)
        changeBackgroundColor()
    }
    
    private func changeBackgroundColor() {
        
        ColorSchemes.systemScheme.general.backgroundColor = backgroundColorPicker.color
        Messenger.publish(.changeBackgroundColor, payload: backgroundColorPicker.color)
        
        print("\nBkgr ccolor: \(backgroundColorPicker.color)")
    }
    
    @IBAction func viewControlButtonColorAction(_ sender: Any) {
        
        history.noteChange(viewControlButtonColorPicker.tag, ColorSchemes.systemScheme.general.viewControlButtonColor, viewControlButtonColorPicker.color, .changeColor)
        changeViewControlButtonColor()
    }
    
    private func changeViewControlButtonColor() {
        
        ColorSchemes.systemScheme.general.viewControlButtonColor = viewControlButtonColorPicker.color
        Messenger.publish(.changeViewControlButtonColor, payload: viewControlButtonColorPicker.color)
    }
    
    @IBAction func functionButtonColorAction(_ sender: Any) {
        
        history.noteChange(functionButtonColorPicker.tag, ColorSchemes.systemScheme.general.functionButtonColor, functionButtonColorPicker.color, .changeColor)
        changeFunctionButtonColor()
    }
    
    private func changeFunctionButtonColor() {
        
        ColorSchemes.systemScheme.general.functionButtonColor = functionButtonColorPicker.color
        Messenger.publish(.changeFunctionButtonColor, payload: functionButtonColorPicker.color)
    }
    
    @IBAction func textButtonMenuColorAction(_ sender: Any) {
        
        history.noteChange(textButtonMenuColorPicker.tag, ColorSchemes.systemScheme.general.textButtonMenuColor, textButtonMenuColorPicker.color, .changeColor)
        changeTextButtonMenuColor()
    }
    
    private func changeTextButtonMenuColor() {
        
        ColorSchemes.systemScheme.general.textButtonMenuColor = textButtonMenuColorPicker.color
        Messenger.publish(.changeTextButtonMenuColor, payload: textButtonMenuColorPicker.color)
    }
    
    @IBAction func toggleButtonOffStateColorAction(_ sender: Any) {
        
        history.noteChange(toggleButtonOffStateColorPicker.tag, ColorSchemes.systemScheme.general.toggleButtonOffStateColor, toggleButtonOffStateColorPicker.color, .changeColor)
        changeToggleButtonOffStateColor()
    }
    
    private func changeToggleButtonOffStateColor() {
        
        ColorSchemes.systemScheme.general.toggleButtonOffStateColor = toggleButtonOffStateColorPicker.color
        Messenger.publish(.changeToggleButtonOffStateColor, payload: toggleButtonOffStateColorPicker.color)
    }
    
    @IBAction func selectedTabButtonColorAction(_ sender: Any) {
        
        history.noteChange(selectedTabButtonColorPicker.tag, ColorSchemes.systemScheme.general.selectedTabButtonColor, selectedTabButtonColorPicker.color, .changeColor)
        changeSelectedTabButtonColor()
    }
    
    private func changeSelectedTabButtonColor() {
        
        ColorSchemes.systemScheme.general.selectedTabButtonColor = selectedTabButtonColorPicker.color
        Messenger.publish(.changeSelectedTabButtonColor, payload: selectedTabButtonColorPicker.color)
    }
    
    @IBAction func mainCaptionTextColorAction(_ sender: Any) {
        
        history.noteChange(mainCaptionTextColorPicker.tag, ColorSchemes.systemScheme.general.mainCaptionTextColor, mainCaptionTextColorPicker.color, .changeColor)
        changeMainCaptionTextColor()
    }
    
    private func changeMainCaptionTextColor() {
        
        ColorSchemes.systemScheme.general.mainCaptionTextColor = mainCaptionTextColorPicker.color
        Messenger.publish(.changeMainCaptionTextColor, payload: mainCaptionTextColorPicker.color)
    }
    
    @IBAction func tabButtonTextColorAction(_ sender: Any) {
        
        history.noteChange(tabButtonTextColorPicker.tag, ColorSchemes.systemScheme.general.tabButtonTextColor, tabButtonTextColorPicker.color, .changeColor)
        changeTabButtonTextColor()
    }
    
    private func changeTabButtonTextColor()	{
        
        ColorSchemes.systemScheme.general.tabButtonTextColor = tabButtonTextColorPicker.color
        Messenger.publish(.changeTabButtonTextColor, payload: tabButtonTextColorPicker.color)
    }
    
    @IBAction func selectedTabButtonTextColorAction(_ sender: Any) {
        
        history.noteChange(selectedTabButtonTextColorPicker.tag, ColorSchemes.systemScheme.general.selectedTabButtonTextColor, selectedTabButtonTextColorPicker.color, .changeColor)
        changeSelectedTabButtonTextColor()
    }
    
    private func changeSelectedTabButtonTextColor()    {
        
        ColorSchemes.systemScheme.general.selectedTabButtonTextColor = selectedTabButtonTextColorPicker.color
        Messenger.publish(.changeSelectedTabButtonTextColor, payload: selectedTabButtonTextColorPicker.color)
    }
    
    @IBAction func buttonMenuTextColorAction(_ sender: Any) {
        
        history.noteChange(buttonMenuTextColorPicker.tag, ColorSchemes.systemScheme.general.buttonMenuTextColor, buttonMenuTextColorPicker.color, .changeColor)
        changeButtonMenuTextColor()
    }
    
    private func changeButtonMenuTextColor() {
        
        ColorSchemes.systemScheme.general.buttonMenuTextColor = buttonMenuTextColorPicker.color
        Messenger.publish(.changeButtonMenuTextColor, payload: buttonMenuTextColorPicker.color)
    }
}
