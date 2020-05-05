import Cocoa

/*
    View controller for the Recorder unit
 */
class RecorderViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber {
    
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
        applyColorScheme(ColorSchemes.systemScheme)
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.appExitRequest], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.changeEffectsTextSize, .applyColorScheme, .changeTextButtonMenuColor, .changeButtonMenuTextColor, .changeMainCaptionTextColor, .changeEffectsFunctionCaptionTextColor, .changeEffectsFunctionValueTextColor], subscriber: self)
    }
    
    private func initControls() {
        
        recorderTimer = RepeatingTaskExecutor(intervalMillis: UIConstants.recorderTimerIntervalMillis, task: {self.updateRecordingInfo()}, queue: DispatchQueue.main)
        
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
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
    }
    
    // Stops the current recording
    private func stopRecording() {
        
        formatMenu.enable()
        
        recorder.stopRecording()
        
        btnRecord.off()
        recorderTimer?.pause()
        
        saveRecording(recordingInfo!.format)
        recordingInfoBox.hide()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
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
        lblRecorderDuration.stringValue = StringUtils.formatSecondsToHMS(recordingInfo!.duration)
        lblRecorderFileSize.stringValue = recordingInfo!.fileSize.toString()
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is an ongoing recording the user may have forgotten about, and prompts the user to save/discard the recording or to cancel the exit.
    private func onExit() -> AppExitResponse {
        
        if recorder.isRecording {
            
            // Recording ongoing, prompt the user to save/discard it
            let response = UIUtils.showAlert(DialogsAndAlerts.saveRecordingAlert).rawValue
            
            switch response {
                
            case RecordingAlertResponse.dontExit.rawValue:
                
                return AppExitResponse.dontExit
                
            case RecordingAlertResponse.saveAndExit.rawValue:
                
                stopRecording()
                return AppExitResponse.okToExit
                
            case RecordingAlertResponse.discardAndExit.rawValue:
                
                recorder.deleteRecording()
                return AppExitResponse.okToExit
                
            // Impossible
            default:
                
                return AppExitResponse.okToExit
            }
        }
        
        // No ongoing recording, proceed with exit
        return AppExitResponse.okToExit
    }
    
    private func changeTextSize() {
        
        lblCaption.font = Fonts.Effects.unitCaptionFont
        
        functionLabels.forEach({$0.font = Fonts.Effects.unitFunctionFont})
        
        formatMenu.redraw()
        formatMenu.font = Fonts.Effects.unitFunctionFont
        
        qualityMenu.redraw()
        qualityMenu.font = Fonts.Effects.unitFunctionFont
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        changeMainCaptionTextColor(scheme.general.mainCaptionTextColor)
        changeFunctionCaptionTextColor(scheme.effects.functionCaptionTextColor)
        changeFunctionValueTextColor(scheme.effects.functionValueTextColor)
        changeTextButtonMenuColor()
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
    
    func changeTextButtonMenuColor() {
        [formatMenu, qualityMenu].forEach({$0?.redraw()})
    }
    
    func changeButtonMenuTextColor() {
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
    
    var subscriberId: String {
        return self.className
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is AppExitRequest) {
            return onExit()
        }
        
        return EmptyResponse.instance
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if message.actionType == .changeEffectsTextSize {
            
            changeTextSize()
            return
        }
        
        if let colorSchemeMsg = message as? ColorSchemeActionMessage {
            
            applyColorScheme(colorSchemeMsg.scheme)
            return
        }
        
        if let colorSchemeMsg = message as? ColorSchemeComponentActionMessage {
            
            switch colorSchemeMsg.actionType {
                
            case .changeMainCaptionTextColor:
                
                changeMainCaptionTextColor(colorSchemeMsg.color)
                
            case .changeEffectsFunctionCaptionTextColor:
                
                changeFunctionCaptionTextColor(colorSchemeMsg.color)
                
            case .changeEffectsFunctionValueTextColor:
                
                changeFunctionValueTextColor(colorSchemeMsg.color)
                
            case .changeTextButtonMenuColor:
                
                changeTextButtonMenuColor()
                
            case .changeButtonMenuTextColor:
                
                changeButtonMenuTextColor()
                
            default: return
                
            }
        }
    }
}
