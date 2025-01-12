//
//  AudioUnitEditorDialogController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class AudioUnitEditorDialogController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"AudioUnitEditorDialog"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var btnClose: TintedImageButton!
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var factoryPresetsMenu: NSMenu!
    @IBOutlet weak var userPresetsMenu: NSMenu!
    @IBOutlet weak var presetsMenuIcon: TintedIconMenuItem!
    
    @IBOutlet weak var viewContainer: NSBox!
    
    lazy var userPresetsPopover: StringInputPopoverViewController = .create(self)
    lazy var messenger = Messenger(for: self)
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var audioUnit: HostedAudioUnitDelegateProtocol!
    
    lazy var userPresetsMenuDelegate: AudioUnitUserPresetsMenuDelegate = AudioUnitUserPresetsMenuDelegate(for: audioUnit, applyPresetAction: #selector(self.applyUserPresetAction(_:)), target: self)
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    convenience init(for audioUnit: HostedAudioUnitDelegateProtocol) {
        
        self.init()
        self.audioUnit = audioUnit
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        window?.identifier = .init("auEditor_\(audioUnit.id)")
        
        window?.isMovableByWindowBackground = true
        rootContainer.anchorToSuperview()
        
        audioUnit.presentView {[weak self] auView in
            
            guard let strongSelf = self else {return}
            
            strongSelf.viewContainer.addSubview(auView)
            auView.anchorToSuperview()
            
            // Resize the window to exactly contain the audio unit's view.
            
            let curWindowSize: NSSize = strongSelf.theWindow.size
            let viewContainerSize: NSSize = strongSelf.viewContainer.size
            
            let widthDelta = viewContainerSize.width - auView.width
            let heightDelta = viewContainerSize.height - auView.height
            
            strongSelf.theWindow.resize(curWindowSize.width - widthDelta, curWindowSize.height - heightDelta)
        }
        
        lblTitle.stringValue = "\(audioUnit.name) v\(audioUnit.version) by \(audioUnit.manufacturerName)"
        
        if let factoryPresets = audioUnit?.factoryPresets {
            
            for preset in factoryPresets.sorted(by: {$0.name < $1.name}) {
                
                factoryPresetsMenu.addItem(withTitle: preset.name,
                                           action: #selector(applyFactoryPresetAction(_:)),
                                           target: self)
            }
        }
        
        userPresetsMenu.delegate = userPresetsMenuDelegate
        
        changeWindowCornerRadius(to: playerUIState.cornerRadius)
        messenger.subscribe(to: .View.changeWindowCornerRadius, handler: changeWindowCornerRadius(to:))
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainer)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: [btnClose, presetsMenuIcon])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblTitle)
    }
    
    override func destroy() {
        
        messenger.unsubscribeFromAll()
//        userPresetsPopover.destroy()
    }
    
    func changeWindowCornerRadius(to radius: CGFloat) {
        rootContainer.cornerRadius = radius
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    override func showWindow(_ sender: Any?) {
        theWindow.showCenteredOnScreen()
    }
    
    @IBAction func applyFactoryPresetAction(_ sender: NSMenuItem) {
        audioUnit.applyFactoryPreset(named: sender.title)
    }
    
    @IBAction func applyUserPresetAction(_ sender: NSMenuItem) {
        audioUnit.applyPreset(named: sender.title)
    }
    
    // Displays a popover to allow the user to name the new custom preset.
    @IBAction func saveUserPresetAction(_ sender: AnyObject) {
        userPresetsPopover.show(rootContainer, .maxX)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        theWindow.close()
    }
}

extension AudioUnitEditorDialogController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        lblTitle.font = systemFontScheme.captionFont
    }
}

extension AudioUnitEditorDialogController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainer.fillColor = systemColorScheme.backgroundColor
        lblTitle.textColor = systemColorScheme.captionTextColor
        presetsMenuIcon.colorChanged(systemColorScheme.buttonColor)
        btnClose.colorChanged(systemColorScheme.buttonColor)
    }
}

///
/// Prevents the AU editor window from moving when some custom AU views are manipulated (eg. circular sliders)
///
class AUViewContainer: MouseTrackingView {

    override func mouseEntered(with event: NSEvent) {
        
        super.mouseEntered(with: event)
        window?.isMovable = false
    }
    
    override func mouseExited(with event: NSEvent) {
        
        super.mouseExited(with: event)
        window?.isMovable = true
    }
}
