import Cocoa

/*
    View controller for the Recorder unit
 */
class RecorderViewController: NSViewController, NotificationSubscriber {
    
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
    
    override var nibName: String? {return "Recorder"}
    
    override func viewDidLoad() {
        
        initControls()
        applyFontScheme(FontSchemes.systemScheme)
        applyColorScheme(ColorSchemes.systemScheme)
        
        // Subscribe to notifications
        Messenger.subscribe(self, .application_exitRequest, self.onAppExit(_:))
        
        Messenger.subscribe(self, .applyFontScheme, self.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeTextButtonMenuColor, self.changeTextButtonMenuColor(_:))
        Messenger.subscribe(self, .changeMainCaptionTextColor, self.changeMainCaptionTextColor(_:))
        Messenger.subscribe(self, .changeButtonMenuTextColor, self.changeButtonMenuTextColor(_:))
        
        Messenger.subscribe(self, .fx_changeFunctionCaptionTextColor, self.changeFunctionCaptionTextColor(_:))
        Messenger.subscribe(self, .fx_changeFunctionValueTextColor, self.changeFunctionValueTextColor(_:))
    }
    
    private func initControls() {
        
        recorderTimer = RepeatingTaskExecutor(intervalMillis: UIConstants.recorderTimerIntervalMillis, task: {self.updateRecordingInfo()}, queue: .main)
        
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
        lblRecorderDuration.stringValue = Strings.zeroDurationString
        lblRecorderFileSize.stringValue = Size.ZERO.toString()
        recordingInfoBox.show()
        
        Messenger.publish(.fx_unitStateChanged)
    }
    
    // Stops the current recording
    private func stopRecording() {
        
        formatMenu.enable()
        
        recorder.stopRecording()
        
        btnRecord.off()
        recorderTimer?.pause()
        
        saveRecording(recordingInfo!.format)
        recordingInfoBox.hide()
        
        Messenger.publish(.fx_unitStateChanged)
    }
    
    // Prompts the user to save the new recording
    private func saveRecording(_ format: RecordingFormat) {
        
        let dialog = DialogsAndAlerts.saveRecordingPanel(format.fileExtension)
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
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        fontsChanged()
    }
    
    private func fontsChanged() {
        
        lblCaption.font = FontSchemes.systemScheme.effects.unitCaptionFont
        
        functionLabels.forEach({$0.font = FontSchemes.systemScheme.effects.unitFunctionFont})
        
        formatMenu.redraw()
        formatMenu.font = FontSchemes.systemScheme.effects.unitFunctionFont
        
        qualityMenu.redraw()
        qualityMenu.font = FontSchemes.systemScheme.effects.unitFunctionFont
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
            let userResponse = UIUtils.showAlert(DialogsAndAlerts.saveRecordingAlert).rawValue
            
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
