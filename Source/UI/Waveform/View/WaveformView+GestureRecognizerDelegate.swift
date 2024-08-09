//
//  WaveformView+GestureRecognizerDelegate.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import AppKit
import CoreGraphics
import Cocoa

///
/// Part of ``WaveformView`` that handles touch gestures.
///
extension WaveformView: NSGestureRecognizerDelegate {
    
    // MARK: State / constants
    
    // -----------------------------------------------------------------------------------------------
    
    // MARK: ``PlatformGestureRecognizerDelegate`` functions
    
    ///
    /// Always recognize simultaneously with other recognizers.
    ///
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSGestureRecognizer) -> Bool {true}
    
    // -----------------------------------------------------------------------------------------------
    
    // MARK: Gesture recognizer initialization
    
    ///
    /// Initializes and adds all the required gesture recognizers for the view.
    ///
    func addGestureRecognizers() {
        
        // Pinch, pan, and tap gesture recognizers.
        clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.handleClick(_:)))
        clickRecognizer.delegate = self
        addGestureRecognizer(clickRecognizer)
    }
    
    // -----------------------------------------------------------------------------------------------
    
    // MARK: Gesture handling functions
    
    ///
    /// Handles a single pan gesture.
    ///
    @objc func handlePanGesture(_ recognizer: NSPanGestureRecognizer) {
        
        handleSeek(initiatedBy: recognizer)
    }
    
    @objc func handleClick(_ recognizer: NSGestureRecognizer) {
        handleSeek(initiatedBy: recognizer)
    }
    
    private func handleSeek(initiatedBy recognizer: NSGestureRecognizer) {
        
        /// The location of the tap within this view.
        let tapLocation = recognizer.location(in: self)
        let percentage: Double = Double(tapLocation.x * 100 / bounds.width)
        self.progress = percentage / 100
        
        // Broadcast a notification informing observers of the progress change.
        Messenger.publish(.Player.seekToPercentage, payload: percentage)
    }
}

extension NSNotification.Name {
    
    static let waveformView_progressChanged: NSNotification.Name = .init("waveformView_progressChanged")
}
