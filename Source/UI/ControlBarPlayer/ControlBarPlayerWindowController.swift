//
//  ControlBarPlayerWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarPlayerWindowController: NSWindowController, NSWindowDelegate, NSMenuDelegate, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var viewController: ControlBarPlayerViewController!
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var optionsMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    private var snappingWindow: SnappingWindow!
    
    override var windowNibName: String? {"ControlBarPlayer"}
    
    private var appMovingWindow: Bool = false
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        window?.delegate = self
        window?.level = NSWindow.Level(Int(CGWindowLevelForKey(.floatingWindow)))
        
        snappingWindow = window as? SnappingWindow

        if let persistentWindowFrame = ControlBarPlayerViewState.windowFrame {
            window?.setFrame(persistentWindowFrame, display: true, animate: true)
        } else {
            
            // Dock to top left if persistent window frame not available (the first time
            // control bar mode is presented).
            dockTopLeftAction(self)
        }
        
        btnQuit.tintFunction = {Colors.viewControlButtonColor}
        optionsMenuItem.tintFunction = {Colors.viewControlButtonColor}
        
        cornerRadiusStepper.integerValue = ControlBarPlayerViewState.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
        
        applyTheme()
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        
        snappingWindow.ensureOnScreen()
    }
    
    func applyTheme() {
        
        applyColorScheme(colorSchemesManager.systemScheme)
        rootContainerBox.cornerRadius = ControlBarPlayerViewState.cornerRadius
    }
    
    func applyColorScheme(_ colorScheme: ColorScheme) {
        
        rootContainerBox.fillColor = colorScheme.general.backgroundColor
        [btnQuit, optionsMenuItem].forEach {($0 as? Tintable)?.reTint()}
    }
    
    @IBAction func cornerRadiusStepperAction(_ sender: NSStepper) {
        
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
        rootContainerBox.cornerRadius = CGFloat(cornerRadiusStepper.integerValue)
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
    
    func destroy() {
        
        close()
        viewController.destroy()
        Messenger.unsubscribeAll(for: self)
    }
    
    @IBAction func windowedModeAction(_ sender: AnyObject) {
        
        transferViewState()
        AppModeManager.presentMode(.windowed)
    }
    
    @IBAction func menuBarModeAction(_ sender: AnyObject) {
        
        transferViewState()
        AppModeManager.presentMode(.menuBar)
    }

    @IBAction func quitAction(_ sender: AnyObject) {

        transferViewState()
        NSApp.terminate(self)
    }
    
    private func transferViewState() {
        
        ControlBarPlayerViewState.windowFrame = theWindow.frame
        ControlBarPlayerViewState.cornerRadius = rootContainerBox.cornerRadius
    }
    
    // MARK: Menu delegate functions -----------------------------
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        cornerRadiusStepper.integerValue = rootContainerBox.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
    }
}
