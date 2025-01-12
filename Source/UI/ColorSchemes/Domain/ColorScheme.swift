//
//  ColorScheme.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Encapsulates all colors that determine a color scheme that can be appplied to the entire application.
 */
class ColorScheme: NSObject, UserManagedObject {
    
    // Default color scheme (uses colors from the default system-defined preset)
    static let defaultScheme: ColorScheme = .grayRed
    
    // Displayed name
    var name: String
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {!systemDefined}

    // False if defined by the user
    let systemDefined: Bool
    
    // MARK: General colors ----------------------------------------------------------------------------------------
    
    @objc dynamic var backgroundColor: NSColor
    @objc dynamic var buttonColor: NSColor
    
    // MARK: Text colors ----------------------------------------------------------------------------------------
    
    @objc dynamic var captionTextColor: NSColor
    
    @objc dynamic var primaryTextColor: NSColor
    @objc dynamic var secondaryTextColor: NSColor
    @objc dynamic var tertiaryTextColor: NSColor
    
    @objc dynamic var primarySelectedTextColor: NSColor
    @objc dynamic var secondarySelectedTextColor: NSColor
    @objc dynamic var tertiarySelectedTextColor: NSColor
    
    // MARK: Control state colors ----------------------------------------------------------------------------------------
    
    @objc dynamic var activeControlColor: NSColor
    
    @objc dynamic var inactiveControlColor: NSColor
    
    @objc dynamic var suppressedControlColor: NSColor
    
    // MARK: Miscellaneous colors ----------------------------------------------------------------------------------------
    
    @objc dynamic var textSelectionColor: NSColor
    
    // MARK: Functions ----------------------------------------------------------------------------------------
    
    init(name: String, systemDefined: Bool,
         backgroundColor: NSColor, buttonColor: NSColor,
         captionTextColor: NSColor,
         primaryTextColor: NSColor, secondaryTextColor: NSColor, tertiaryTextColor: NSColor,
         primarySelectedTextColor: NSColor, secondarySelectedTextColor: NSColor, tertiarySelectedTextColor: NSColor,
         textSelectionColor: NSColor,
         activeControlColor: NSColor, inactiveControlColor: NSColor, suppressedControlColor: NSColor) {
        
        self.name = name
        self.systemDefined = systemDefined
        
        self.backgroundColor = backgroundColor
        self.buttonColor = buttonColor
        self.captionTextColor = captionTextColor
        
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.tertiaryTextColor = tertiaryTextColor
        
        self.primarySelectedTextColor = primarySelectedTextColor
        self.secondarySelectedTextColor = secondarySelectedTextColor
        self.tertiarySelectedTextColor = tertiarySelectedTextColor
        
        self.activeControlColor = activeControlColor
        self.inactiveControlColor = inactiveControlColor
        self.suppressedControlColor = suppressedControlColor
        
        self.textSelectionColor = textSelectionColor
        
        super.init()
    }
    
    // Copy constructor ... creates a copy of the given scheme (used when creating a user-defined preset)
    init(_ name: String, _ systemDefined: Bool, _ scheme: ColorScheme) {
    
        self.name = name
        self.systemDefined = systemDefined
        
        backgroundColor = scheme.backgroundColor
        buttonColor = scheme.buttonColor
        captionTextColor = scheme.captionTextColor
        
        primaryTextColor = scheme.primaryTextColor
        secondaryTextColor = scheme.secondaryTextColor
        tertiaryTextColor = scheme.tertiaryTextColor
        
        primarySelectedTextColor = scheme.primarySelectedTextColor
        secondarySelectedTextColor = scheme.secondarySelectedTextColor
        tertiarySelectedTextColor = scheme.tertiarySelectedTextColor
        
        textSelectionColor = scheme.textSelectionColor
        
        activeControlColor = scheme.activeControlColor
        inactiveControlColor = scheme.inactiveControlColor
        suppressedControlColor = scheme.suppressedControlColor
        
        super.init()
    }
    
    // Used when loading app state on startup
    init(_ persistentState: ColorSchemePersistentState?, _ systemDefined: Bool) {
        
        self.name = persistentState?.name ?? ""
        self.systemDefined = systemDefined
        
        backgroundColor = persistentState?.backgroundColor?.toColor() ?? Self.defaultScheme.backgroundColor
        buttonColor = persistentState?.buttonColor?.toColor() ?? Self.defaultScheme.buttonColor
        captionTextColor = persistentState?.captionTextColor?.toColor() ?? Self.defaultScheme.captionTextColor
        
        primaryTextColor = persistentState?.primaryTextColor?.toColor() ?? Self.defaultScheme.primaryTextColor
        secondaryTextColor = persistentState?.secondaryTextColor?.toColor() ?? Self.defaultScheme.secondaryTextColor
        tertiaryTextColor = persistentState?.tertiaryTextColor?.toColor() ?? Self.defaultScheme.tertiaryTextColor
        
        primarySelectedTextColor = persistentState?.primarySelectedTextColor?.toColor() ?? Self.defaultScheme.primarySelectedTextColor
        secondarySelectedTextColor = persistentState?.secondarySelectedTextColor?.toColor() ?? Self.defaultScheme.secondarySelectedTextColor
        tertiarySelectedTextColor = persistentState?.tertiarySelectedTextColor?.toColor() ?? Self.defaultScheme.tertiarySelectedTextColor
        
        activeControlColor = persistentState?.activeControlColor?.toColor() ?? Self.defaultScheme.activeControlColor
        inactiveControlColor = persistentState?.inactiveControlColor?.toColor() ?? Self.defaultScheme.inactiveControlColor
        suppressedControlColor = persistentState?.suppressedControlColor?.toColor() ?? Self.defaultScheme.suppressedControlColor
        
        textSelectionColor = persistentState?.textSelectionColor?.toColor() ?? Self.defaultScheme.textSelectionColor
        
        super.init()
    }
    
    deinit {
        kvoTokens.invalidate()
    }
    
    private var kvoTokens: KVOTokens<ColorScheme, NSColor> = KVOTokens()
    
    // Applies another color scheme to this scheme.
    func applyScheme(_ scheme: ColorScheme) {
        
        backgroundColor = scheme.backgroundColor
        buttonColor = scheme.buttonColor
        captionTextColor = scheme.captionTextColor
        
        primaryTextColor = scheme.primaryTextColor
        secondaryTextColor = scheme.secondaryTextColor
        tertiaryTextColor = scheme.tertiaryTextColor
        
        primarySelectedTextColor = scheme.primarySelectedTextColor
        secondarySelectedTextColor = scheme.secondarySelectedTextColor
        tertiarySelectedTextColor = scheme.tertiarySelectedTextColor
        
        textSelectionColor = scheme.textSelectionColor
        
        activeControlColor = scheme.activeControlColor
        inactiveControlColor = scheme.inactiveControlColor
        suppressedControlColor = scheme.suppressedControlColor
    }
    
    // Creates an identical copy of this color scheme
    func clone() -> ColorScheme {
        ColorScheme(self.name + "_clone", self.systemDefined, self)
    }
    
    // State that can be persisted to disk
    var persistentState: ColorSchemePersistentState {
        ColorSchemePersistentState(self)
    }
    
    func colorForEffectsUnitState(_ state: EffectsUnitState) -> NSColor {
        
        switch state {
            
        case .active:       return activeControlColor
            
        case .bypassed:     return inactiveControlColor
            
        case .suppressed:   return suppressedControlColor
            
        }
    }
}
