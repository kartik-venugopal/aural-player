//
//  ColorSchemesPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all persistent state for application color schemes.
///
/// - SeeAlso: `ColorSchemesManager`
///
struct ColorSchemesPersistentState: Codable {

    let systemScheme: ColorSchemePersistentState?
    let userSchemes: [ColorSchemePersistentState]?
    
    init(systemScheme: ColorSchemePersistentState?, userSchemes: [ColorSchemePersistentState]?) {
        
        self.systemScheme = systemScheme
        self.userSchemes = userSchemes
    }
    
    init(legacyPersistentState: LegacyColorSchemesPersistentState?) {
        
        self.systemScheme = ColorSchemePersistentState(legacyPersistentState: legacyPersistentState?.systemScheme)
        self.userSchemes = legacyPersistentState?.userSchemes?.map {ColorSchemePersistentState(legacyPersistentState: $0)}
    }
}

///
/// Persistent state for a single color scheme.
///
/// - SeeAlso: `ColorScheme`
///
struct ColorSchemePersistentState: Codable {
    
    let name: String?
    
    let backgroundColor: ColorPersistentState?
    let buttonColor: ColorPersistentState?
    let captionTextColor: ColorPersistentState?
    
    let primaryTextColor: ColorPersistentState?
    let secondaryTextColor: ColorPersistentState?
    let tertiaryTextColor: ColorPersistentState?
    
    let primarySelectedTextColor: ColorPersistentState?
    let secondarySelectedTextColor: ColorPersistentState?
    let tertiarySelectedTextColor: ColorPersistentState?
    
    let textSelectionColor: ColorPersistentState?
    
    let activeControlColor: ColorPersistentState?
    let inactiveControlColor: ColorPersistentState?
    let suppressedControlColor: ColorPersistentState?
    
    #if os(macOS)
    
    // When saving app state to disk
    init(_ scheme: ColorScheme) {
        
        self.name = scheme.name

        self.backgroundColor = ColorPersistentState(color: scheme.backgroundColor)
        self.buttonColor = ColorPersistentState(color: scheme.buttonColor)
        
        self.captionTextColor = ColorPersistentState(color: scheme.captionTextColor)
        
        self.primaryTextColor = ColorPersistentState(color: scheme.primaryTextColor)
        self.secondaryTextColor = ColorPersistentState(color: scheme.secondaryTextColor)
        self.tertiaryTextColor = ColorPersistentState(color: scheme.tertiaryTextColor)
        
        self.primarySelectedTextColor = ColorPersistentState(color: scheme.primarySelectedTextColor)
        self.secondarySelectedTextColor = ColorPersistentState(color: scheme.secondarySelectedTextColor)
        self.tertiarySelectedTextColor = ColorPersistentState(color: scheme.tertiarySelectedTextColor)
        
        self.textSelectionColor = ColorPersistentState(color: scheme.textSelectionColor)
        
        self.activeControlColor = ColorPersistentState(color: scheme.activeControlColor)
        self.inactiveControlColor = ColorPersistentState(color: scheme.inactiveControlColor)
        self.suppressedControlColor = ColorPersistentState(color: scheme.suppressedControlColor)
    }
    
    init(legacyPersistentState: LegacyColorSchemePersistentState?) {
        
        self.name = legacyPersistentState?.name
        
        self.backgroundColor = legacyPersistentState?.general?.backgroundColor
        self.buttonColor = legacyPersistentState?.general?.functionButtonColor
        self.captionTextColor = legacyPersistentState?.general?.mainCaptionTextColor
        
        self.primaryTextColor = legacyPersistentState?.player?.trackInfoPrimaryTextColor
        self.secondaryTextColor = legacyPersistentState?.player?.trackInfoSecondaryTextColor
        self.tertiaryTextColor = legacyPersistentState?.player?.trackInfoTertiaryTextColor
        
        self.primarySelectedTextColor = legacyPersistentState?.playlist?.trackNameSelectedTextColor
        self.secondarySelectedTextColor = legacyPersistentState?.playlist?.groupNameSelectedTextColor
        self.tertiarySelectedTextColor = legacyPersistentState?.playlist?.indexDurationSelectedTextColor
        
        self.textSelectionColor = legacyPersistentState?.playlist?.selectionBoxColor
        
        self.activeControlColor = legacyPersistentState?.effects?.activeUnitStateColor
        self.inactiveControlColor = legacyPersistentState?.effects?.bypassedUnitStateColor
        self.suppressedControlColor = legacyPersistentState?.effects?.suppressedUnitStateColor
    }
    
    #endif
}
