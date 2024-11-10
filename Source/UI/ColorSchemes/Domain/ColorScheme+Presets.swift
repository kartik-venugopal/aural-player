//
//  ColorScheme+Presets.swift
//  Aural-macOS
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AppKit

extension ColorScheme {
    
    static let lava: ColorScheme = .init(name: "Lava", systemDefined: true,
                                         
                                         backgroundColor: NSColor(red: 0.144, green: 0.144, blue: 0.144),
                                         buttonColor: .white70Percent,
                                         
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
                                         suppressedControlColor: NSColor(red: 0.5, green: 0.204, blue: 0.107))
    
    static let blackAqua: ColorScheme = .init(name: "Black & aqua", systemDefined: true,
                                              
                                              backgroundColor: .white8Percent,
                                              buttonColor: .white90Percent,
                                              
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
                                              suppressedControlColor: NSColor(red: 0, green: 0.31, blue: 0.5))
    
    static let blackGreen: ColorScheme = .init(name: "Black & green", systemDefined: true,
                                               
                                               backgroundColor: .white8Percent,
                                               buttonColor: .white90Percent,
                                               
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
    
    static let grayRed: ColorScheme = .init(name: "Gray & red", systemDefined: true,
                                               
                                               backgroundColor: NSColor(white: 0.1225),
                                               buttonColor: .white55Percent,
                                               
                                               captionTextColor: .white40Percent,
                                               
                                               primaryTextColor: .white60Percent,
                                               secondaryTextColor: .white50Percent,
                                               tertiaryTextColor: .white40Percent,
                                               
                                               primarySelectedTextColor: .white80Percent,
                                               secondarySelectedTextColor: .white70Percent,
                                               tertiarySelectedTextColor: .white60Percent,
                                               
                                               textSelectionColor: .black,
                                               
                                            activeControlColor: NSColor(red: 0.777746456185567, green: 0.17426582771233134, blue: 0.12780412229666493),
                                            inactiveControlColor: .white22Percent,
                                               suppressedControlColor: NSColor(red: 0.5, green: 0.10164300227543215, blue: 0.07177490018553201))
    
    static let whiteBlight: ColorScheme = .init(name: "White blight", systemDefined: true,
                                                
                                                backgroundColor: .white75Percent,
                                                buttonColor: .black,
                                                
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
    
    static let brownie: ColorScheme = .init(name: "Brownie", systemDefined: true,
                                            
                                            backgroundColor: NSColor(red: 0.25, green: 0.162, blue: 0.131),
                                            buttonColor: NSColor(red: 0.636, green: 0.483, blue: 0.44),
                                            
                                            captionTextColor: NSColor(red: 0.536, green: 0.356, blue: 0.29),
                                            
                                            primaryTextColor: NSColor(red: 0.614, green: 0.407, blue: 0.332),
                                            secondaryTextColor: NSColor(red: 0.448, green: 0.297, blue: 0.243),
                                            tertiaryTextColor: NSColor(red: 0.38, green: 0.252, blue: 0.206),
                                            
                                            primarySelectedTextColor: NSColor(red: 0.856, green: 0.346, blue: 0.286),
                                            secondarySelectedTextColor: NSColor(red: 0.668, green: 0.271, blue: 0.221),
                                            tertiarySelectedTextColor: NSColor(red: 0.521, green: 0.212, blue: 0.171),
                                            
                                            textSelectionColor: NSColor(red: 0.073, green: 0.047, blue: 0.038),
                                            
                                            activeControlColor: NSColor(red: 0.8, green: 0.329, blue: 0.293),
                                            inactiveControlColor: NSColor(red: 0.668, green: 0.507, blue: 0.436),
                                            suppressedControlColor: NSColor(red: 0.599, green: 0.245, blue: 0.217))
    
    static let poolsideFM: ColorScheme = .init(name: "Poolside.fm", systemDefined: true,
                                                
                                                backgroundColor: NSColor(red: 1, green: 0.7882353, blue: 0.7882353),
                                                buttonColor: .black,
                                                
                                                captionTextColor: .black,
                                                
                                                primaryTextColor: .black,
                                                secondaryTextColor: .white20Percent,
                                                tertiaryTextColor: .white40Percent,
                                                
                                                primarySelectedTextColor: .white,
                                                secondarySelectedTextColor: .white80Percent,
                                                tertiarySelectedTextColor: .white60Percent,
                                                
                                                textSelectionColor: NSColor(red: 0.55, green: 0.38, blue: 0.39),
                                                
                                                activeControlColor: .black,
                                                inactiveControlColor: .white50Percent,
                                                suppressedControlColor: .white25Percent)
    
    static let allSystemDefinedSchemes: [ColorScheme] = [.lava, .blackAqua, .blackGreen, .grayRed, .whiteBlight, .gloomyDay, .brownie, .poolsideFM]
}
