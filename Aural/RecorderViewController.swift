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
    
    private let recorder: RecorderDelegateProtocol = ObjectGraph.getRecorderDelegate()
    
    // Timer that periodically updates the recording duration (only when recorder is active)
    private var recorderTimer: ScheduledTaskExecutor?
    
    override func viewDidLoad() {
        
        recorderTimer = ScheduledTaskExecutor(intervalMillis: UIConstants.recorderTimerIntervalMillis, task: {self.updateRecordingInfo()}, queue: DispatchQueue.main)
        
        SyncMessenger.subscribe(.appExitRequest, subscriber: self)
    }
    
    @IBAction func recorderAction(_ sender: Any) {
        
        if (recorder.getRecordingInfo() != nil) {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        
        // Only AAC format works for now
        recorder.startRecording(RecordingFormat.aac)
        
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
        
        saveRecording()
        recordingInfoBox.isHidden = true
    }
    
    private func saveRecording() {
        
        let dialog = UIElements.saveRecordingDialog
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSModalResponseOK) {
            recorder.saveRecording(dialog.url!)
        } else {
            recorder.deleteRecording()
        }
    }
    
    private func updateRecordingInfo() {
        
        let recInfo = recorder.getRecordingInfo()!
        lblRecorderDuration.stringValue = Utils.formatDuration(recInfo.duration)
        lblRecorderFileSize.stringValue = recInfo.fileSize.toString()
    }
    
    private func onExit() -> AppExitResponse {
        
        if (recorder.isRecording()) {
            
            let alert = UIElements.saveRecordingAlert
            
            // Recording ongoing, prompt the user to save/discard it
            let response = UIUtils.showAlert(alert)
            
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
