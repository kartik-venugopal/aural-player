/*
    View controller for the Recorder unit
 */

import Cocoa

class RecorderViewController: NSViewController {
    
    @IBOutlet weak var recorderTabViewButton: NSButton!
    
    // Recorder controls
    @IBOutlet weak var btnRecord: NSButton!
    @IBOutlet weak var lblRecorderDuration: NSTextField!
    @IBOutlet weak var lblRecorderFileSize: NSTextField!
    @IBOutlet weak var recordingInfoBox: NSBox!
    
    private let recorder: RecorderDelegateProtocol = AppInitializer.getRecorderDelegate()
    
    // Timer that periodically updates the recording duration (only when recorder is active)
    private var recorderTimer: ScheduledTaskExecutor?
    
    override func viewDidLoad() {
        
        recorderTimer = ScheduledTaskExecutor(intervalMillis: UIConstants.recorderTimerIntervalMillis, task: {self.updateRecordingInfo()}, queue: DispatchQueue.main)
    }
    
    @IBAction func recorderAction(_ sender: Any) {
        
        let isRecording: Bool = recorder.getRecordingInfo() != nil
        
        if (isRecording) {
            stopRecording()
        } else {
            
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
    }
    
    func stopRecording() {
        
        recorder.stopRecording()
        btnRecord.image = UIConstants.imgRecord
        recorderTimer?.pause()
        
        (recorderTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = false
        recorderTabViewButton.needsDisplay = true
        
        saveRecording()
        recordingInfoBox.isHidden = true
    }
    
    func saveRecording() {
        
        let dialog = UIElements.saveRecordingDialog
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSModalResponseOK) {
            recorder.saveRecording(dialog.url!)
        } else {
            recorder.deleteRecording()
        }
    }
    
    func updateRecordingInfo() {
        
        let recInfo = recorder.getRecordingInfo()!
        lblRecorderDuration.stringValue = Utils.formatDuration(recInfo.duration)
        lblRecorderFileSize.stringValue = recInfo.fileSize.toString()
    }
}
