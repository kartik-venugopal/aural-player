//
//  UnifiedPlayerWaveformContainerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class UnifiedPlayerWaveformContainerViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"UnifiedPlayerWaveformContainer"}
    
    @IBOutlet weak var rootContainer: NSBox!
    
    @IBOutlet weak var waveformContainer: NSView!
    private let viewController: WaveformViewController = .init()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        waveformContainer.addSubview(viewController.view)
        viewController.view.anchorToSuperview()
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainer)
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        Messenger.publish(.View.toggleWaveform)
    }
}

extension UnifiedPlayerWaveformContainerViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        rootContainer.fillColor = systemColorScheme.backgroundColor
    }
}
