//
//  VisualizerWC.swift
//  Aural
//
//  Created by Wald Schlafer on 10/21/18.
//  Copyright © 2018 Anonymous. All rights reserved.
//
//
//import Cocoa
//
//class VisualizerWC: NSWindowController {
//
//    @IBOutlet weak var sp: Spectrogram!
//
//    override var windowNibName: String? {return "Visualizer"}
//}
//
//// MARK - Experimental code not in use ------------------------------------------------------------
//
//func startViz(_ sp: Spectrogram, _ fft: FFT) {
//
//    graph.nodeForRecorderTap.installTap(onBus: 0, bufferSize: 1024, format: nil, block: { buffer, when in
//
//        //            buffer.frameLength = 512
//
//        let data = fft.fft1(buffer)
//        sp.updateWithData(data)
//    })
//}
