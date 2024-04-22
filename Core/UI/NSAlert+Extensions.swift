//
//  NSAlert+Extensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

#if os(macOS)

import Cocoa

///
/// Shared constants and convenience functions for ``NSAlert``.
///
extension NSAlert {
    
    private static let shared: NSAlert = NSAlert()
    
    // MARK: Functions
    
    ///
    /// Shows an informational / error alert, with the given title and informational text.
    ///
    static func showError(withTitle title: String, andText text: String) {
        
        shared.messageText = title
        shared.informativeText = text
        
        shared.alertStyle = .critical
        shared.icon = .imgError
        
        _ = shared.runModal()
    }
    
    ///
    /// Shows an informational / error alert, with the given title and informational text,  and returns
    /// a response depending on which alert button was clicked.
    ///
    func showAndGetResponse(withTitle title: String, andText text: String) -> NSApplication.ModalResponse {
        
        messageText = title
        informativeText = text
        
        return runModal()
    }
}

#endif
