//
//  NSAlertExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSAlert {
    
    // Centers an alert with respect to the screen, and shows it. Returns the modal response from the alert.
    func showModal() -> NSApplication.ModalResponse {
        
        window.showCenteredOnScreen()
        return runModal()
    }
}
