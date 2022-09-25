//
//  AUControlViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa
import AudioToolbox

class AUControlViewController: NSViewController {
    
    override var nibName: String? {"AUControl"}
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    var paramControlVCs: [AUParameterControlViewController] = []
    
    func generateControlsForAudioUnit(_ audioUnit: HostedAudioUnitDelegateProtocol) {
        
        forceLoadingOfView()
        
        guard let paramTree = audioUnit.parameterTree else {return}
        
        let allParams = paramTree.allParameters
        var totalHeight: CGFloat = 0
        
        for param in allParams.reversed() {
            
            let viewDelegate = AUParameterControlViewDelegate(audioUnit: audioUnit, parameter: param)
            let viewController = AUParameterControlViewController()
            paramControlVCs.append(viewController)
            
            let theView = viewController.view
            viewController.paramControlDelegate = viewDelegate
            scrollView.documentView?.addSubview(theView)
            
            totalHeight += theView.height
        }
        
        scrollView.documentView?.setFrameSize(NSMakeSize(750, totalHeight))
        
        totalHeight = 0
        for vc in paramControlVCs {
            
            let view = vc.view
            view.setFrameOrigin(NSMakePoint(0, totalHeight))
            
            let c1 = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: view.superview!, attribute: .leading, multiplier: 1, constant: 0)
            let c2 = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: view.superview!, attribute: .bottom, multiplier: 1, constant: totalHeight)
            let c3 = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: view.superview!, attribute: .trailing, multiplier: 1, constant: 0)
            let c4 = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.height)
            
            view.superview?.activateAndAddConstraints(c1, c2, c3, c4)
            totalHeight += view.height
        }
        
        scrollView.scrollToTop()
    }
}
