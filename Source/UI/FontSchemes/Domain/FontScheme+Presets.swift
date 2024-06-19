//
//  FontScheme+Presets.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension FontScheme {
    
    static let standard: FontScheme = .init(name: FontSchemePreset.standard.name, systemDefined: true,
                                            captionFont: standardFontSet.captionFont(size: 14),
                                            normalFont: standardFontSet.mainFont(size: 12),
                                            prominentFont: standardFontSet.mainFont(size: 14),
                                            smallFont: standardFontSet.mainFont(size: 11),
                                            extraSmallFont: standardFontSet.mainFont(size: 9),
                                            tableYOffset: -1)
    
    static let rounded: FontScheme = .init(name: FontSchemePreset.rounded.name, systemDefined: true,
                                           captionFont: roundedFontSet.captionFont(size: 14),
                                           normalFont: roundedFontSet.mainFont(size: 13),
                                           prominentFont: roundedFontSet.mainFont(size: 16),
                                           smallFont: roundedFontSet.mainFont(size: 11.5),
                                           extraSmallFont: roundedFontSet.mainFont(size: 9.5),
                                           tableYOffset: -1)
    
    static let programmer: FontScheme = .init(name: FontSchemePreset.programmer.name, systemDefined: true,
                                              captionFont: programmerFontSet.captionFont(size: 14),
                                              normalFont: programmerFontSet.mainFont(size: 12),
                                              prominentFont: programmerFontSet.mainFont(size: 14),
                                              smallFont: programmerFontSet.mainFont(size: 11),
                                              extraSmallFont: programmerFontSet.mainFont(size: 9),
                                              tableYOffset: -1)
    
    static let futuristic: FontScheme = .init(name: FontSchemePreset.futuristic.name, systemDefined: true,
                                              captionFont: futuristicFontSet.captionFont(size: 16),
                                              normalFont: futuristicFontSet.mainFont(size: 14.5),
                                              prominentFont: futuristicFontSet.mainFont(size: 18),
                                              smallFont: futuristicFontSet.mainFont(size: 13),
                                              extraSmallFont: futuristicFontSet.mainFont(size: 10.5),
                                              tableYOffset: -1)
    
    static let novelist: FontScheme = .init(name: FontSchemePreset.novelist.name, systemDefined: true,
                                            captionFont: novelistFontSet.captionFont(size: 14),
                                            normalFont: novelistFontSet.mainFont(size: 12.5),
                                            prominentFont: novelistFontSet.mainFont(size: 15),
                                            smallFont: novelistFontSet.mainFont(size: 11.5),
                                            extraSmallFont: novelistFontSet.mainFont(size: 9.5),
                                            tableYOffset: -1)
    
    static let soySauce: FontScheme = .init(name: FontSchemePreset.soySauce.name, systemDefined: true,
                                            captionFont: soySauceFontSet.captionFont(size: 15),
                                            normalFont: soySauceFontSet.mainFont(size: 20),
                                            prominentFont: soySauceFontSet.mainFont(size: 25),
                                            smallFont: soySauceFontSet.mainFont(size: 16),
                                            extraSmallFont: soySauceFontSet.mainFont(size: 12),
                                            tableYOffset: -2)
    
    static let gothic: FontScheme = .init(name: FontSchemePreset.gothic.name, systemDefined: true,
                                          captionFont: gothicFontSet.captionFont(size: 15),
                                          normalFont: gothicFontSet.mainFont(size: 11.5),
                                          prominentFont: gothicFontSet.mainFont(size: 14),
                                          smallFont: gothicFontSet.mainFont(size: 10),
                                          extraSmallFont: gothicFontSet.mainFont(size: 8),
                                          tableYOffset: -1)
    
    static let papyrus: FontScheme = .init(name: FontSchemePreset.papyrus.name, systemDefined: true,
                                           captionFont: papyrusFontSet.captionFont(size: 11),
                                           normalFont: papyrusFontSet.mainFont(size: 13.5),
                                           prominentFont: papyrusFontSet.mainFont(size: 16.5),
                                           smallFont: papyrusFontSet.mainFont(size: 11.5),
                                           extraSmallFont: papyrusFontSet.mainFont(size: 10),
                                           tableYOffset: 0)
    
    static let poolsideFM: FontScheme = .init(name: FontSchemePreset.poolsideFM.name, systemDefined: true,
                                              captionFont: poolsideFMFontSet.captionFont(size: 14),
                                              normalFont: poolsideFMFontSet.mainFont(size: 12),
                                              prominentFont: poolsideFMFontSet.mainFont(size: 14),
                                              smallFont: poolsideFMFontSet.mainFont(size: 11),
                                              extraSmallFont: poolsideFMFontSet.mainFont(size: 9),
                                              tableYOffset: -1)
    
    static let allSystemDefinedSchemes: [FontScheme] = [.standard, .rounded, .programmer, .futuristic, .novelist, .soySauce, .gothic, .papyrus, .poolsideFM]
}
