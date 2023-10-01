//
//  ColorSchemeHistory.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A utility that maintains a chronological record of all changes made to a color
    scheme (used by the color scheme editor panel), using LIFO stacks.
    Provides undo/redo capabilities.
 */
class ColorSchemeHistory: ChangeHistory<ColorScheme, ColorSchemeChange> {
    
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    override func captureSnapshotAsRestorePoint() -> ColorScheme {
        colorSchemesManager.systemScheme.clone()
    }
}

/*
    A single historical record of a change made to the system color scheme.
 */
struct ColorSchemeChange {
    
    // The tag of the control whose value was changed
    let tag: Int
    
    // The value that should be assigned to the changed control if/when an undo is performed on this field.
    let undoValue: Any
    
    // The value that should be assigned to the changed control if/when a redo is performed on this field.
    let redoValue: Any
    
    // The type of change that this record represents (i.e. a color change or a gradient amount change).
    let changeType: ColorSchemeChangeType
}

// Enumeration of all possible color scheme changes that can be recorded in history.
enum ColorSchemeChangeType {
    
    case
    
    /*
        A single color scheme element has changed (eg. window background color).
     */
    changeColor,
    
    /*
        The gradient for a single color scheme element has changed (eg. seek slider foreground).
     */
    changeGradient,
    
    /*
        An entire color scheme has been applied to the system color scheme.
     */
    applyScheme,
    
    /*
        A boolean field has been toggled (eg. enable/disable slider foreground gradient)
     */
    toggle,
    
    /*
        An Int value field has been changed. (eg. gradient amount)
     */
    setIntValue
}

// An action that is performed as part of an undo/redo operation.
typealias ColorChangeAction = () -> Void
