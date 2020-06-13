/*
 View controller for the Effects panel containing controls that alter the sound output (i.e. controls that affect the audio graph)
 */

import Cocoa

class EffectsWindowController: NSWindowController, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var effectsContainerBox: NSBox!
    @IBOutlet weak var tabButtonsBox: NSBox!

    // The constituent sub-views, one for each effects unit

    private let masterView: NSView = ViewFactory.masterView
    private let eqView: NSView = ViewFactory.eqView
    private let pitchView: NSView = ViewFactory.pitchView
    private let timeView: NSView = ViewFactory.timeView
    private let reverbView: NSView = ViewFactory.reverbView
    private let delayView: NSView = ViewFactory.delayView
    private let filterView: NSView = ViewFactory.filterView
    private let recorderView: NSView = ViewFactory.recorderView

    // Tab view and its buttons

    @IBOutlet weak var fxTabView: NSTabView!

    @IBOutlet weak var masterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var eqTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var pitchTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var timeTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var reverbTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var delayTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var filterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var recorderTabViewButton: EffectsUnitTabButton!

    private var fxTabViewButtons: [EffectsUnitTabButton]!
    
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var viewMenuButton: NSPopUpButton!
    @IBOutlet weak var viewMenuIconItem: TintedIconMenuItem!

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
        theWindow.delegate = WindowManager.windowDelegate

        EffectsViewState.initialize(ObjectGraph.appState.ui.effects)
        
        btnClose.tintFunction = {return Colors.viewControlButtonColor}
        
        changeTextSize()
        SyncMessenger.publishActionMessage(TextSizeActionMessage(.changeEffectsTextSize, EffectsViewState.textSize))
        
        applyColorScheme(ColorSchemes.systemScheme)
        
        initUnits()
        initTabGroup()
        initSubscriptions()
    }

    private func addSubViews() {

        fxTabView.tabViewItem(at: 0).view?.addSubview(masterView)
        fxTabView.tabViewItem(at: 1).view?.addSubview(eqView)
        fxTabView.tabViewItem(at: 2).view?.addSubview(pitchView)
        fxTabView.tabViewItem(at: 3).view?.addSubview(timeView)
        fxTabView.tabViewItem(at: 4).view?.addSubview(reverbView)
        fxTabView.tabViewItem(at: 5).view?.addSubview(delayView)
        fxTabView.tabViewItem(at: 6).view?.addSubview(filterView)
        fxTabView.tabViewItem(at: 7).view?.addSubview(recorderView)

        fxTabViewButtons = [masterTabViewButton, eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton]
        
        masterTabViewButton.stateFunction = graph.masterUnit.stateFunction
        eqTabViewButton.stateFunction = graph.eqUnit.stateFunction
        pitchTabViewButton.stateFunction = graph.pitchUnit.stateFunction
        timeTabViewButton.stateFunction = graph.timeUnit.stateFunction
        reverbTabViewButton.stateFunction = graph.reverbUnit.stateFunction
        delayTabViewButton.stateFunction = graph.delayUnit.stateFunction
        filterTabViewButton.stateFunction = graph.filterUnit.stateFunction
        recorderTabViewButton.stateFunction = {return self.recorder.isRecording ? .active : .bypassed}
    }

    private func initUnits() {

        [masterTabViewButton, eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton].forEach({$0?.updateState()})
    }

    private func initTabGroup() {

        // Select Master tab view by default
        tabViewAction(masterTabViewButton)
    }

    private func initSubscriptions() {

        Messenger.subscribe(self, .fxUnitStateChanged, self.stateChanged)
        
        SyncMessenger.subscribe(actionTypes: [.showEffectsUnitTab, .changeEffectsTextSize, .applyColorScheme, .changeBackgroundColor, .changeViewControlButtonColor, .changeEffectsActiveUnitStateColor, .changeEffectsBypassedUnitStateColor, .changeEffectsSuppressedUnitStateColor, .changeSelectedTabButtonColor], subscriber: self)
    }

    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: NSButton) {

        // Set sender button state, reset all other button states
        
        // TODO: Add a field "isSelected" to the tab button control to distinguish between "state" (on/off) and "selected"
        fxTabViewButtons!.forEach({$0.state = convertToNSControlStateValue(0)})
        sender.state = convertToNSControlStateValue(1)

        // Button tag is the tab index
        fxTabView.selectTabViewItem(at: sender.tag)
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.toggleEffects))
    }
    
    private func changeTextSize() {
        viewMenuButton.font = Fonts.Effects.menuFont
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeViewControlButtonColor(scheme.general.viewControlButtonColor)
        
        fxTabViewButtons.forEach({$0.reTint()})
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        rootContainerBox.fillColor = color
        
        [effectsContainerBox, tabButtonsBox].forEach({
            $0!.fillColor = color
            $0!.isTransparent = !color.isOpaque
        })
        
        fxTabViewButtons.forEach({$0.redraw()})
    }
    
    private func changeViewControlButtonColor(_ color: NSColor) {
        
        [btnClose, viewMenuIconItem].forEach({
            ($0 as? Tintable)?.reTint()
        })
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
    
    private func changeSelectedTabButtonColor() {
        fxTabViewButtons[fxTabView.selectedIndex].redraw()
    }

    // MARK: Message handling

    // Notification that an effect unit's state has changed (active/inactive)
    func stateChanged() {

        // Update the tab button states
        fxTabViewButtons.forEach({$0.updateState()})
    }

    // Dummy implementation
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }

    func consumeMessage(_ message: ActionMessage) {

        if let message = message as? EffectsViewActionMessage {

            switch message.actionType {

            // Action message to switch tabs
            case .showEffectsUnitTab:

                switch message.effectsUnit {

                case .eq: tabViewAction(eqTabViewButton)

                case .pitch: tabViewAction(pitchTabViewButton)

                case .time: tabViewAction(timeTabViewButton)

                case .reverb: tabViewAction(reverbTabViewButton)

                case .delay: tabViewAction(delayTabViewButton)

                case .filter: tabViewAction(filterTabViewButton)

                case .recorder: tabViewAction(recorderTabViewButton)
                    
                case .master: tabViewAction(masterTabViewButton)
                    
                }

            default: return

            }
        }
        
        if message is TextSizeActionMessage {
            
            changeTextSize()
            return
        }
        
        if let colorSchemeMsg = message as? ColorSchemeActionMessage {
            
            applyColorScheme(colorSchemeMsg.scheme)
            return
        }
        
        if let colorChangeMsg = message as? ColorSchemeComponentActionMessage {
            
            switch colorChangeMsg.actionType {
                
            case .changeBackgroundColor:
                
                changeBackgroundColor(colorChangeMsg.color)
                
            case .changeViewControlButtonColor:
                
                changeViewControlButtonColor(colorChangeMsg.color)
                
            case .changeEffectsActiveUnitStateColor:
                
                changeActiveUnitStateColor(colorChangeMsg.color)
                
            case .changeEffectsBypassedUnitStateColor:
                
                changeBypassedUnitStateColor(colorChangeMsg.color)
                
            case .changeEffectsSuppressedUnitStateColor:
                
                changeSuppressedUnitStateColor(colorChangeMsg.color)
                
            case .changeSelectedTabButtonColor:
                
                changeSelectedTabButtonColor()
                
            default: return
                
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSControlStateValue(_ input: Int) -> NSControl.StateValue {
	return NSControl.StateValue(rawValue: input)
}
