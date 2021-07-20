//
//  InfoPopupProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Contract for displaying info notification popups
protocol InfoPopupProtocol {
    
    // Shows a info message
    func showMessage(_ message: String, _ relativeToView: NSView, _ preferredEdge: NSRectEdge)
}
