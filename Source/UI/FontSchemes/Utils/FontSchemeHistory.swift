//
//  FontSchemeHistory.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A utility that maintains a chronological record of all changes made to a font scheme (used by the font scheme editor panel), using LIFO stacks.
    Provides undo/redo capabilities.
 */
class FontSchemeHistory: ChangeHistory<FontScheme, FontSchemeChange> {
    
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    
    override func captureSnapshotAsRestorePoint() -> FontScheme {
        fontSchemesManager.systemScheme.clone()
    }
}

/*
    A single historical record of a change made to the system font scheme.
 */
struct FontSchemeChange {
    
    // The font scheme that should be applied if/when an undo is performed.
    let undoValue: FontScheme
    
    // The font scheme that should be applied if/when a redo is performed.
    let redoValue: FontScheme
}
