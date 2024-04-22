//
//  MasterUnitViewController.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 24/09/22.
//

import UIKit

class MasterUnitViewController: UIViewController {
    
    @IBOutlet weak var btnBypass: UIButton!
    
    @IBOutlet weak var btnEQBypass: UIButton!
    @IBOutlet weak var btnPitchShiftBypass: UIButton!
    @IBOutlet weak var btnTimeStretchBypass: UIButton!
    @IBOutlet weak var btnReverbBypass: UIButton!
    @IBOutlet weak var btnDelayBypass: UIButton!
    @IBOutlet weak var btnFilterBypass: UIButton!
    
    @IBOutlet weak var imgEQBypass: UIImageView!
    @IBOutlet weak var imgPitchShiftBypass: UIImageView!
    @IBOutlet weak var imgTimeStretchBypass: UIImageView!
    @IBOutlet weak var imgReverbBypass: UIImageView!
    @IBOutlet weak var imgDelayBypass: UIImageView!
    @IBOutlet weak var imgFilterBypass: UIImageView!
    
    @IBOutlet weak var lblEQ: UILabel!
    @IBOutlet weak var lblPitchShift: UILabel!
    @IBOutlet weak var lblTimeStretch: UILabel!
    @IBOutlet weak var lblReverb: UILabel!
    @IBOutlet weak var lblDelay: UILabel!
    @IBOutlet weak var lblFilter: UILabel!
    
    // MARK: Services, utilities, helpers, and properties
    
    let graph: AudioGraphDelegateProtocol = audioGraphDelegate
    
    private var masterUnit: MasterUnitDelegateProtocol {graph.masterUnit}
    private var eqUnit: EQUnitDelegateProtocol {graph.eqUnit}
    private var pitchShiftUnit: PitchShiftUnitDelegateProtocol {graph.pitchShiftUnit}
    private var timeStretchUnit: TimeStretchUnitDelegateProtocol {graph.timeStretchUnit}
    private var reverbUnit: ReverbUnitDelegateProtocol {graph.reverbUnit}
    private var delayUnit: DelayUnitDelegateProtocol {graph.delayUnit}
    private var filterUnit: FilterUnitDelegateProtocol {graph.filterUnit}
    
    lazy var messenger = Messenger(for: self)
    
    ///
    /// Sets the state of the controls based on the current state of the FX unit.
    ///
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        btnBypass.tintColor = masterUnit.isActive ? .blue : .gray
        updateEQControls()
        updatePitchShiftControls()
        updateTimeStretchControls()
        
        imgPitchShiftBypass.image = imgPitchShiftBypass.image?.withRenderingMode(.alwaysTemplate)
    }
    
    private func broadcastStateChangeNotification() {
        
        // Update the bypass buttons for the effects units
//        messenger.publish(.effects_unitStateChanged)
    }
    
    private func updateEQControls() {
        
        let tintColor: UIColor = eqUnit.isActive ? .blue : .gray
        btnEQBypass.tintColor = tintColor
        imgEQBypass.tintColor = tintColor
        lblEQ.textColor = tintColor
    }
    
    private func updatePitchShiftControls() {
        
        let tintColor: UIColor = pitchShiftUnit.isActive ? .blue : .gray
        btnPitchShiftBypass.tintColor = tintColor
        imgPitchShiftBypass.tintColor = tintColor
        lblPitchShift.textColor = tintColor
    }
    
    private func updateTimeStretchControls() {
        
        let tintColor: UIColor = timeStretchUnit.isActive ? .blue : .gray
        btnTimeStretchBypass.tintColor = tintColor
        imgTimeStretchBypass.tintColor = tintColor
        lblTimeStretch.textColor = tintColor
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func bypassAction(_ sender: AnyObject) {
        
        _ = masterUnit.toggleState()
        btnBypass.tintColor = masterUnit.isActive ? .blue : .gray
        
        updateEQControls()
        updatePitchShiftControls()
        updateTimeStretchControls()
    }
    
    @IBAction func presetsAction(_ sender: AnyObject) {
        
    }
    
    @IBAction func eqBypassAction(_ sender: AnyObject) {
        
        _ = eqUnit.toggleState()
        updateEQControls()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        _ = pitchShiftUnit.toggleState()
        updatePitchShiftControls()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        _ = timeStretchUnit.toggleState()
        updateTimeStretchControls()
        
        messenger.publish(.effects_playbackRateChanged, payload: timeStretchUnit.effectiveRate)
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        _ = reverbUnit.toggleState()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        _ = delayUnit.toggleState()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        _ = filterUnit.toggleState()
        broadcastStateChangeNotification()
    }
}
