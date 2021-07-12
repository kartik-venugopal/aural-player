//
//  RecorderViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Recorder unit
 */
class RecorderViewController: NSViewController, Destroyable {
    
    // Recorder controls
    @IBOutlet weak var btnRecord: OnOffImageButton!
    @IBOutlet weak var lblRecorderDuration: NSTextField!
    @IBOutlet weak var lblRecorderFileSize: NSTextField!
    @IBOutlet weak var recordingInfoBox: NSBox!
    
    @IBOutlet weak var formatMenu: NSPopUpButton!
    @IBOutlet weak var qualityMenu: NSPopUpButton!
    
    // Labels
    @IBOutlet weak var lblCaption: NSTextField!
    
    private var functionLabels: [NSTextField] = []
    private var functionCaptionLabels: [NSTextField] = []
    private var functionValueLabels: [NSTextField] = []
    
    // Delegate that relays requests to the recorder
    private let recorder: RecorderDelegateProtocol = ObjectGraph.recorderDelegate
    
    // Timer that periodically updates recording info - duration and filesize (only when recorder is active)
    private var recorderTimer: RepeatingTaskExecutor?
    
    // Cached recording info (used to determine recording format when saving a recording)
    private var recordingInfo: RecordingInfo?
    
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    // Recorder timer interval (milliseconds)
    static let timerIntervalMillis: Int = 500
    
    // Default value for the label that shows a track's seek position
    static let zeroDurationString: String = "0:00"
    
    override var nibName: String? {"Recorder"}
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        initControls()
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
        
        // Subscribe to notifications
        messenger.subscribe(to: .application_exitRequest, handler: onAppExit(_:))
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
        messenger.subscribe(to: .changeTextButtonMenuColor, handler: changeTextButtonMenuColor(_:))
        messenger.subscribe(to: .changeMainCaptionTextColor, handler: changeMainCaptionTextColor(_:))
        messenger.subscribe(to: .changeButtonMenuTextColor, handler: changeButtonMenuTextColor(_:))
        
        messenger.subscribe(to: .effects_changeFunctionCaptionTextColor, handler: changeFunctionCaptionTextColor(_:))
        messenger.subscribe(to: .effects_changeFunctionValueTextColor, handler: changeFunctionValueTextColor(_:))
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    private func initControls() {
        
        recorderTimer = RepeatingTaskExecutor(intervalMillis: Self.timerIntervalMillis, task: {[weak self] in self?.updateRecordingInfo()}, queue: .main)
        
        btnRecord.off()
        
        findFunctionLabels(self.view)
        functionValueLabels = [lblRecorderDuration, lblRecorderFileSize]
    }
    
    // Starts/stops recording
    @IBAction func recorderAction(_ sender: Any) {
        recorder.isRecording ? stopRecording() : startRecording()
    }
    
    // Starts a new recording
    private func startRecording() {
        
        formatMenu.disable()
        
        let format = RecordingFormat.formatForDescription(formatMenu.selectedItem!.title)
        let quality = RecordingQuality(rawValue: qualityMenu.selectedItem!.tag)!
        
        recorder.startRecording(RecordingParams(format, quality))
        
        // Start the recording
        btnRecord.on()
        recorderTimer?.startOrResume()
        
        // Update the UI to display current recording information
        lblRecorderDuration.stringValue = Self.zeroDurationString
        lblRecorderFileSize.stringValue = Size.ZERO.toString()
        recordingInfoBox.show()
        
        messenger.publish(.effects_unitStateChanged)
    }
    
    // Stops the current recording
    private func stopRecording() {
        
        formatMenu.enable()
        
        recorder.stopRecording()
        
        btnRecord.off()
        recorderTimer?.pause()
        
        saveRecording(recordingInfo!.format)
        recordingInfoBox.hide()
        
        messenger.publish(.effects_unitStateChanged)
    }
    
    // Prompts the user to save the new recording
    private func saveRecording(_ format: RecordingFormat) {
        
        let dialog = DialogsAndAlerts.saveRecordingDialog(fileExtension: format.fileExtension)
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSApplication.ModalResponse.OK) {
            recorder.saveRecording(dialog.url!)
        } else {
            
            // If user doesn't want to save the recording, discard it (delete the temp file)
            recorder.deleteRecording()
        }
    }
    
    // Updates current recording information
    private func updateRecordingInfo() {
        
        recordingInfo = recorder.recordingInfo
        lblRecorderDuration.stringValue = ValueFormatter.formatSecondsToHMS(recordingInfo!.duration)
        lblRecorderFileSize.stringValue = recordingInfo!.fileSize.toString()
    }
    
    private func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        lblCaption.font = fontSchemesManager.systemScheme.effects.unitCaptionFont
        
        functionLabels.forEach({$0.font = fontSchemesManager.systemScheme.effects.unitFunctionFont})
        
        formatMenu.redraw()
        formatMenu.font = fontSchemesManager.systemScheme.effects.unitFunctionFont
        
        qualityMenu.redraw()
        qualityMenu.font = fontSchemesManager.systemScheme.effects.unitFunctionFont
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        changeMainCaptionTextColor(scheme.general.mainCaptionTextColor)
        changeFunctionCaptionTextColor(scheme.effects.functionCaptionTextColor)
        changeFunctionValueTextColor(scheme.effects.functionValueTextColor)
        changeTextButtonMenuColor(scheme.general.textButtonMenuColor)
    }
    
    func changeMainCaptionTextColor(_ color: NSColor) {
        lblCaption.textColor = color
    }
    
    func changeFunctionCaptionTextColor(_ color: NSColor) {
        functionCaptionLabels.forEach({$0.textColor = color})
    }
    
    func changeFunctionValueTextColor(_ color: NSColor) {
        functionValueLabels.forEach({$0.textColor = color})
    }
    
    func changeTextButtonMenuColor(_ color: NSColor) {
        [formatMenu, qualityMenu].forEach({$0?.redraw()})
    }
    
    func changeButtonMenuTextColor(_ color: NSColor) {
        [formatMenu, qualityMenu].forEach({$0?.redraw()})
    }
    
    private func findFunctionLabels(_ view: NSView) {
        
        for subview in view.subviews {
            
            if let label = subview as? NSTextField, label != lblCaption {
                
                functionLabels.append(label)
                
                if label !== lblRecorderDuration && label !== lblRecorderFileSize {
                    functionCaptionLabels.append(label)
                }
            }
            
            // Recursive call
            findFunctionLabels(subview)
        }
    }
    
    // MARK: Message handling
    
    // This function is invoked when the user attempts to exit the app. It checks if there is an ongoing recording the user may have forgotten about, and prompts the user to save/discard the recording or to cancel the exit.
    private func onAppExit(_ request: AppExitRequestNotification) {
        
        if recorder.isRecording {
            
            // Recording ongoing, prompt the user to save/discard it
            let userResponse = DialogsAndAlerts.saveRecordingAlert.showModal().rawValue
            
            if userResponse == RecordingAlertResponse.saveAndExit.rawValue {
                stopRecording()
                
            } else if userResponse == RecordingAlertResponse.discardAndExit.rawValue {
                recorder.deleteRecording()
            }
            
            request.acceptResponse(okToExit: userResponse != RecordingAlertResponse.dontExit.rawValue)
            
        } else {
            
            request.acceptResponse(okToExit: true)
        }
    }
}

// Enumeration of all possible responses in the save/discard ongoing recording alert (possibly) displayed when exiting the app
enum RecordingAlertResponse: Int {
    
    case saveAndExit = 1000
    case discardAndExit = 1001
    case dontExit = 1002
}
