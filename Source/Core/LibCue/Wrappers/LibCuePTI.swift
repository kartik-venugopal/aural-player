//
//  LibCuePTI.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

enum LibCuePTI: CaseIterable {
    
    case title,    /* title of album or track titles */
    performer,    /* name(s) of the performer(s) */
    songwriter,    /* name(s) of the songwriter(s) */
    composer,    /* name(s) of the composer(s) */
    arranger,    /* name(s) of the arranger(s) */
    message,    /* message(s) from the content provider and/or artist */
    discID,    /* (binary) disc identification information */
    genre,    /* (binary) genre identification and genre information */
    UPC_ISRC    /* UPC/EAN code of the album and ISRC code of each track */
    
    private static let mappings: [Pti: LibCuePTI] = [
        
        PTI_TITLE: .title,
        PTI_PERFORMER: .performer,
        PTI_SONGWRITER: .songwriter,
        PTI_COMPOSER: .composer,
        PTI_ARRANGER: .arranger,
        PTI_MESSAGE: .message,
        PTI_DISC_ID: .discID,
        PTI_GENRE: .genre,
        PTI_UPC_ISRC: .UPC_ISRC
    ]
    
    private static let reverseMappings: [LibCuePTI: Pti] = [
        
        .title: PTI_TITLE,
        .performer: PTI_PERFORMER,
        .songwriter: PTI_SONGWRITER,
        .composer: PTI_COMPOSER,
        .arranger: PTI_ARRANGER,
        .message: PTI_MESSAGE,
        .discID: PTI_DISC_ID,
        .genre: PTI_GENRE,
        .UPC_ISRC: PTI_UPC_ISRC
    ]
    
    private static func computeKey(forPTI pti: Pti, isTrack: Bool) -> String? {
        
        if let keyPtr = cdtext_get_key(Int32(pti.rawValue), isTrack ? 1 : 0) {
            return String(cString: keyPtr)
        }
        
        return nil
    }
    
    private static let keysForTracks: [LibCuePTI: String] = {
        
        var keys: [LibCuePTI: String] = [:]
        
        for pti in allCases {
            keys[pti] = computeKey(forPTI: pti.pti, isTrack: true)
        }
        
        return keys
    }()
    
    private static let keysForCDs: [LibCuePTI: String] = {
        
        var keys: [LibCuePTI: String] = [:]
        
        for pti in allCases {
            keys[pti] = computeKey(forPTI: pti.pti, isTrack: false)
        }
        
        return keys
    }()
    
    static func fromPTI(_ pti: Pti) -> LibCuePTI? {
        mappings[pti]
    }
    
    var pti: Pti {
        Self.reverseMappings[self]!
    }
    
    func key(isTrack: Bool) -> String? {
        isTrack ? Self.keysForTracks[self] : Self.keysForCDs[self]
    }
}

extension Pti: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
