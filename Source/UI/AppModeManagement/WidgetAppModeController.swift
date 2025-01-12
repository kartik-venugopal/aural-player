//
//  WidgetAppModeController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Controller responsible for presenting / dismissing the *Widget* application user interface mode.
///
/// The widget app mode presents a minimalistic user interface consisting of a single compact "floating"
/// window containing only player controls, playing track info, and some options to change the displayed info
/// and appearance (theme).
///
/// The widget app mode allows the user access to essential player functions and is intended for a
/// low level of user interaction. It will typically be used when running the application in the "background".
///
class WidgetAppModeController: AppModeController {
    
    var mode: AppMode {.widget}
    
    var windowMagnetism: Bool = false
    
    var isShowingPlayer: Bool {true}
    
    var isShowingPlayQueue: Bool {true}

    var isShowingLyrics: Bool {
        true
    }
    
    var isShowingEffects: Bool {true}
    
    var isShowingChaptersList: Bool {true}
    
    var isShowingVisualizer: Bool {true}
    
    var isShowingTrackInfo: Bool {true}
    
    var isShowingWaveform: Bool {false}

    private var windowController: WidgetPlayerWindowController?
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {

        NSApp.setActivationPolicy(.accessory)
        NSApp.activate(ignoringOtherApps: true)
        
        windowController = WidgetPlayerWindowController()
        windowController?.showWindow(self)
    }
    
    func dismissMode() {
        
        windowController?.destroy()
        windowController = nil
    }
}
