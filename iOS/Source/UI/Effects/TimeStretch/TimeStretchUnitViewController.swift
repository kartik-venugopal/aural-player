//
//  TimeStretchUnitViewController.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 24/09/22.
//

import UIKit

class TimeStretchUnitViewController: UIViewController {
    
    @IBOutlet weak var btnBypass: UIButton!
    
    @IBOutlet weak var rateSlider: TimeStretchSlider!
    @IBOutlet weak var lblRate: UILabel!
    
    @IBOutlet weak var pitchShiftSwitch: UISwitch!
 
    // MARK: Services, utilities, helpers, and properties

    var timeStretchUnit: TimeStretchUnitDelegateProtocol = audioGraphDelegate.timeStretchUnit
    
    ///
    /// Sets the state of the controls based on the current state of the FX unit.
    ///
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationItem.title = "Time Stretch Settings"
        
        btnBypass.tintColor = timeStretchUnit.isActive ? .blue : .gray
        rateSlider.rate = timeStretchUnit.rate
        lblRate.text = timeStretchUnit.formattedRate
        pitchShiftSwitch.setOn(timeStretchUnit.shiftPitch, animated: true)
    }

    // ------------------------------------------------------------------------

    // MARK: Actions

    // Activates/deactivates the Time stretch effects unit
    @IBAction func bypassAction(_ sender: UIButton) {
        
        _ = timeStretchUnit.toggleState()
        btnBypass.tintColor = timeStretchUnit.isActive ? .blue : .gray
    }

    // Updates the playback rate value
    @IBAction func timeStretchAction(_ sender: TimeStretchSlider) {
        
        timeStretchUnit.rate = rateSlider.rate
        lblRate.text = timeStretchUnit.formattedRate
    }

    private static let oneTenth: Float = 1.0 / 10.0
    private static let oneHundredth: Float = 1.0 / 100.0

    @IBAction func increaseRateByTenthAction(_ sender: UIButton) {
        
        _ = timeStretchUnit.increaseRate(by: Self.oneTenth)
        rateSlider.rate = timeStretchUnit.rate
        lblRate.text = timeStretchUnit.formattedRate
    }

    @IBAction func increaseRateByHundredthAction(_ sender: UIButton) {
        
        _ = timeStretchUnit.increaseRate(by: Self.oneHundredth)
        rateSlider.rate = timeStretchUnit.rate
        lblRate.text = timeStretchUnit.formattedRate
    }

    @IBAction func decreaseRateByTenthAction(_ sender: UIButton) {
        
        _ = timeStretchUnit.decreaseRate(by: Self.oneTenth)
        rateSlider.rate = timeStretchUnit.rate
        lblRate.text = timeStretchUnit.formattedRate
    }

    @IBAction func decreaseRateByHundredthAction(_ sender: UIButton) {
        
        _ = timeStretchUnit.decreaseRate(by: Self.oneHundredth)
        rateSlider.rate = timeStretchUnit.rate
        lblRate.text = timeStretchUnit.formattedRate
    }

    // Toggles the "Shift pitch" option of the Time stretch effects unit
    @IBAction func shiftPitchAction(_ sender: UISwitch) {
        timeStretchUnit.shiftPitch.toggle()
    }
}

class TimeStretchSlider: UISlider {
    
    private let minRate: Float = 0.25
    
    /// Logarithmic scale.
    var rate: Float {
        
        get {
            minRate * powf(2, value)
        }
        
        set(newRate) {
            value = log2(newRate / minRate)
        }
    }
}
