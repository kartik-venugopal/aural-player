//
//  WaveformView+GestureHandling.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
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
    
    // MARK: ``NSGestureRecognizerDelegate`` functions
    
    ///
    /// Always recognize simultaneously with other recognizers.
    ///
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSGestureRecognizer) -> Bool {true}
    
    // -----------------------------------------------------------------------------------------------
    
    // MARK: Gesture recognizer initialization
    
    // Registers handlers for keyboard events and trackpad/mouse gestures (NSEvent).
    func setUpGestureHandling() {
        
        eventMonitor = EventMonitor()
        eventMonitor.registerHandler(forEventType: .scrollWheel, self.handleScroll(_:))
        eventMonitor.startMonitoring()
        
        // Pinch, pan, and tap gesture recognizers.
        clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.handleClick(_:)))
        clickRecognizer.delegate = self
        addGestureRecognizer(clickRecognizer)
    }
    
    func deactivateGestureHandling() {
        
        eventMonitor?.stopMonitoring()
        eventMonitor = nil
        
        clickRecognizer?.delegate = nil
        
        if let clickRecognizer = self.clickRecognizer {
            removeGestureRecognizer(clickRecognizer)
        }
        
        clickRecognizer = nil
    }
    
    // -----------------------------------------------------------------------------------------------
    
    @objc func handleClick(_ recognizer: NSGestureRecognizer) {
        
        if player.hasPlayingTrack {
            handleSeek(initiatedBy: recognizer)
        }
    }
    
    // Handles a single scroll event
    func handleScroll(_ event: NSEvent) -> NSEvent? {
        
        guard player.hasPlayingTrack else {return event}

        // If a modal dialog is open, don't do anything
        // Also, ignore any gestures that weren't triggered over the main window (they trigger other functions if performed over the playlist window)

        // Calculate the direction and magnitude of the scroll (nil if there is no direction information)
        if event.window === self.window,
           !NSApp.isShowingModalComponent,
           let scrollDirection = event.gestureDirection {
            
            // Vertical scroll = volume control, horizontal scroll = seeking
            if scrollDirection.isHorizontal {
                GestureHandler.handleSeek(event, scrollDirection)
            }
        }

        return event
    }
    
    private func handleSeek(initiatedBy recognizer: NSGestureRecognizer) {
        
        /// The location of the tap within this view.
        let tapLocation = recognizer.location(in: self)
        let percentage: Double = Double(tapLocation.x * 100 / bounds.width)
        self.progress = percentage / 100
        
        playbackOrch.seekTo(percentage: percentage)
    }
}

extension NSNotification.Name {
    
    static let waveformView_progressChanged: NSNotification.Name = .init("waveformView_progressChanged")
}
