//
//  FFmpegString.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class FFmpegString {
    
    let size: Int
    lazy var int32Size: Int32 = Int32(size)
    
    lazy var pointer: UnsafeMutablePointer<Int8> = .allocate(capacity: size)
    lazy var string: String = String(cString: pointer)
    
    init(size: Int) {
        self.size = size
    }
    
    deinit {
        pointer.deallocate()
    }
}
