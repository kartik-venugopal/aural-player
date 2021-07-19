//
//  FontConstants.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

let auxiliaryFontName: String = "Play Regular"

let standardFontName: String = "Exo-Medium"
let standardCaptionFontName: String = "AlegreyaSansSC-Regular"

let roundedFontName: String = "FuturaBT-Light"
let roundedCaptionFontName: String = "RoundorNonCommercialRegular"

let programmerFontName: String = "Monaco"
let programmerCaptionFontName: String = "CarroisGothicSC-Regular"

let novelistFontName: String = "ComingSoon"
let novelistCaptionFontName: String = "WalterTurncoat"

let soySauceFontName: String = "RagingRedLotusBB"
let soySauceCaptionFontName: String = "Shufen"

let futuristicFontName: String = "ControlFreak"
let futuristicCaptionFontName: String = "neo-latina"

let gothicFontName: String = "Metamorphous"
let gothicCaptionFontName: String = "AlmendraSC-Regular"

let papyrusFontName: String = "Papyrus"
let papyrusCaptionFontName: String = "Aniron"

let poolsideFMFontName: String = "ChicagoFLF"

let standardFontSet: FontSet = FontSet(mainFontName: standardFontName, captionFontName: standardCaptionFontName)
let roundedFontSet: FontSet = FontSet(mainFontName: roundedFontName, captionFontName: roundedCaptionFontName)
let programmerFontSet: FontSet = FontSet(mainFontName: programmerFontName, captionFontName: programmerCaptionFontName)
let novelistFontSet: FontSet = FontSet(mainFontName: novelistFontName, captionFontName: novelistCaptionFontName)
let soySauceFontSet: FontSet = FontSet(mainFontName: soySauceFontName, captionFontName: soySauceCaptionFontName)
let futuristicFontSet: FontSet = FontSet(mainFontName: futuristicFontName, captionFontName: futuristicCaptionFontName)
let gothicFontSet: FontSet = FontSet(mainFontName: gothicFontName, captionFontName: gothicCaptionFontName)
let papyrusFontSet: FontSet = FontSet(mainFontName: papyrusFontName, captionFontName: papyrusCaptionFontName)
let poolsideFMFontSet: FontSet = FontSet(mainFontName: poolsideFMFontName, captionFontName: poolsideFMFontName)

class FontSet {
    
    let mainFontName: String
    let captionFontName: String
    
    init(mainFontName: String, captionFontName: String) {
        
        self.mainFontName = mainFontName
        self.captionFontName = captionFontName
    }
    
    func mainFont(size: CGFloat) -> NSFont {
        NSFont(name: mainFontName, size: size)!
    }
    
    func captionFont(size: CGFloat) -> NSFont {
        NSFont(name: captionFontName, size: size)!
    }
}

extension NSFont {
    
    // Font used in modal dialogs and utility windows.
    static let auxiliary_size13: NSFont = NSFont(name: auxiliaryFontName, size: 13)!
}
