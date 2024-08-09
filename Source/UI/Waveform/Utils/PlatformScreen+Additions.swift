//
//  PlatformScreen+Additions.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import Cocoa

extension NSScreen {
 
    /// Scale factor for the main screen.
    static var screenScale: CGFloat {
        main!.backingScaleFactor
    }
}
