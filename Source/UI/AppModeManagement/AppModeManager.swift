//
//  AppModeManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class AppModeManager {
    
    static var mode: AppMode!
    
    private static var windowedMode: WindowedAppModeController = WindowedAppModeController()
    
    private static var menuBarMode: MenuBarAppModeController = MenuBarAppModeController()
    
    private static var controlBarMode: ControlBarAppModeController = ControlBarAppModeController()
    
    static func presentApp(lastPresentedAppMode: AppMode, preferences: ViewPreferences) {
        
        if preferences.appModeOnStartup.option == .rememberFromLastAppLaunch {
            presentMode(lastPresentedAppMode)
            
        } else {    // Specific mode
            presentMode(AppMode(rawValue: preferences.appModeOnStartup.modeName) ?? AppMode.defaultMode)
        }
    }
    
    static func presentMode(_ newMode: AppMode) {
        
        dismissCurrentMode()
        
        switch newMode {
        
        case .windowed:  windowedMode.presentMode(transitioningFromMode: mode)
        
        case .menuBar: menuBarMode.presentMode(transitioningFromMode: mode)
            
        case .controlBar:   controlBarMode.presentMode(transitioningFromMode: mode)
        
        }
        
        mode = newMode
    }
    
    private static func dismissCurrentMode() {
        
        guard let currentMode = self.mode else {return}
        
        switch currentMode {
            
        case .windowed:  windowedMode.dismissMode()
            
        case .menuBar: menuBarMode.dismissMode()
            
        case .controlBar:   controlBarMode.dismissMode()
            
        }
    }
}

enum AppMode: String {
    
    static let defaultMode: AppMode = .windowed
    
    case windowed
    case menuBar
    case controlBar
}

protocol AppModeController {
    
    var mode: AppMode {get}
    
    func presentMode(transitioningFromMode previousMode: AppMode?)
    
    func dismissMode()
}
