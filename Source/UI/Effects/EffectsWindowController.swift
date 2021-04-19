/*
 View controller for the Effects panel containing controls that alter the sound output (i.e. controls that affect the audio graph)
 */

import Cocoa

class EffectsWindowController: NSWindowController, NotificationSubscriber, Destroyable {
    
    deinit {
        print("\nDeinited \(self.className)")
    }
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var effectsContainerBox: NSBox!
    @IBOutlet weak var tabButtonsBox: NSBox!

    // The constituent sub-views, one for each effects unit
    
    private let masterViewController: MasterViewController = MasterViewController()
    private let eqViewController: EQViewController = EQViewController()
    private let pitchViewController: PitchViewController = PitchViewController()
    private let timeViewController: TimeViewController = TimeViewController()
    private let reverbViewController: ReverbViewController = ReverbViewController()
    private let delayViewController: DelayViewController = DelayViewController()
    private let filterViewController: FilterViewController = FilterViewController()
    private let auViewController: AudioUnitsViewController = AudioUnitsViewController()
    private let recorderViewController: RecorderViewController = RecorderViewController()

    // Tab view and its buttons

    @IBOutlet weak var fxTabView: NSTabView!

    @IBOutlet weak var masterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var eqTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var pitchTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var timeTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var reverbTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var delayTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var filterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var auTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var recorderTabViewButton: EffectsUnitTabButton!

    private var fxTabViewButtons: [EffectsUnitTabButton] = []
    
    @IBOutlet weak var btnClose: TintedImageButton!

    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    private let recorder: RecorderDelegateProtocol = ObjectGraph.recorderDelegate

    private let preferences: ViewPreferences = ObjectGraph.preferencesDelegate.preferences.viewPreferences

    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }
    
    override var windowNibName: String? {return "Effects"}

    override func windowDidLoad() {
        
        // Initialize all sub-views
        addSubViews()

        theWindow.isMovableByWindowBackground = true

        btnClose.tintFunction = {return Colors.viewControlButtonColor}
        
        applyColorScheme(ColorSchemes.systemScheme)
        rootContainerBox.cornerRadius = WindowAppearanceState.cornerRadius
        
        initUnits()
        initTabGroup()
        initSubscriptions()
    }

    private func addSubViews() {
        
        for (index, viewController) in [masterViewController, eqViewController, pitchViewController, timeViewController, reverbViewController, delayViewController, filterViewController, auViewController, recorderViewController].enumerated() {
            
            fxTabView.tabViewItem(at: index).view?.addSubview(viewController.view)
        }

        fxTabViewButtons = [masterTabViewButton, eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, auTabViewButton, recorderTabViewButton]
        
        masterTabViewButton.stateFunction = graph.masterUnit.stateFunction
        eqTabViewButton.stateFunction = graph.eqUnit.stateFunction
        pitchTabViewButton.stateFunction = graph.pitchUnit.stateFunction
        timeTabViewButton.stateFunction = graph.timeUnit.stateFunction
        reverbTabViewButton.stateFunction = graph.reverbUnit.stateFunction
        delayTabViewButton.stateFunction = graph.delayUnit.stateFunction
        filterTabViewButton.stateFunction = graph.filterUnit.stateFunction

        auTabViewButton.stateFunction = {[weak self] in

            for unit in self?.graph.audioUnits ?? [] {

                if unit.state == .active {
                    return .active
                }
                
                if unit.state == .suppressed {
                    return .suppressed
                }
            }
            
            return .bypassed
        }

        recorderTabViewButton.stateFunction = {[weak self] in
            return (self?.recorder.isRecording ?? false) ? .active : .bypassed
        }
    }

    private func initUnits() {
        fxTabViewButtons.forEach {$0.updateState()}
    }

    private func initTabGroup() {

        // Select Master tab view by default
        tabViewAction(masterTabViewButton)
    }

    private func initSubscriptions() {

        Messenger.subscribe(self, .fx_unitStateChanged, self.stateChanged)
        
        // MARK: Commands ----------------------------------------------------------------------------------------
        
        Messenger.subscribe(self, .fx_showFXUnitTab, self.showTab(_:))
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeBackgroundColor, self.changeBackgroundColor(_:))
        Messenger.subscribe(self, .changeViewControlButtonColor, self.changeViewControlButtonColor(_:))
        Messenger.subscribe(self, .changeSelectedTabButtonColor, self.changeSelectedTabButtonColor(_:))
        Messenger.subscribe(self, .windowAppearance_changeCornerRadius, self.changeWindowCornerRadius(_:))
        
        Messenger.subscribe(self, .fx_changeActiveUnitStateColor, self.changeActiveUnitStateColor(_:))
        Messenger.subscribe(self, .fx_changeBypassedUnitStateColor, self.changeBypassedUnitStateColor(_:))
        Messenger.subscribe(self, .fx_changeSuppressedUnitStateColor, self.changeSuppressedUnitStateColor(_:))
    }
    
    func destroy() {
        
        close()
        Messenger.unsubscribeAll(for: self)
    }

    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: NSButton) {

        // Set sender button state, reset all other button states
        
        // TODO: Add a field "isSelected" to the tab button control to distinguish between "state" (on/off) and "selected"
        fxTabViewButtons.forEach {$0.state = convertToNSControlStateValue(0)}
        sender.state = convertToNSControlStateValue(1)

        // Button tag is the tab index
        fxTabView.selectTabViewItem(at: sender.tag)
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        Messenger.publish(.windowManager_toggleEffectsWindow)
    }
    
    private func applyTheme() {
        
        applyColorScheme(ColorSchemes.systemScheme)
        changeWindowCornerRadius(WindowAppearanceState.cornerRadius)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeViewControlButtonColor(scheme.general.viewControlButtonColor)
        
        fxTabViewButtons.forEach({$0.reTint()})
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        rootContainerBox.fillColor = color
        tabButtonsBox.fillColor = color
        
        fxTabViewButtons.forEach({$0.redraw()})
    }
    
    private func changeViewControlButtonColor(_ color: NSColor) {
        btnClose.reTint()
    }
    
    private func changeActiveUnitStateColor(_ color: NSColor) {
        
        fxTabViewButtons.forEach({
            
            if $0.unitState == .active {
                $0.reTint()
            }
        })
    }
    
    private func changeBypassedUnitStateColor(_ color: NSColor) {
        
        fxTabViewButtons.forEach({
            
            if $0.unitState == .bypassed {
                $0.reTint()
            }
        })
    }
    
    private func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        fxTabViewButtons.forEach({
            
            if $0.unitState == .suppressed {
                $0.reTint()
            }
        })
    }
    
    private func changeSelectedTabButtonColor(_ color: NSColor) {
        fxTabViewButtons[fxTabView.selectedIndex].redraw()
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }

    // MARK: Message handling

    // Notification that an effect unit's state has changed (active/inactive)
    func stateChanged() {

        // Update the tab button states
        fxTabViewButtons.forEach {$0.updateState()}
    }
    
    func showTab(_ fxUnit: EffectsUnit) {
        
        switch fxUnit {

        case .eq: tabViewAction(eqTabViewButton)

        case .pitch: tabViewAction(pitchTabViewButton)

        case .time: tabViewAction(timeTabViewButton)

        case .reverb: tabViewAction(reverbTabViewButton)

        case .delay: tabViewAction(delayTabViewButton)

        case .filter: tabViewAction(filterTabViewButton)
            
        case .au: tabViewAction(auTabViewButton)

        case .recorder: tabViewAction(recorderTabViewButton)
            
        case .master: tabViewAction(masterTabViewButton)
            
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSControlStateValue(_ input: Int) -> NSControl.StateValue {
	return NSControl.StateValue(rawValue: input)
}
