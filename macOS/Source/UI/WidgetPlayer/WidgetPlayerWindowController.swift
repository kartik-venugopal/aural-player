//
//  WidgetPlayerWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class WidgetPlayerWindowController: NSWindowController, NSWindowDelegate, NSMenuDelegate, ColorSchemeObserver {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var viewController: WidgetPlayerViewController!
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var optionsMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    private var snappingWindow: SnappingWindow!
    
    private lazy var messenger = Messenger(for: self)
    
    private let uiState: WidgetPlayerUIState = widgetPlayerUIState
    
    override var windowNibName: String? {"WidgetPlayer"}
    
    private var appMovingWindow: Bool = false
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        window?.delegate = self
        window?.level = NSWindow.Level(Int(CGWindowLevelForKey(.floatingWindow)))
        
        snappingWindow = window as? SnappingWindow

        if let persistentWindowFrame = uiState.windowFrame {
            window?.setFrame(persistentWindowFrame, display: true, animate: false)

        } else {
            
            // Dock to top left if persistent window frame not available (the first time
            // widget mode is presented).
            dockTopLeftAction(self)
        }
        
        rootContainerBox.cornerRadius = uiState.cornerRadius
        cornerRadiusStepper.integerValue = uiState.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
        
        colorSchemesManager.registerSchemeObserver(self)
        
        snappingWindow.ensureOnScreen()
    }
    
    @IBAction func cornerRadiusStepperAction(_ sender: NSStepper) {
        
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
        rootContainerBox.cornerRadius = CGFloat(cornerRadiusStepper.integerValue)
        uiState.cornerRadius = rootContainerBox.cornerRadius
    }
    
    // MARK: Window delegate functions --------------------------------
    
    func windowDidResize(_ notification: Notification) {
        viewController.windowResized()
    }
    
    func windowDidMove(_ notification: Notification) {
        snappingWindow.checkForSnapToVisibleFrame()
    }
    
    // MARK: Window docking functions --------------------------------
    
    private var computedVisibleFrame: NSRect {NSScreen.main!.visibleFrame}
    
    @IBAction func dockTopLeftAction(_ sender: AnyObject) {
        
        let visibleFrame = computedVisibleFrame
        moveWindowTo(visibleFrame.minX, visibleFrame.maxY - theWindow.height)
    }
    
    @IBAction func dockTopCenterAction(_ sender: AnyObject) {
        
        let visibleFrame = computedVisibleFrame
        let xPadding = (visibleFrame.width - theWindow.width) / 2
        moveWindowTo(visibleFrame.minX + xPadding, visibleFrame.maxY - theWindow.height)
    }
    
    @IBAction func dockTopRightAction(_ sender: AnyObject) {
        
        let visibleFrame = computedVisibleFrame
        moveWindowTo(visibleFrame.maxX - theWindow.width, visibleFrame.maxY - theWindow.height)
    }
    
    @IBAction func dockTopAction(_ sender: AnyObject) {
        
        let visibleFrame = computedVisibleFrame
        moveWindowTo(visibleFrame.minX, visibleFrame.maxY - theWindow.height)
        theWindow.resize(visibleFrame.width, theWindow.height)
    }
    
    @IBAction func dockBottomLeftAction(_ sender: AnyObject) {
        
        let visibleFrame = computedVisibleFrame
        moveWindowTo(visibleFrame.minX, visibleFrame.minY)
    }
    
    @IBAction func dockBottomCenterAction(_ sender: AnyObject) {
        
        let visibleFrame = computedVisibleFrame
        let xPadding = (visibleFrame.width - theWindow.width) / 2
        moveWindowTo(visibleFrame.minX + xPadding, visibleFrame.minY)
    }
    
    @IBAction func dockBottomRightAction(_ sender: AnyObject) {
        
        let visibleFrame = computedVisibleFrame
        moveWindowTo(visibleFrame.maxX - theWindow.width, visibleFrame.minY)
    }
    
    @IBAction func dockBottomAction(_ sender: AnyObject) {
        
        let visibleFrame = computedVisibleFrame
        moveWindowTo(visibleFrame.minX, visibleFrame.minY)
        theWindow.resize(visibleFrame.width, theWindow.height)
    }
    
    private func moveWindowTo(_ x: CGFloat, _ y: CGFloat) {
        
        appMovingWindow = true
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
        appMovingWindow = false
    }
    
    override func destroy() {
        
        close()
        viewController.destroy()
        messenger.unsubscribeFromAll()
    }
    
    @IBAction func modularModeAction(_ sender: AnyObject) {
        
        transferViewState()
        appModeManager.presentMode(.modular)
    }
    
    @IBAction func unifiedModeAction(_ sender: AnyObject) {
        
        transferViewState()
        appModeManager.presentMode(.unified)
    }
    
    @IBAction func compactModeAction(_ sender: AnyObject) {
        
        transferViewState()
        appModeManager.presentMode(.compact)
    }
    
    @IBAction func menuBarModeAction(_ sender: AnyObject) {
        
        transferViewState()
        appModeManager.presentMode(.menuBar)
    }

    @IBAction func quitAction(_ sender: AnyObject) {

        transferViewState()
        NSApp.terminate(self)
    }
    
    private func transferViewState() {
        uiState.windowFrame = theWindow.frame
    }
    
    // MARK: Menu delegate functions -----------------------------
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        cornerRadiusStepper.integerValue = rootContainerBox.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
    }
    
    func colorSchemeChanged() {
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        btnQuit.contentTintColor = systemColorScheme.buttonColor
        optionsMenuItem.colorChanged(systemColorScheme.buttonColor)
    }
}
