//
//  AppSetupWindowController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa
import OrderedCollections

class AppSetupWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"AppSetupWindow"}
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var pathControl: NSPathControl!
    
    @IBOutlet weak var btnNext: NSButton!
    @IBOutlet weak var btnPrevious: NSButton!
    
    private var indexOfLastTabViewItem: Int {
        tabView.numberOfTabViewItems - 1
    }
    
    private let presentationModeSetupViewController: PresentationModeSetupViewController = .init()
    private let windowLayoutSetupViewController: WindowLayoutSetupViewController = .init()
    private let themeSetupViewController: ThemeSetupViewController = .init()
//    private let libraryHomeSetupViewController: LibraryHomeSetupViewController = .init()
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    private var titlesAndIndices: OrderedDictionary<String, Int> = .init()
    
    fileprivate static let pathControlFont: NSFont = NSFont(name: standardFontName, size: 15)!
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        window?.isMovableByWindowBackground = true
        window?.center()
        
        pathControl.pathItems.removeAll()
        
        let titles: [String] = ["Presentation Mode", "Window Layout", "Theme"]
        let pathItems: [NSPathControlItem] = titles.enumerated().map {(index, title) in
            
            titlesAndIndices[title] = index
            
            let item = NSPathControlItem()
            item.attributedTitle = title.attributed(withFont: Self.pathControlFont, andColor: .lightGray)
            return item
        }
        
        pathItems.first?.setTitleColor(.white)
        
        pathControl.pathItems.append(contentsOf: pathItems)
        
        for (index, controller) in [presentationModeSetupViewController, windowLayoutSetupViewController, 
                                    themeSetupViewController].enumerated() {
            
            tabView.tabViewItem(at: index).view?.addSubview(controller.view)
            controller.view.anchorToSuperview()
        }
    }
    
    @IBAction func pathControlAction(_ sender: NSPathControl) {
        
        guard let clickedItem = sender.clickedPathItem,
              let index = titlesAndIndices[clickedItem.title] else {return}
        
        if index == 1, appSetup.presentationMode != .modular {
            return
        }
        
        tabView.selectTabViewItem(at: index)
        
        if tabView.selectedIndex > 0 {
            
            for index in 0..<tabView.selectedIndex {
                pathControl.pathItems[index].setTitleColor(.systemBlue)
            }
        }
        
        pathControl.pathItems[tabView.selectedIndex].setTitleColor(.white)
        
        if tabView.selectedIndex < indexOfLastTabViewItem {
            
            for index in (tabView.selectedIndex + 1)...indexOfLastTabViewItem {
                pathControl.pathItems[index].setTitleColor(.lightGray)
            }
        }
        
        btnPrevious.enableIf(tabView.selectedIndex > 0)
        btnNext.title = tabView.selectedIndex == indexOfLastTabViewItem ? "Done" : "Next"
    }
    
    @IBAction func nextStepAction(_ sender: Any) {
        
        if tabView.selectedIndex == 0, appSetup.presentationMode != .modular {
            
            pathControl.pathItems[0].setTitleColor(.systemBlue)
            
            // Skip window layout
            doNextTab()
            doNextTab()
            
        } else if tabView.selectedIndex == indexOfLastTabViewItem {
            
            // Last step, done with setup
            close()
            appSetup.setupCompleted = true
            messenger.publish(.appSetup_completed)
            
        } else {
            doNextTab()
        }
        
        pathControl.pathItems[tabView.selectedIndex - 1].setTitleColor(.systemBlue)
        pathControl.pathItems[tabView.selectedIndex].setTitleColor(.white)
        
        if tabView.selectedIndex == indexOfLastTabViewItem {
            btnNext.title = "Done"
        }
    }
    
    private func doNextTab() {
        
        tabView.selectNextTabViewItem(self)
        btnPrevious.enable()
    }
    
    @IBAction func previousStepAction(_ sender: Any) {
        
        guard tabView.selectedIndex > 0 else {return}
        
        if tabView.selectedIndex == 2, appSetup.presentationMode != .modular {
            
            pathControl.pathItems[2].setTitleColor(.lightGray)
            
            // Skip window layout
            doPreviousTab()
        }
        
        doPreviousTab()
        
        if tabView.selectedIndex == 0 {
            btnPrevious.disable()
        }
        
        btnNext.title = "Next"
        
        pathControl.pathItems[tabView.selectedIndex].setTitleColor(.white)
        pathControl.pathItems[tabView.selectedIndex + 1].setTitleColor(.lightGray)
    }
    
    private func doPreviousTab() {
        tabView.selectPreviousTabViewItem(self)
    }
    
    @IBAction func skipSetupAction(_ sender: Any) {
        
        close()
        appSetup.setupCompleted = false
        messenger.publish(.appSetup_completed)
    }
}

extension NSPathControlItem {
    
    func setTitleColor(_ color: NSColor) {
        attributedTitle = title.attributed(withFont: AppSetupWindowController.pathControlFont, andColor: color)
    }
}
