import Cocoa

class TranscodingPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    // Transcoding preferences
    
    @IBOutlet weak var btnSaveFiles: NSButton!
    @IBOutlet weak var btnDeleteFiles: NSButton!
    
    @IBOutlet weak var btnLimitSpace: NSButton!
    @IBOutlet weak var maxSpaceSlider: NSSlider!
    @IBOutlet weak var lblMaxSpace: NSTextField!
    @IBOutlet weak var lblCurrentUsage: NSTextField!
    
    @IBOutlet weak var btnEagerTranscoding: NSButton!
    @IBOutlet weak var btnPredictive: NSButton!
    @IBOutlet weak var btnAllFiles: NSButton!
    
    @IBOutlet weak var lblMaxTasks: NSTextField!
    @IBOutlet weak var maxTasksStepper: NSStepper!
    
    private let transcoder: TranscoderProtocol = ObjectGraph.transcoder
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let prefs = preferences.playbackPreferences.transcodingPreferences
        
        // Persistence
        
        if prefs.persistenceOption == .save {
            btnSaveFiles.on()
        } else {
            btnDeleteFiles.on()
        }
        transcoderPersistenceRadioButtonAction(self)
        
        btnLimitSpace.onIf(prefs.limitDiskSpaceUsage)
        limitSpaceAction(self)
        
        let currentUsageMB: Double = Double(transcoder.currentDiskSpaceUsage) / (1000.0 * 1000)
        lblCurrentUsage.stringValue = formatSizeMB(currentUsageMB)
        let percUsed: Double = currentUsageMB * 100 / Double(prefs.maxDiskSpaceUsage)
        
        if percUsed < 75 {
            lblCurrentUsage.textColor = NSColor.green
        } else if percUsed < 90 {
            lblCurrentUsage.textColor = NSColor.orange
        } else {
            lblCurrentUsage.textColor = NSColor.red
        }
        
        maxSpaceSlider.doubleValue = log10(Double(prefs.maxDiskSpaceUsage)) - log10(100)
        maxSpaceSliderAction(self)
        
        // Eager transcoding
        
        btnEagerTranscoding.onIf(prefs.eagerTranscodingEnabled)
        eagerTranscodingAction(self)
        
        if prefs.eagerTranscodingOption == .allFiles {
            btnAllFiles.on()
        } else {
            btnPredictive.on()
        }
        
        // Max background tasks
    }
    
    @IBAction func transcoderPersistenceRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func limitSpaceAction(_ sender: Any) {
        maxSpaceSlider.enableIf(btnLimitSpace.isOn())
    }
    
    @IBAction func maxSpaceSliderAction(_ sender: Any) {
        lblMaxSpace.stringValue = formatSizeMB(round(100 * pow(10, maxSpaceSlider.doubleValue)))
    }
    
    private func formatSizeMB(_ size: Double) -> String {
        
        var amount: Double = size
        var unit = "MB"
        
        if amount >= 1000 && amount < 1000 * 1000 {
            
            // GB
            unit = "GB"
            amount = amount / 1000.0
            
        } else if amount >= 1000 * 1000 {
            
            // TB
            unit = "TB"
            amount = amount / (1000.0 * 1000.0)
        }
        
        let isWholeNumber = amount == round(amount)
        return isWholeNumber ? String(format: "%d  %@", Int(amount), unit) : (unit == "MB" ? String(format: "%d  %@", UInt(round(amount)), unit) : String(format: "%.2lf  %@", amount, unit))
    }
    
    @IBAction func eagerTranscodingAction(_ sender: Any) {
        [btnPredictive, btnAllFiles].forEach({$0?.enableIf(btnEagerTranscoding.isOn())})
    }
    
    @IBAction func eagerTranscodingOptionAction(_ sender: Any) {
        // Needed for radio buttons
    }
    
    func save(_ preferences: Preferences) throws {
        
        let prefs = preferences.playbackPreferences.transcodingPreferences
        
        prefs.persistenceOption = btnSaveFiles.isOn() ? .save : .delete
        prefs.limitDiskSpaceUsage = btnLimitSpace.isOn()
        
        let amount: Double = 100 * pow(10, maxSpaceSlider.doubleValue)
        prefs.maxDiskSpaceUsage = Int(round(amount))
        
        prefs.eagerTranscodingEnabled = btnEagerTranscoding.isOn()
        prefs.eagerTranscodingOption = btnAllFiles.isOn() ? .allFiles : .predictive
        
        
        
        // Max usage prefs may have changed, so perform a check if user has opted to limit disk space usage
        if prefs.limitDiskSpaceUsage {
            transcoder.checkDiskSpaceUsage()
        }
    }
}

fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
