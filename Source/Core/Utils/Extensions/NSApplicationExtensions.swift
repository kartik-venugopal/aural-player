//
//  NSApplicationExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension NSApplication {
    
    ///
    /// The version number of this application.
    ///
    var appVersion: String {Bundle.main.infoDictionary!["CFBundleShortVersionString", String.self]!}
    
    var modalComponents: [ModalComponentProtocol] {
        windows.compactMap {$0.windowController as? ModalComponentProtocol}
    }
    
    var isShowingModalComponent: Bool {
        
        modalComponents.contains(where: {$0.isModal}) ||
            StringInputPopoverViewController.isShowingAPopover ||
            modalWindow != nil
    }
}
