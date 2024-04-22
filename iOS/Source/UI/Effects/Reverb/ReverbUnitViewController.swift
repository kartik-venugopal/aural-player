//
//  ReverbUnitViewController.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 24/09/22.
//

import UIKit

class ReverbUnitViewController: UIViewController {
    
    // MARK: UI fields
    
    @IBOutlet weak var btnBypass: UIButton!
    @IBOutlet weak var btnReverbSpace: UIButton!
    @IBOutlet weak var reverbAmountSlider: UISlider!
    @IBOutlet weak var lblReverbAmountValue: UILabel!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var reverbUnit: ReverbUnitDelegateProtocol = audioGraphDelegate.reverbUnit
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        btnReverbSpace.setTitle(reverbUnit.space.description, for: .normal)
        reverbAmountSlider.value = reverbUnit.amount
        
        createSpacesMenu()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func bypassAction(_ sender: UIButton) {
        
        _ = reverbUnit.toggleState()
        btnBypass.tintColor = reverbUnit.isActive ? .blue : .gray
    }

    // Updates the Reverb amount parameter
    @IBAction func reverbAmountAction(_ sender: AnyObject) {
        
        reverbUnit.amount = reverbAmountSlider.value
        lblReverbAmountValue.text = reverbUnit.formattedAmount
    }
    
    private func createSpacesMenu() {
        
        func actionForSpace(_ space: ReverbSpaces) -> UIAction {
            
            UIAction(title: space.description, image: nil) {[weak self] _ in
                
                self?.btnReverbSpace.setTitle(space.description, for: .normal)
                self?.reverbUnit.space = space
                self?.createSpacesMenu()
            }
        }
        
        let menu = UIMenu(title: "Presets", image: nil, identifier: nil, options: .displayInline,
                          children: ReverbSpaces.allCases.map(actionForSpace(_:)))
        
        btnReverbSpace.menu = menu
        btnReverbSpace.showsMenuAsPrimaryAction = true
    }
}
