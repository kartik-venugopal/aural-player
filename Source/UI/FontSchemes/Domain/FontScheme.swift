//
//  FontScheme.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Container for fonts used by the UI
 */
class FontScheme: NSObject, UserManagedObject {
    
    // Default color scheme (uses colors from the default system-defined preset)
    static let defaultScheme: FontScheme = .futuristic
    
    // Displayed name
    var name: String
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {!systemDefined}

    // False if defined by the user
    let systemDefined: Bool
    
    var captionFont: NSFont
    
    var normalFont: NSFont
    
    var prominentFont: NSFont {
        
        didSet {
            self.lyricsHighlightFont = NSFont(name: prominentFont.familyName!, size: prominentFont.pointSize * 1.1)!
        }
    }
    
    var lyricsHighlightFont: NSFont
    
    var smallFont: NSFont
    var extraSmallFont: NSFont
    
    var tableYOffset: CGFloat
    
    init(name: String, systemDefined: Bool, captionFont: NSFont, normalFont: NSFont, prominentFont: NSFont, smallFont: NSFont, extraSmallFont: NSFont, tableYOffset: CGFloat) {
        
        self.name = name
        self.systemDefined = systemDefined
        
        self.captionFont = captionFont
        self.normalFont = normalFont
        self.prominentFont = prominentFont
        self.lyricsHighlightFont = NSFont(name: prominentFont.familyName!, size: prominentFont.pointSize * 1.1)!
        self.smallFont = smallFont
        self.extraSmallFont = extraSmallFont
        
        self.tableYOffset = tableYOffset
    }
    
    // Used when loading app state on startup
    init?(persistentState: FontSchemePersistentState?, systemDefined: Bool) {
        
        guard let persistentState = persistentState,
              let schemeName = persistentState.name,
              let textFontName = persistentState.textFontName,
              let captionFontName = persistentState.captionFontName,
              let captionSize = persistentState.captionSize,
              let normalSize = persistentState.normalSize,
              let prominentSize = persistentState.prominentSize,
              let smallSize = persistentState.smallSize,
              let extraSmallSize = persistentState.extraSmallSize,
              let tableYOffset = persistentState.tableYOffset
        else {return nil}
        
        guard let captionFont = NSFont(name: captionFontName, size: captionSize),
              let normalFont = NSFont(name: textFontName, size: normalSize),
              let prominentFont = NSFont(name: textFontName, size: prominentSize),
              let smallFont = NSFont(name: textFontName, size: smallSize),
              let extraSmallFont = NSFont(name: textFontName, size: extraSmallSize)
        else {return nil}
        
        self.name = schemeName
        self.systemDefined = systemDefined
        
        self.captionFont = captionFont
        
        self.normalFont = normalFont
        self.prominentFont = prominentFont
        self.lyricsHighlightFont = NSFont(name: prominentFont.familyName!, size: prominentFont.pointSize * 1.1)!
        self.smallFont = smallFont
        self.extraSmallFont = extraSmallFont
        
        self.tableYOffset = tableYOffset
    }
    
    // Copy constructor ... for theme creation.
    init(name: String, copying otherScheme: FontScheme) {
        
        self.name = name
        
        // Schemes created by the user are always "user-defined".
        self.systemDefined = false
        
        self.captionFont = otherScheme.captionFont
        
        self.normalFont = otherScheme.normalFont
        self.prominentFont = otherScheme.prominentFont
        self.lyricsHighlightFont = otherScheme.lyricsHighlightFont
        self.smallFont = otherScheme.smallFont
        self.extraSmallFont = otherScheme.extraSmallFont
        
        self.tableYOffset = otherScheme.tableYOffset
        
        self.tableYOffset = otherScheme.tableYOffset
    }
    
    // Applies another font scheme to this scheme.
    func applyScheme(_ otherScheme: FontScheme) {
        
        self.captionFont = otherScheme.captionFont
        
        self.name = otherScheme.name

        self.captionFont = otherScheme.captionFont
        
        self.normalFont = otherScheme.normalFont
        self.prominentFont = otherScheme.prominentFont
        self.smallFont = otherScheme.smallFont
        self.extraSmallFont = otherScheme.extraSmallFont
        
        self.tableYOffset = otherScheme.tableYOffset
    }
    
    func clone() -> FontScheme {
        FontScheme(name: self.name + "_clone", copying: self)
    }
}
