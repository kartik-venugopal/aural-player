//
//  AUControlViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa
import AudioToolbox

class AUControlViewController: NSViewController {
    
    override var nibName: String? {"AUControl"}
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var containerView: NSView!
    
    private var paramControlVCs: [AUParameterControlViewController] = []
    
    private static let auParamControlViewWidth: CGFloat = 750
    private var totalHeight: CGFloat = 0
    
    var audioUnit: HostedAudioUnitDelegateProtocol! {
        
        didSet {
            generateControlsForAudioUnit()
        }
    }
    
    private func generateControlsForAudioUnit() {
        
        forceLoadingOfView()
        
        guard let paramTree = audioUnit.parameterTree,
        let containerView = scrollView.documentView else {return}
        
        traverseParameterGroup(paramTree)
        
        if totalHeight > containerView.height {
            containerView.setFrameSize(NSMakeSize(Self.auParamControlViewWidth, totalHeight))
        }
        
        let h1 = NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: containerView.height)
        containerView.superview?.activateAndAddConstraint(h1)
        
        var heightSoFar: CGFloat = 0
        var viewAbove: NSView? = nil
        for view in containerView.subviews {
            
            view.setFrameOrigin(NSMakePoint(0, containerView.height - heightSoFar - view.height))
            
            let c1 = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1, constant: 0)
            let c2 = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1, constant: 0)
            
            containerView.activateAndAddConstraints(c1, c2)
            
            if let theViewAbove = viewAbove {
                
                let c3 = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: theViewAbove, attribute: .bottom, multiplier: 1, constant: 0)
                containerView.activateAndAddConstraint(c3)
                
            } else {
                
                let c3 = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0)
                containerView.activateAndAddConstraint(c3)
            }
            
            heightSoFar += view.height
            viewAbove = view
        }
        
        scrollView.scrollToTop()
    }
    
    private func traverseParameterGroup(_ group: AUParameterGroup) {
        
        let children = group.children
        
        if children.contains(where: {$0 is AUParameter}) {
            
            let label = BottomTextLabel(frame: NSMakeRect(0, 0, Self.auParamControlViewWidth, 28))
            label.isEditable = false
            label.stringValue = "    " + group.displayName.capitalizingFirstLetter()
            label.textColor = .white50Percent
            label.font = .auxCaptionFont
            label.forceAlignment()
            
            label.drawsBackground = true
            label.backgroundColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(label)
            totalHeight += label.height
        }
        
        for child in group.children {
            
            if let param = child as? AUParameter {
                
                let viewDelegate = AUParameterControlViewDelegate(audioUnit: audioUnit, parameter: param)
                let viewController = AUParameterControlViewController()
                paramControlVCs.append(viewController)
                
                let theView = viewController.view
                viewController.paramControlDelegate = viewDelegate
                containerView.addSubview(theView)
                
                totalHeight += theView.height
                
            } else if let subGroup = child as? AUParameterGroup {
                traverseParameterGroup(subGroup)
            }
        }
    }
    
    func refreshControls() {
        paramControlVCs.forEach {$0.refreshControls()}
    }
}
