/*
    View controller for the Recorder unit
 */

import Cocoa

class RecorderViewController: NSViewController, MessageSubscriber {
    
    @IBOutlet weak var recorderTabViewButton: NSButton!
    
    // Recorder controls
    @IBOutlet weak var btnRecord: NSButton!
    @IBOutlet weak var lblRecorderDuration: NSTextField!
    @IBOutlet weak var lblRecorderFileSize: NSTextField!
    @IBOutlet weak var recordingInfoBox: NSBox!
    
    @IBOutlet weak var formatMenu: NSPopUpButton!
    
    // Delegate that relays requests to the recorder
    private let recorder: RecorderDelegateProtocol = ObjectGraph.getRecorderDelegate()
    
    // Timer that periodically updates recording info - duration and filesize (only when recorder is active)
    private var recorderTimer: RepeatingTaskExecutor?
    
    // Cached recording info (used to determine recording format when saving a recording)
    private var recordingInfo: RecordingInfo?
    
    override func viewDidLoad() {
        
        recorderTimer = RepeatingTaskExecutor(intervalMillis: UIConstants.recorderTimerIntervalMillis, task: {self.updateRecordingInfo()}, queue: DispatchQueue.main)
        
        SyncMessenger.subscribe(.appExitRequest, subscriber: self)
    }
    
    @IBAction func recorderAction(_ sender: Any) {
        
        if (recorder.isRecording()) {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        
        let format = RecordingFormat.formatForDescription((formatMenu.selectedItem?.title)!)
        
        recorder.startRecording(format)
        
        btnRecord.image = UIConstants.imgRecorderStop
        recorderTimer?.startOrResume()
        
        lblRecorderDuration.stringValue = UIConstants.zeroDurationString
        lblRecorderFileSize.stringValue = Size.ZERO.toString()
        recordingInfoBox.isHidden = false
        
        (recorderTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = true
        recorderTabViewButton.needsDisplay = true
    }
    
    private func stopRecording() {
        
        recorder.stopRecording()
        
        btnRecord.image = UIConstants.imgRecord
        recorderTimer?.pause()
        
        (recorderTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = false
        recorderTabViewButton.needsDisplay = true
        
        saveRecording(recordingInfo!.format)
        recordingInfoBox.isHidden = true
    }
    
    private func saveRecording(_ format: RecordingFormat) {
        
        let dialog = UIElements.saveRecordingPanel(format.fileExtension)
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSApplication.ModalResponse.OK) {
            recorder.saveRecording(dialog.url!)
        } else {
            
            // If user doesn't want to save the recording, discard it (delete the temp file)
            recorder.deleteRecording()
        }
    }
    
    private func updateRecordingInfo() {
        
        recordingInfo = recorder.getRecordingInfo()
        lblRecorderDuration.stringValue = StringUtils.formatSecondsToHMS(recordingInfo!.duration)
        lblRecorderFileSize.stringValue = recordingInfo!.fileSize.toString()
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is an ongoing recording the user may have forgotten about, and prompts the user to save/discard the recording or to cancel the exit.
    private func onExit() -> AppExitResponse {
        
        if (recorder.isRecording()) {
            
            // Recording ongoing, prompt the user to save/discard it
            let response = UIUtils.showAlert(UIElements.saveRecordingAlert).rawValue
            
            switch response {
                
            case RecordingAlertResponse.dontExit.rawValue: return AppExitResponse.dontExit
                
            case RecordingAlertResponse.saveAndExit.rawValue: stopRecording()
                                                                return AppExitResponse.okToExit
                
            case RecordingAlertResponse.discardAndExit.rawValue: recorder.deleteRecording()
                                                                return AppExitResponse.okToExit
                
            // Impossible
            default: return AppExitResponse.okToExit
                
            }
        }
        
        // No ongoing recording, proceed with exit
        return AppExitResponse.okToExit
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is AppExitRequest) {
            return onExit()
        }
        
        return EmptyResponse.instance
    }
}
