//
//  Int+Extensions.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import Foundation

extension Int {
    
    /// The number of bytes occupied by a single ``Float`` in memory.
    static let sizeOfFloat = MemoryLayout<Float>.size
    
    /// The number of bytes occupied by a single ``Int16`` in memory.
    static let sizeOfInt16: Int = MemoryLayout<Int16>.size
}
