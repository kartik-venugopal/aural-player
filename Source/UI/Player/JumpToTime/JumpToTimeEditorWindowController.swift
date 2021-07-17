//
//  JumpToTimeEditorWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class JumpToTimeEditorWindowController: NSWindowController, ModalDialogDelegate, Destroyable {
    
    override var windowNibName: String? {"JumpToTimeEditorDialog"}
    
    @IBOutlet weak var lblTrackName: NSTextField!
    @IBOutlet weak var lblTrackDuration: NSTextField!
    
    @IBOutlet weak var btnHMS: DialogCheckRadioButton!
    @IBOutlet weak var btnSeconds: DialogCheckRadioButton!
    @IBOutlet weak var btnPercentage: DialogCheckRadioButton!
    
    @IBOutlet weak var timePicker: IntervalPicker!
    
    @IBOutlet weak var secondsFormatter: TimeIntervalFormatter!
    
    @IBOutlet weak var percentageFormatter: TimeIntervalFormatter!
    
    @IBOutlet weak var txtSeconds: NSTextField!
    @IBOutlet weak var secondsStepper: NSStepper!
    
    @IBOutlet weak var txtPercentage: NSTextField!
    @IBOutlet weak var percentageStepper: NSStepper!
    
    private let playbackInfo: PlaybackInfoDelegateProtocol = objectGraph.playbackInfoDelegate
    
    private lazy var messenger = Messenger(for: self)
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override func windowDidLoad() {
        
        secondsFormatter.valueFunction = {[weak self]
            () -> String in
            
            return String(describing: self?.secondsStepper.doubleValue ?? 0)
        }
        
        secondsFormatter.updateFunction = {[weak self]
            (_ value: Double) in
            
            self?.secondsStepper.doubleValue = value
        }
        
        percentageFormatter.valueFunction = {[weak self]
            () -> String in
            
            return String(describing: self?.percentageStepper.doubleValue ?? 0)
        }
        
        percentageFormatter.updateFunction = {[weak self]
            (_ value: Double) in
            
            self?.percentageStepper.doubleValue = value
        }
        
        percentageFormatter.maxValue = 100
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:),
                                 filter: {[weak self] msg in self?.window?.isVisible ?? false})
        
        WindowManager.instance.registerModalComponent(self)
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = theWindow
        }
        
        guard let playingTrack = playbackInfo.playingTrack else {
            
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
        btnHMS.titleUpdated()
        
        btnSeconds.title = String(format: "Specify as seconds (0 to %d)", durationInt)
        btnSeconds.titleUpdated()
        
        // Reset to 00:00:00
        timePicker.maxInterval = roundedDuration
        timePicker.reset()
        
        secondsFormatter.maxValue = roundedDuration
        secondsStepper.maxValue = roundedDuration
        secondsStepper.doubleValue = 0
        secondsStepperAction(self)
        
        percentageStepper.doubleValue = 0
        percentageStepperAction(self)
    }
    
    @IBAction func radioButtonAction(_ sender: Any) {
        
        timePicker.enableIf(btnHMS.isOn)
        [txtSeconds, secondsStepper].forEach({$0?.enableIf(btnSeconds.isOn)})
        
        if txtSeconds.isEnabled {
            self.window?.makeFirstResponder(txtSeconds)
        }
        
        [txtPercentage, percentageStepper].forEach({$0?.enableIf(btnPercentage.isOn)})
        
        if txtPercentage.isEnabled {
            self.window?.makeFirstResponder(txtPercentage)
        }
    }
    
    @IBAction func secondsStepperAction(_ sender: Any) {
        txtSeconds.stringValue = String(describing: secondsStepper.doubleValue)
    }
    
    @IBAction func percentageStepperAction(_ sender: Any) {
        txtPercentage.stringValue = String(describing: percentageStepper.doubleValue)
    }
    
    @IBAction func okAction(_ sender: Any) {
        
        var jumpToTime: Double = 0
        
        if btnHMS.isOn {
            
            // HH : MM : SS
            jumpToTime = timePicker.interval
            
        } else if btnSeconds.isOn {
            
            // Seconds
            jumpToTime = secondsStepper.doubleValue
            
        } else {
            
            // Percentage
            // NOTE - secondsStepper.maxValue = track duration
            jumpToTime = percentageStepper.doubleValue * secondsStepper.maxValue / 100
        }
        
        messenger.publish(.player_jumpToTime, payload: jumpToTime)
        
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
