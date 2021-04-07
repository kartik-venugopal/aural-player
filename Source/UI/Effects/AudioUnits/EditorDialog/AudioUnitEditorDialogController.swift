import Cocoa

class AudioUnitEditorDialogController: NSWindowController, StringInputReceiver {
    
    @IBOutlet weak var rootContainer: NSBox!
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var viewContainer: NSBox!
    
    @IBOutlet weak var lblFactoryPresets: NSTextField!
    @IBOutlet weak var btnFactoryPresets: NSPopUpButton!
    
    @IBOutlet weak var lblUserPresets: NSTextField!
    @IBOutlet weak var btnUserPresets: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: TintedImageButton!
    
    lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    override var windowNibName: String? {return "AudioUnitEditorDialog"}

    var audioUnit: HostedAudioUnitDelegateProtocol!
    
    var factoryPresetsMenuDelegate: AudioUnitFactoryPresetsMenuDelegate!
    var userPresetsMenuDelegate: AudioUnitUserPresetsMenuDelegate!
    
    convenience init(for audioUnit: HostedAudioUnitDelegateProtocol) {
        
        self.init()
        self.audioUnit = audioUnit
        
        self.factoryPresetsMenuDelegate = AudioUnitFactoryPresetsMenuDelegate(for: audioUnit)
        self.userPresetsMenuDelegate = AudioUnitUserPresetsMenuDelegate(for: audioUnit)
    }
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        rootContainer.anchorToSuperview()
        
        audioUnit.presentView {auView in
            
            self.viewContainer.addSubview(auView)
            auView.anchorToSuperview()
            
            // Resize the window to exactly contain the audio unit's view.
            
            let curWindowSize: NSSize = self.window!.frame.size
            let viewContainerSize: NSSize = self.viewContainer.frame.size
            
            let widthDelta = viewContainerSize.width - auView.frame.width
            let heightDelta = viewContainerSize.height - auView.frame.height
            
            self.window?.resizeTo(newWidth: curWindowSize.width - widthDelta, newHeight: curWindowSize.height - heightDelta)
        }
        
        lblTitle.stringValue = "Editing Audio Unit:  \(audioUnit.name)"
        
        initFactoryPresets()
        initUserPresets()
    }
    
    func showDialog() {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = self.window!
        }
        
        UIUtils.showDialog(self.window!)
    }
    
    private func initFactoryPresets() {
        
        let shouldShowFactoryPresets: Bool = self.audioUnit?.factoryPresets.isNonEmpty ?? false
        [lblFactoryPresets, btnFactoryPresets].forEach {$0?.showIf(shouldShowFactoryPresets)}
        btnFactoryPresets.menu?.delegate = self.factoryPresetsMenuDelegate
    }
    
    private func initUserPresets() {
        
        let shouldShowUserPresets: Bool = self.audioUnit?.supportsUserPresets ?? false
        [lblUserPresets, btnUserPresets, btnSavePreset].forEach {$0?.showIf(shouldShowUserPresets)}
        btnUserPresets.menu?.delegate = self.userPresetsMenuDelegate
    }
    
    @IBAction func closeAction(_ sender: Any) {
        UIUtils.dismissDialog(self.window!)
    }
    
    @IBAction func applyFactoryPresetAction(_ sender: Any) {
        
        if let presetName = btnFactoryPresets.titleOfSelectedItem {
            audioUnit.applyFactoryPreset(presetName)
        }
    }
    
    @IBAction func applyUserPresetAction(_ sender: Any) {
        
        if let presetName = btnUserPresets.titleOfSelectedItem {
            audioUnit.applyPreset(presetName)
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
        return "<New \(audioUnit.name) preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let presets = audioUnit.presets
        
        if presets.presetWithNameExists(string) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        audioUnit.savePreset(string)
    }
}

class AudioUnitUserPresetsMenuDelegate: NSObject, NSMenuDelegate {
    
    var audioUnit: HostedAudioUnitDelegateProtocol!
    
    convenience init(for audioUnit: HostedAudioUnitDelegateProtocol) {

        self.init()
        self.audioUnit = audioUnit
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        while menu.items.count > 1 {
            menu.removeItem(at: 1)
        }
        
        if let userPresets = audioUnit?.presets {
            
            for preset in userPresets.userDefinedPresets.sorted(by: {$0.name < $1.name}) {
                menu.addItem(withTitle: preset.name, action: nil, keyEquivalent: "")
            }
        }
    }
}

class AudioUnitFactoryPresetsMenuDelegate: NSObject, NSMenuDelegate {
    
    var audioUnit: HostedAudioUnitDelegateProtocol!
    
    convenience init(for audioUnit: HostedAudioUnitDelegateProtocol) {

        self.init()
        self.audioUnit = audioUnit
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {

        while menu.items.count > 1 {
            menu.removeItem(at: 1)
        }
        
        if let factoryPresets = audioUnit?.factoryPresets {
            
            for preset in factoryPresets.sorted(by: {$0.name < $1.name}) {
                menu.addItem(withTitle: preset.name, action: nil, keyEquivalent: "")
            }
        }
    }
}
