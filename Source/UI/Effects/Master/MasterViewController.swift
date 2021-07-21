//
//  MasterViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MasterViewController: EffectsUnitViewController {
    
    @IBOutlet weak var masterView: MasterView!
    
    @IBOutlet weak var audioUnitsScrollView: NSScrollView!
    @IBOutlet weak var audioUnitsClipView: NSClipView!
    @IBOutlet weak var audioUnitsTable: NSTableView!
    
    private let soundPreferences: SoundPreferences = objectGraph.preferences.soundPreferences
    private let playbackPreferences: PlaybackPreferences = objectGraph.preferences.playbackPreferences
    
    private var masterUnit: MasterUnitDelegateProtocol {return graph.masterUnit}
    private var eqUnit: EQUnitDelegateProtocol {return graph.eqUnit}
    private var pitchShiftUnit: PitchShiftUnitDelegateProtocol {return graph.pitchShiftUnit}
    private var timeStretchUnit: TimeStretchUnitDelegateProtocol {return graph.timeStretchUnit}
    private var reverbUnit: ReverbUnitDelegateProtocol {return graph.reverbUnit}
    private var delayUnit: DelayUnitDelegateProtocol {return graph.delayUnit}
    private var filterUnit: FilterUnitDelegateProtocol {return graph.filterUnit}
    
    private let soundProfiles: SoundProfiles = objectGraph.audioGraphDelegate.soundProfiles
    
    override var nibName: String? {"Master"}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .master
        effectsUnit = masterUnit
        presetsWrapper = PresetsWrapper<MasterPreset, MasterPresets>(masterUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        
        let auStateFunction: EffectsUnitStateFunction = {[weak self] in
            
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
        
        masterView.initialize(graph.eqUnit.stateFunction, graph.pitchShiftUnit.stateFunction, graph.timeStretchUnit.stateFunction, graph.reverbUnit.stateFunction, graph.delayUnit.stateFunction, graph.filterUnit.stateFunction, auStateFunction)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackChanged(_:),
                                 filter: {msg in msg.trackChanged})
        
        messenger.subscribe(to: .masterEffectsUnit_toggleEffects, handler: toggleEffects)
        messenger.subscribe(to: .auEffectsUnit_audioUnitsAddedOrRemoved, handler: refreshAUTable)
        
        messenger.subscribe(to: .changeBackgroundColor, handler: changeBackgroundColor(_:))
    }
    
    override func initControls() {
        
        super.initControls()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    @IBAction override func bypassAction(_ sender: AnyObject) {
        
        super.bypassAction(sender)
        updateButtons()
        broadcastStateChangeNotification()
        
        messenger.publish(.effects_playbackRateChanged, payload: timeStretchUnit.effectiveRate)
        
        audioUnitsTable.reloadData()
    }
    
    private func toggleEffects() {
        bypassAction(self)
    }
    
    @IBAction override func presetsAction(_ sender: AnyObject) {
        
        super.presetsAction(sender)
        messenger.publish(.effects_updateEffectsUnitView, payload: EffectsUnitType.master)
    }
    
    private func updateButtons() {
        btnBypass.updateState()
        masterView.stateChanged()
    }
    
    private func broadcastStateChangeNotification() {
        // Update the bypass buttons for the effects units
        messenger.publish(.effects_unitStateChanged)
    }
    
    @IBAction func eqBypassAction(_ sender: AnyObject) {
        
        _ = eqUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        _ = pitchShiftUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        _ = timeStretchUnit.toggleState()
        
        messenger.publish(.effects_playbackRateChanged, payload: timeStretchUnit.effectiveRate)
        
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        _ = reverbUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        _ = delayUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        _ = filterUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    func trackChanged(_ notification: TrackTransitionNotification) {
        
        // Apply sound profile if there is one for the new track and if the preferences allow it
        if let newTrack = notification.endTrack, soundProfiles.hasFor(newTrack) {
            
            updateButtons()
            messenger.publish(.effects_updateEffectsUnitView, payload: EffectsUnitType.master)
        }
    }
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        
        lblCaption.font = fontSchemesManager.systemScheme.effects.unitCaptionFont
        
        functionLabels.forEach {
            
            $0.font = $0 is EffectsUnitTriStateLabel ? fontSchemesManager.systemScheme.effects.masterUnitFunctionFont :
                fontSchemesManager.systemScheme.effects.unitCaptionFont
        }
        
        presetsMenu.font = .menuFont
        
        audioUnitsTable.reloadAllRows(columns: [1])
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        
        changeBackgroundColor(scheme.general.backgroundColor)
        audioUnitsTable.reloadData()
    }
    
    func changeBackgroundColor(_ color: NSColor) {
        
        audioUnitsScrollView.backgroundColor = color
        audioUnitsClipView.backgroundColor = color
        audioUnitsTable.backgroundColor = color
    }
    
    override func changeFunctionCaptionTextColor(_ color: NSColor) {
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        masterView.changeActiveUnitStateColor(color)
        
        let rowsForActiveUnits: [Int] = audioUnitsTable.allRowIndices.filter {graph.audioUnits[$0].state == .active}
        audioUnitsTable.reloadRows(rowsForActiveUnits, columns: [0, 1])
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        masterView.changeBypassedUnitStateColor(color)
        
        let rowsForBypassedUnits: [Int] = audioUnitsTable.allRowIndices.filter {graph.audioUnits[$0].state == .bypassed}
        audioUnitsTable.reloadRows(rowsForBypassedUnits, columns: [0, 1])
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        // Master unit can never be suppressed, but update other unit state buttons
        masterView.changeSuppressedUnitStateColor(color)
        
        let rowsForSuppressedUnits: [Int] = audioUnitsTable.allRowIndices.filter {graph.audioUnits[$0].state == .suppressed}
        audioUnitsTable.reloadRows(rowsForSuppressedUnits, columns: [0, 1])
    }
    
    // MARK: Message handling
    
    override func stateChanged() {
        
        updateButtons()
        messenger.publish(.effects_playbackRateChanged, payload: timeStretchUnit.effectiveRate)
        
        audioUnitsTable.reloadData()
    }
    
    private func refreshAUTable() {
        audioUnitsTable.reloadData()
    }
}
