//
//  VisualizerWC.swift
//  Aural
//
//  Created by Wald Schlafer on 10/21/18.
//  Copyright © 2018 Anonymous. All rights reserved.
//

import Cocoa

class VisualizerWC: NSWindowController {
    
    @IBOutlet weak var sp: Spectrogram!
    
    override var windowNibName: String? {return "Visualizer"}
}
