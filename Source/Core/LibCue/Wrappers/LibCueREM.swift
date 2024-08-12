//
//  LibCueREM.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class LibCueREM {
    
    let type: LibCueREMType
    let value: String
    
    init?(type: LibCueREMType, pointer: OpaquePointer) {

        guard let valuePtr = rem_get(type.remType.rawValue, pointer) else {return nil}
        
        self.type = type
        self.value = String(cString: valuePtr)
    }
}

enum LibCueREMType: CaseIterable {
    
//    REM_DATE,    /* date of cd/track */
//    REM_REPLAYGAIN_ALBUM_GAIN,
//    REM_REPLAYGAIN_ALBUM_PEAK,
//    REM_REPLAYGAIN_TRACK_GAIN,
//    REM_REPLAYGAIN_TRACK_PEAK,
//    REM_END        /* terminating REM (for stepping through REMs) */
    
    case date, end
    
    private static var mappings: [RemType: LibCueREMType] = [
        
        REM_DATE: .date,
        REM_END: .end
    ]
    
    static func fromREMType(_ remType: RemType) -> LibCueREMType? {
        mappings[remType]
    }
    
    var remType: RemType {
        return self == .date ? REM_DATE : REM_END
    }
}

extension RemType: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
