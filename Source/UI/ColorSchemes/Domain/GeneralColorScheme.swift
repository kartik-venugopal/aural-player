//
//  GeneralColorScheme.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

/*
    Encapsulates color values that are generally applicable to the entire UI, e.g. window background color.
 */
class GeneralColorScheme {
    
    var appLogoColor: NSColor
    var backgroundColor: NSColor
    
    var viewControlButtonColor: NSColor
    var functionButtonColor: NSColor
    var textButtonMenuColor: NSColor
    var toggleButtonOffStateColor: NSColor
    var selectedTabButtonColor: NSColor
    
    var mainCaptionTextColor: NSColor
    var tabButtonTextColor: NSColor
    var selectedTabButtonTextColor: NSColor
    var buttonMenuTextColor: NSColor
    
    init(_ persistentState: GeneralColorSchemePersistentState?) {
        
        self.appLogoColor = persistentState?.appLogoColor?.toColor() ?? ColorSchemesManager.defaultScheme.general.appLogoColor
        self.backgroundColor = persistentState?.backgroundColor?.toColor() ?? ColorSchemesManager.defaultScheme.general.backgroundColor
        
        self.viewControlButtonColor = persistentState?.viewControlButtonColor?.toColor() ?? ColorSchemesManager.defaultScheme.general.viewControlButtonColor
        
        self.functionButtonColor = persistentState?.functionButtonColor?.toColor() ?? ColorSchemesManager.defaultScheme.general.functionButtonColor
        
        self.textButtonMenuColor = persistentState?.textButtonMenuColor?.toColor() ?? ColorSchemesManager.defaultScheme.general.textButtonMenuColor
        
        self.toggleButtonOffStateColor = persistentState?.toggleButtonOffStateColor?.toColor() ?? ColorSchemesManager.defaultScheme.general.toggleButtonOffStateColor
        
        self.selectedTabButtonColor = persistentState?.selectedTabButtonColor?.toColor() ?? ColorSchemesManager.defaultScheme.general.selectedTabButtonColor
        
        self.mainCaptionTextColor = persistentState?.mainCaptionTextColor?.toColor() ?? ColorSchemesManager.defaultScheme.general.mainCaptionTextColor
        
        self.tabButtonTextColor = persistentState?.tabButtonTextColor?.toColor() ?? ColorSchemesManager.defaultScheme.general.tabButtonTextColor
        
        self.selectedTabButtonTextColor = persistentState?.selectedTabButtonTextColor?.toColor() ?? ColorSchemesManager.defaultScheme.general.selectedTabButtonTextColor
        
        self.buttonMenuTextColor = persistentState?.buttonMenuTextColor?.toColor() ?? ColorSchemesManager.defaultScheme.general.buttonMenuTextColor
    }
    
    init(_ scheme: GeneralColorScheme) {
        
        self.appLogoColor = scheme.appLogoColor
        self.backgroundColor = scheme.backgroundColor
        
        self.viewControlButtonColor = scheme.viewControlButtonColor
        self.functionButtonColor = scheme.functionButtonColor
        self.textButtonMenuColor = scheme.textButtonMenuColor
        self.toggleButtonOffStateColor = scheme.toggleButtonOffStateColor
        self.selectedTabButtonColor = scheme.selectedTabButtonColor
        
        self.mainCaptionTextColor = scheme.mainCaptionTextColor
        self.tabButtonTextColor = scheme.tabButtonTextColor
        self.selectedTabButtonTextColor = scheme.selectedTabButtonTextColor
        self.buttonMenuTextColor = scheme.buttonMenuTextColor
    }
   
    init(_ preset: ColorSchemePreset) {
        
        self.appLogoColor = preset.appLogoColor
        self.backgroundColor = preset.backgroundColor
        
        self.viewControlButtonColor = preset.viewControlButtonColor
        self.functionButtonColor = preset.functionButtonColor
        self.textButtonMenuColor = preset.textButtonMenuColor
        self.toggleButtonOffStateColor = preset.toggleButtonOffStateColor
        self.selectedTabButtonColor = preset.selectedTabButtonColor
        
        self.mainCaptionTextColor = preset.mainCaptionTextColor
        self.tabButtonTextColor = preset.tabButtonTextColor
        self.selectedTabButtonTextColor = preset.selectedTabButtonTextColor
        self.buttonMenuTextColor = preset.buttonMenuTextColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.appLogoColor = preset.appLogoColor
        self.backgroundColor = preset.backgroundColor
        
        self.viewControlButtonColor = preset.viewControlButtonColor
        self.functionButtonColor = preset.functionButtonColor
        self.textButtonMenuColor = preset.textButtonMenuColor
        self.toggleButtonOffStateColor = preset.toggleButtonOffStateColor
        self.selectedTabButtonColor = preset.selectedTabButtonColor
        
        self.mainCaptionTextColor = preset.mainCaptionTextColor
        self.tabButtonTextColor = preset.tabButtonTextColor
        self.selectedTabButtonTextColor = preset.selectedTabButtonTextColor
        self.buttonMenuTextColor = preset.buttonMenuTextColor
    }
    
    func applyScheme(_ scheme: GeneralColorScheme) {
        
        self.appLogoColor = scheme.appLogoColor
        self.backgroundColor = scheme.backgroundColor
        
        self.viewControlButtonColor = scheme.viewControlButtonColor
        self.functionButtonColor = scheme.functionButtonColor
        self.textButtonMenuColor = scheme.textButtonMenuColor
        self.toggleButtonOffStateColor = scheme.toggleButtonOffStateColor
        self.selectedTabButtonColor = scheme.selectedTabButtonColor
        
        self.mainCaptionTextColor = scheme.mainCaptionTextColor
        self.tabButtonTextColor = scheme.tabButtonTextColor
        self.selectedTabButtonTextColor = scheme.selectedTabButtonTextColor
        self.buttonMenuTextColor = scheme.buttonMenuTextColor
    }
    
    func clone() -> GeneralColorScheme {
        return GeneralColorScheme(self)
    }
    
    var persistentState: GeneralColorSchemePersistentState {
        return GeneralColorSchemePersistentState(self)
    }
}
