//
//  ColorScheme+Presets.swift
//  Aural-macOS
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

extension ColorScheme {
    
    static let lava: ColorScheme = .init(name: "Lava", systemDefined: true,
                                         
                                         backgroundColor: PlatformColor(red: 0.144, green: 0.144, blue: 0.144),
                                         buttonColor: .white70Percent,
                                         iconColor: .white60Percent,
                                         
                                         captionTextColor: .white40Percent,
                                         
                                         primaryTextColor: .white70Percent,
                                         secondaryTextColor: .white50Percent,
                                         tertiaryTextColor: .white40Percent,
                                         
                                         primarySelectedTextColor: .white,
                                         secondarySelectedTextColor: .white75Percent,
                                         tertiarySelectedTextColor: .white50Percent,
                                         
                                         textSelectionColor: .black,
                                         
                                         activeControlColor: .lava,
                                         inactiveControlColor: .white40Percent,
                                         suppressedControlColor: PlatformColor(red: 0.5, green: 0.204, blue: 0.107))
    
    static let blackAqua: ColorScheme = .init(name: "Black & aqua", systemDefined: true,
                                              
                                              backgroundColor: .white8Percent,
                                              buttonColor: .white90Percent,
                                              iconColor: .white60Percent,
                                              
                                              captionTextColor: .white40Percent,
                                              
                                              primaryTextColor: .white70Percent,
                                              secondaryTextColor: .white45Percent,
                                              tertiaryTextColor: .white30Percent,
                                              
                                              primarySelectedTextColor: .white,
                                              secondarySelectedTextColor: .white75Percent,
                                              tertiarySelectedTextColor: .white50Percent,
                                              
                                              textSelectionColor: .white15Percent,
                                              
                                              activeControlColor: .aqua,
                                              inactiveControlColor: .white30Percent,
                                              suppressedControlColor: PlatformColor(red: 0, green: 0.31, blue: 0.5))
    
    static let blackGreen: ColorScheme = .init(name: "Black & green", systemDefined: true,
                                               
                                               backgroundColor: .white8Percent,
                                               buttonColor: .white90Percent,
                                               iconColor: .white60Percent,
                                               
                                               captionTextColor: .white40Percent,
                                               
                                               primaryTextColor: .white70Percent,
                                               secondaryTextColor: .white45Percent,
                                               tertiaryTextColor: .white30Percent,
                                               
                                               primarySelectedTextColor: .white,
                                               secondarySelectedTextColor: .white75Percent,
                                               tertiarySelectedTextColor: .white50Percent,
                                               
                                               textSelectionColor: .white15Percent,
                                               
                                               activeControlColor: .green75Percent,
                                               inactiveControlColor: .white30Percent,
                                               suppressedControlColor: .green50Percent)
    
    static let whiteBlight: ColorScheme = .init(name: "White blight", systemDefined: true,
                                                
                                                backgroundColor: .white75Percent,
                                                buttonColor: .black,
                                                iconColor: .white60Percent,
                                                
                                                captionTextColor: .white30Percent,
                                                
                                                primaryTextColor: .black,
                                                secondaryTextColor: .white25Percent,
                                                tertiaryTextColor: .white40Percent,
                                                
                                                primarySelectedTextColor: .white,
                                                secondarySelectedTextColor: .white85Percent,
                                                tertiarySelectedTextColor: .white20Percent,
                                                
                                                textSelectionColor: .white60Percent,
                                                
                                                activeControlColor: .black,
                                                inactiveControlColor: .white50Percent,
                                                suppressedControlColor: .white25Percent)
    
    static let gloomyDay: ColorScheme = .init(name: "Gloomy day", systemDefined: true,
                                              
                                              backgroundColor: .white20Percent,
                                              buttonColor: .white80Percent,
                                              iconColor: .white60Percent,
                                              
                                              captionTextColor: .white40Percent,
                                              
                                              primaryTextColor: .white70Percent,
                                              secondaryTextColor: .white45Percent,
                                              tertiaryTextColor: .white35Percent,
                                              
                                              primarySelectedTextColor: .white,
                                              secondarySelectedTextColor: .white75Percent,
                                              tertiarySelectedTextColor: .white50Percent,
                                              
                                              textSelectionColor: .black,
                                              
                                              activeControlColor: .white70Percent,
                                              inactiveControlColor: .white35Percent,
                                              suppressedControlColor: .white50Percent)
    
    static let poolsideFM: ColorScheme = .init(name: "Poolside.fm", systemDefined: true,
                                                
                                                backgroundColor: PlatformColor(red: 1, green: 0.7882353, blue: 0.7882353),
                                                buttonColor: .black,
                                                iconColor: PlatformColor(red: 0.671, green: 0.467, blue: 0.475),
                                                
                                                captionTextColor: .black,
                                                
                                                primaryTextColor: .black,
                                                secondaryTextColor: .white20Percent,
                                                tertiaryTextColor: .white40Percent,
                                                
                                                primarySelectedTextColor: .white,
                                                secondarySelectedTextColor: .white80Percent,
                                                tertiarySelectedTextColor: .white60Percent,
                                                
                                                textSelectionColor: PlatformColor(red: 0.55, green: 0.38, blue: 0.39),
                                                
                                                activeControlColor: .black,
                                                inactiveControlColor: .white50Percent,
                                                suppressedControlColor: .white25Percent)
    
    static let allPresets: [ColorScheme] = [.lava, .blackAqua, .blackGreen, .whiteBlight, .gloomyDay, .poolsideFM]
}
