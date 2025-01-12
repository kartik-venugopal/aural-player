//
//  ColorSchemesViewProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

/*
    Contract for all subviews that alter the color scheme, to facilitate communication between the window controller and subviews.
 */
protocol ColorSchemesViewProtocol {
    
    // The view containing the color editing UI components
    var view: NSView {get}
    
    // Reset all UI controls every time the dialog is shown or a new color scheme is applied.
    // NOTE - the history and clipboard are shared across all views
    func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard)
    
    // If the last change was made to a control in this view, performs an undo operation and returns true. Otherwise, does nothing and returns false.
    func undoChange(_ lastChange: ColorSchemeChange) -> Bool

    // If the last undo was performed on a control in this view, performs a redo operation and returns true. Otherwise, does nothing and returns false.
    func redoChange(_ lastChange: ColorSchemeChange) -> Bool
}
