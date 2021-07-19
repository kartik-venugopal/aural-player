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

extension NSFont {
    
    // Font used in modal dialogs and utility windows.
    static let auxiliary_size13: NSFont = NSFont(name: auxiliaryFontName, size: 13)!
    
    static let menuFont: NSFont = standardFontSet.mainFont(size: 11)
    
    static let stringInputPopoverFont: NSFont = standardFontSet.mainFont(size: 12.5)
    static let stringInputPopoverErrorFont: NSFont = standardFontSet.mainFont(size: 11.5)
    
    static let largeTabButtonFont: NSFont = standardFontSet.captionFont(size: 14)
    
    static let helpInfoTextFont: NSFont = standardFontSet.mainFont(size: 12)
    
    static let presetsManagerTableHeaderTextFont: NSFont = standardFontSet.mainFont(size: 13)
    static let presetsManagerTableTextFont: NSFont = standardFontSet.mainFont(size: 12)
    static let presetsManagerTableSelectedTextFont: NSFont = standardFontSet.mainFont(size: 12)
    
    // Font used by the playlist tab view buttons
    static let tabViewButtonFont: NSFont = standardFontSet.mainFont(size: 12)
    static let tabViewButtonBoldFont: NSFont = standardFontSet.mainFont(size: 12)
    
    // Font used by modal dialog buttons
    static let modalDialogButtonFont: NSFont = standardFontSet.mainFont(size: 12)
    
    // Font used by modal dialog control buttons
    static let modalDialogControlButtonFont: NSFont = standardFontSet.mainFont(size: 11)
    
    // Font used by the search modal dialog navigation buttons
    static let modalDialogNavButtonFont: NSFont = standardFontSet.mainFont(size: 12)
    
    // Font used by modal dialog check and radio buttons
    static let checkRadioButtonFont: NSFont = standardFontSet.mainFont(size: 11)
    
    // Font used by the popup menus
    static let popupMenuFont: NSFont = standardFontSet.mainFont(size: 10)
}
