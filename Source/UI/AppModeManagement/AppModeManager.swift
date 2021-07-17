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

///
/// Switches between application user interface modes.
///
class AppModeManager {
    
    var currentMode: AppMode? = nil
    
    private lazy var windowedMode: WindowedAppModeController = WindowedAppModeController()
    
    private lazy var menuBarMode: MenuBarAppModeController = MenuBarAppModeController()
    
    private lazy var controlBarMode: ControlBarAppModeController = ControlBarAppModeController()
    
    func presentMode(_ newMode: AppMode) {
        
        dismissCurrentMode()
        
        switch newMode {
        
        case .windowed:
            
            windowedMode.presentMode(transitioningFromMode: currentMode)
        
        case .menuBar:
            
            menuBarMode.presentMode(transitioningFromMode: currentMode)
            
        case .controlBar:
            
            controlBarMode.presentMode(transitioningFromMode: currentMode)
        }
        
        currentMode = newMode
    }
    
    private func dismissCurrentMode() {
        
        guard let currentMode = self.currentMode else {return}
        
        switch currentMode {
            
        case .windowed:  windowedMode.dismissMode()
            
        case .menuBar: menuBarMode.dismissMode()
            
        case .controlBar:   controlBarMode.dismissMode()
            
        }
    }
}
