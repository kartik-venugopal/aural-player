//
//  LibCueCDText.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class LibCueCDText {
    
    let pointer: OpaquePointer
    let pti: LibCuePTI
    
    let key: String
    let value: String
    
    init?(pointer: OpaquePointer, pti: LibCuePTI, isTrack: Bool) {
        
        self.pointer = pointer
        self.pti = pti
        
        guard let key = pti.key(isTrack: isTrack) else {return nil}
        self.key = key
        
        guard let valuePtr = cdtext_get(pti.pti, pointer) else {return nil}
        
        self.value = String(cString: valuePtr)
    }
}
