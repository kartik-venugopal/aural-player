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
    
    case date, replayGain_albumGain, replayGain_albumPeak, replayGain_trackGain, replayGain_trackPeak, end
    
    private static var mappings: [RemType: LibCueREMType] = [
        
        REM_DATE: .date,
        REM_REPLAYGAIN_ALBUM_GAIN: .replayGain_albumGain,
        REM_REPLAYGAIN_ALBUM_PEAK: .replayGain_albumPeak,
        REM_REPLAYGAIN_TRACK_GAIN: .replayGain_trackGain,
        REM_REPLAYGAIN_TRACK_PEAK: .replayGain_trackPeak,
        REM_END: .end
    ]
    
    static func fromREMType(_ remType: RemType) -> LibCueREMType? {
        mappings[remType]
    }
    
    var remType: RemType {
        
        switch self {
            
        case .date:
            return REM_DATE
            
        case .replayGain_albumGain:
            return REM_REPLAYGAIN_ALBUM_GAIN
            
        case .replayGain_albumPeak:
            return REM_REPLAYGAIN_ALBUM_PEAK
            
        case .replayGain_trackGain:
            return REM_REPLAYGAIN_TRACK_GAIN
            
        case .replayGain_trackPeak:
            return REM_REPLAYGAIN_TRACK_PEAK
            
        case .end:
            return REM_END
        }
    }
}

extension RemType: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
