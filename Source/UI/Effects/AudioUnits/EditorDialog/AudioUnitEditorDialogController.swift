import Cocoa

class AudioUnitEditorDialogController: NSWindowController, StringInputReceiver {
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var viewContainer: NSBox!
    
    @IBOutlet weak var factoryPresetsMenu: NSPopUpButton!
    @IBOutlet weak var userPresetsMenu: NSPopUpButton!
    
    @IBOutlet weak var btnSavePreset: TintedImageButton!
    lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    override var windowNibName: String? {return "AudioUnitEditorDialog"}

    var currentlyDisplayedView: NSView?
    var audioUnit: HostedAudioUnitDelegateProtocol?
    
    func showDialog(for audioUnit: HostedAudioUnitDelegateProtocol) {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = self.window!
        }
        
        self.audioUnit = audioUnit
        
        audioUnit.presentView {view in
            
            self.viewContainer.addSubview(view)
            view.anchorToView(view.superview!)
            view.show()
            
            self.currentlyDisplayedView = view
        }
        
        lblTitle.stringValue = "Editing Audio Unit:  \(audioUnit.name)"
        
        UIUtils.showDialog(self.window!)
        
        (factoryPresetsMenu.menu?.delegate as? AudioUnitFactoryPresetsMenuDelegate)?.audioUnit = audioUnit
        (userPresetsMenu.menu?.delegate as? AudioUnitUserPresetsMenuDelegate)?.audioUnit = audioUnit
    }
    
    @IBAction func closeAction(_ sender: Any) {
        
        UIUtils.dismissDialog(self.window!)
        currentlyDisplayedView?.hide()
    }
    
    @IBAction func applyFactoryPresetAction(_ sender: Any) {
        
        if let presetName = factoryPresetsMenu.titleOfSelectedItem {
            audioUnit?.applyFactoryPreset(presetName)
        }
    }
    
    @IBAction func applyUserPresetAction(_ sender: Any) {
        
        if let presetName = userPresetsMenu.titleOfSelectedItem {
            audioUnit?.applyPreset(presetName)
        }
    }
    
    // Displays a popover to allow the user to name the new custom preset.
    @IBAction func saveUserPresetAction(_ sender: AnyObject) {
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
    }
    
    // MARK - StringInputReceiver functions
    
    var inputPrompt: String {
        return "Enter a new preset name:"
    }
    
    var defaultValue: String? {
        return "<New \(audioUnit?.name ?? "") preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        if let presets = audioUnit?.presets, presets.presetWithNameExists(string) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        audioUnit?.savePreset(string)
    }
}

class AudioUnitUserPresetsMenuDelegate: NSObject, NSMenuDelegate {
    
    var audioUnit: HostedAudioUnitDelegateProtocol?
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        while menu.items.count > 1 {
            menu.removeItem(at: 1)
        }
        
        if let userPresets = audioUnit?.presets {
            
            for preset in userPresets.userDefinedPresets {
                menu.insertItem(withTitle: preset.name, action: nil, keyEquivalent: "", at: 1)
            }
        }
    }
}

class AudioUnitFactoryPresetsMenuDelegate: NSObject, NSMenuDelegate {
    
    var audioUnit: HostedAudioUnitDelegateProtocol?
    
    func menuNeedsUpdate(_ menu: NSMenu) {

        while menu.items.count > 1 {
            menu.removeItem(at: 1)
        }
        
        if let factoryPresets = audioUnit?.factoryPresets {
            
            for preset in factoryPresets {
                menu.insertItem(withTitle: preset.name, action: nil, keyEquivalent: "", at: 1)
            }
        }
    }
}
