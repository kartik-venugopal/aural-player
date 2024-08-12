//
//  LibCueTrack.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

fileprivate let framesInASecond: Double = 75

class LibCueTrack {
    
    let pointer: OpaquePointer
    
    let fileName: String
    
    let start: Double?
    let length: Double?
    let preGap: Double?
    let postGap: Double?
    
    let rems: [LibCueREM]
    lazy var date: String? = rems.first(where: {$0.type == .date})?.value
    
    let cdTexts: [LibCueCDText]
    lazy var title: String? = cdTexts.first(where: {$0.pti == .title})?.value
    lazy var performer: String? = cdTexts.first(where: {$0.pti == .performer})?.value
    lazy var genre: String? = cdTexts.first(where: {$0.pti == .genre})?.value
    lazy var composer: String? = cdTexts.first(where: {$0.pti == .composer})?.value
    
    lazy var songwriter: String? = cdTexts.first(where: {$0.pti == .songwriter})?.value
    lazy var arranger: String? = cdTexts.first(where: {$0.pti == .arranger})?.value
    lazy var message: String? = cdTexts.first(where: {$0.pti == .message})?.value
    
    let ISRC: String?
    
    init?(pointer: OpaquePointer) {
        
        func framesToSeconds(_ frames: Int) -> Double {
            Double(frames) / framesInASecond
        }
        
        self.pointer = pointer
        
        guard let fileNamePtr = track_get_filename(pointer) else {return nil}
        
        self.fileName = String(cString: fileNamePtr)
        
        let start = track_get_start(pointer)
        self.start = start < 0 ? nil : framesToSeconds(start)
        
        let length = track_get_length(pointer)
        self.length = length < 0 ? nil : framesToSeconds(length)
        
        let preGap = track_get_zero_pre(pointer)
        self.preGap = preGap < 0 ? nil : framesToSeconds(preGap)
        
        let postGap = track_get_zero_post(pointer)
        self.postGap = postGap < 0 ? nil : framesToSeconds(postGap)
        
        if let isrcPtr = track_get_isrc(pointer) {
            self.ISRC = String(cString: isrcPtr)
        } else {
            self.ISRC = nil
        }
        
        if let cdTextPtr = track_get_cdtext(pointer) {
            
            self.cdTexts = LibCuePTI.allCases.compactMap {pti in
                LibCueCDText(pointer: cdTextPtr, pti: pti, isTrack: true)
            }
            
        } else {
            self.cdTexts = []
        }
        
        if let remPtr = track_get_rem(pointer) {
            
            self.rems = LibCueREMType.allCases.compactMap {remType in
                LibCueREM(type: remType, pointer: remPtr)
            }
            
        } else {
            self.rems = []
        }
    }
}
