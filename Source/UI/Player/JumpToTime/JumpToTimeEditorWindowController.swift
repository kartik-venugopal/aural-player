//
//  JumpToTimeEditorWindowController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class JumpToTimeEditorWindowController: NSWindowController, ModalDialogDelegate {
    
    override var windowNibName: NSNib.Name? {"JumpToTimeEditorDialog"}
    
    @IBOutlet weak var lblTrackName: NSTextField!
    @IBOutlet weak var lblTrackDuration: NSTextField!
    
    @IBOutlet weak var btnHMS: NSButton!
    @IBOutlet weak var btnSeconds: NSButton!
    @IBOutlet weak var btnPercentage: NSButton!
    
    @IBOutlet weak var hmsFormatter: HMSTimeFormatter!
    @IBOutlet weak var secondsFormatter: TimeIntervalFormatter!
    
    @IBOutlet weak var percentageFormatter: TimeIntervalFormatter!
    
    @IBOutlet weak var txtHMS: NSTextField!
    @IBOutlet weak var hmsStepper: NSStepper!
    
    @IBOutlet weak var txtSeconds: NSTextField!
    @IBOutlet weak var secondsStepper: NSStepper!
    
    @IBOutlet weak var txtPercentage: NSTextField!
    @IBOutlet weak var percentageStepper: NSStepper!
    
    private lazy var messenger = Messenger(for: self)
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override func windowDidLoad() {
        
        hmsFormatter.valueFunction = {[weak self] () -> String in
            ValueFormatter.formatSecondsToHMS(self?.hmsStepper.doubleValue ?? 0)
        }
        
        hmsFormatter.updateFunction = {[weak self] (_ value: Double) in
            self?.hmsStepper.doubleValue = value
        }
        
        secondsFormatter.valueFunction = {[weak self] () -> String in
            String(describing: self?.secondsStepper.doubleValue ?? 0)
        }
        
        secondsFormatter.updateFunction = {[weak self] (_ value: Double) in
            self?.secondsStepper.doubleValue = value
        }
        
        percentageFormatter.valueFunction = {[weak self] () -> String in
            String(describing: self?.percentageStepper.doubleValue ?? 0)
        }
        
        percentageFormatter.updateFunction = {[weak self] (_ value: Double) in
            self?.percentageStepper.doubleValue = value
        }
        
        percentageFormatter.maxValue = 100
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:),
                                 filter: {[weak self] msg in self?.isModal ?? false})
    }
    
    override func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    var isModal: Bool {
        self.window?.isVisible ?? false
    }
    
    func showDialog() -> ModalDialogResponse {
        
        forceLoadingOfWindow()
        
        guard let playingTrack = player.playingTrack else {
            
            // Should never happen
            cancelAction(self)
            return modalDialogResponse
        }
            
        resetFields(playingTrack)
        theWindow.showCenteredOnScreen()
        modalDialogResponse = .ok
        
        return modalDialogResponse
    }
    
    func resetFields(_ playingTrack: Track) {
    
        let roundedDuration = round(playingTrack.duration)
        let formattedDuration = ValueFormatter.formatSecondsToHMS(roundedDuration)
        let durationInt = Int(roundedDuration)
        
        lblTrackName.stringValue = String(format: "Track:   %@", playingTrack.displayName)
        lblTrackDuration.stringValue = String(format: "Duration:   %@", formattedDuration)
        
        btnHMS.on()
        radioButtonAction(self)
        
        btnHMS.title = String(format: "Specify as hh : mm : ss (00:00:00 to %@)", formattedDuration)
        
        btnSeconds.title = String(format: "Specify as seconds (0 to %d)", durationInt)
        
        // Reset to 00:00:00
        
        hmsStepper.doubleValue = 0
        hmsStepper.maxValue = roundedDuration
        hmsFormatter.maxValue = roundedDuration
        hmsStepperAction(self)
        
        secondsFormatter.maxValue = roundedDuration
        secondsStepper.maxValue = roundedDuration
        secondsStepper.doubleValue = 0
        secondsStepperAction(self)
        
        percentageStepper.doubleValue = 0
        percentageStepperAction(self)
    }
    
    @IBAction func radioButtonAction(_ sender: Any) {
        
        [txtHMS, hmsStepper].forEach {$0?.enableIf(btnHMS.isOn)}
        
        if txtHMS.isEnabled {
            window?.makeFirstResponder(txtHMS)
        }
        
        [txtSeconds, secondsStepper].forEach {$0?.enableIf(btnSeconds.isOn)}
        
        if txtSeconds.isEnabled {
            window?.makeFirstResponder(txtSeconds)
        }
        
        [txtPercentage, percentageStepper].forEach {$0?.enableIf(btnPercentage.isOn)}
        
        if txtPercentage.isEnabled {
            window?.makeFirstResponder(txtPercentage)
        }
    }
    
    @IBAction func hmsStepperAction(_ sender: Any) {
        txtHMS.stringValue = ValueFormatter.formatSecondsToHMS(secondsStepper.doubleValue)
    }
    
    @IBAction func secondsStepperAction(_ sender: Any) {
        txtSeconds.stringValue = String(describing: secondsStepper.doubleValue)
    }
    
    @IBAction func percentageStepperAction(_ sender: Any) {
        txtPercentage.stringValue = String(describing: percentageStepper.doubleValue)
    }
    
    @IBAction func okAction(_ sender: Any) {
        
        var targetTime: TimeInterval = 0
        
        if btnHMS.isOn {
            
            // HH : MM : SS
            targetTime = hmsStepper.doubleValue
            
        } else if btnSeconds.isOn {
            
            // Seconds
            targetTime = secondsStepper.doubleValue
            
        } else {
            
            // Percentage
            // NOTE - secondsStepper.maxValue = track duration
            targetTime = percentageStepper.doubleValue * secondsStepper.maxValue / 100
        }
        
        playbackOrch.seekTo(position: targetTime)
        
        modalDialogResponse = .ok
        theWindow.close()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        theWindow.close()
    }
    
    func trackTransitioned(_ msg: TrackTransitionNotification) {
        
        if msg.playbackStarted, let playingTrack = msg.endTrack {
            resetFields(playingTrack)
            
        } else {
            cancelAction(self)
        }
    }
}
