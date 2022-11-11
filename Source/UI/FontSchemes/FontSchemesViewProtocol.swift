//
//  FontSchemesViewProtocol.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

/*
    Contract for all subviews that alter the color scheme, to facilitate communication between the window controller and subviews.
 */
protocol FontSchemesViewProtocol {
    
    // The view containing the color editing UI components
    var view: NSView {get}
    
    // Reset all UI controls every time the dialog is shown or a new color scheme is applied.
    // NOTE - the history and clipboard are shared across all views
    func resetFields(_ fontScheme: FontScheme)
    
    // Load values from a font scheme into the UI fields
    func loadFontScheme(_ fontScheme: FontScheme)
    
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme)
}
