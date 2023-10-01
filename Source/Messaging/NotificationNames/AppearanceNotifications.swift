//
//  AppearanceNotifications.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications that pertain to the appearance of the user interface.
///
extension Notification.Name {
    
    // MARK: Font scheme commands
    
    // Commands all UI components to apply a new specified font scheme.
    static let applyFontScheme = Notification.Name("applyFontScheme")

    // MARK: Color scheme commands

    // Commands all UI components to apply a new specified color scheme.
    static let applyColorScheme = Notification.Name("applyColorScheme")
    
    // Commands the relevant UI components to change the color of the app's main logo.
    static let changeAppLogoColor = Notification.Name("changeAppLogoColor")

    // Commands all relevant UI components to change the color of their background.
    static let changeBackgroundColor = Notification.Name("changeBackgroundColor")

    // Commands all relevant UI components to change the color of their function buttons (eg. play/seek buttons in the player).
    static let changeFunctionButtonColor = Notification.Name("changeFunctionButtonColor")

    // Commands all relevant UI components to change the color of their textual buttons/menus.
    static let changeTextButtonMenuColor = Notification.Name("changeTextButtonMenuColor")

    // Commands all relevant UI components to change the Off state color of their toggle buttons (eg. repeat/shuffle).
    static let changeToggleButtonOffStateColor = Notification.Name("changeToggleButtonOffStateColor")

    // Commands all relevant UI components to change the color of their selected tab buttons.
    static let changeSelectedTabButtonColor = Notification.Name("changeSelectedTabButtonColor")

    // Commands all relevant UI components to change the color of their main text captions.
    static let changeMainCaptionTextColor = Notification.Name("changeMainCaptionTextColor")

    // Commands all relevant UI components to change the color of their tab button text.
    static let changeTabButtonTextColor = Notification.Name("changeTabButtonTextColor")

    // Commands all relevant UI components to change the color of the text of their selected tab buttons.
    static let changeSelectedTabButtonTextColor = Notification.Name("changeSelectedTabButtonTextColor")

    // Commands all relevant UI components to change the color of the text within their textual buttons/menus.
    static let changeButtonMenuTextColor = Notification.Name("changeButtonMenuTextColor")
    
    // MARK: Window appearance commands sent to all app windows
    
    static let windowAppearance_changeCornerRadius = Notification.Name("windowAppearance_changeCornerRadius")
    
    // MARK: Theme commands
    
    static let applyTheme = Notification.Name("applyTheme")
}
