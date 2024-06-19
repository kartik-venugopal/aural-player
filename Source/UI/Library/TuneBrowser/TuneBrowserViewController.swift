//
//  TuneBrowserViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa
import OrderedCollections

class TuneBrowserViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"TuneBrowser"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var btnBack: TintedImageButton!
    @IBOutlet weak var btnForward: TintedImageButton!
    
    @IBOutlet weak var backHistoryMenu: NSMenu!
    @IBOutlet weak var forwardHistoryMenu: NSMenu!
    
    @IBOutlet weak var imgHomeIcon: TintedImageView!
    @IBOutlet weak var pathControlWidget: NSPathControl!
    
    let history: TuneBrowserHistory = TuneBrowserHistory()
    private var tabs: OrderedDictionary<URL, NSTabViewItem> = .init()
    
    var currentTabVC: TuneBrowserTabViewController? {
        tabView.selectedTabViewItem?.viewController as? TuneBrowserTabViewController
    }
    
    private var respondToSidebarSelectionChange: Bool = true
    
    private lazy var messenger = Messenger(for: self)
    
    let textFont: NSFont = standardFontSet.mainFont(size: 13)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: backgroundColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primaryTextColor, handler: primaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: [btnBack, btnForward, imgHomeIcon])
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribe(to: .tuneBrowser_openFolder, handler: openFolder(notif:))
        messenger.subscribe(to: .Application.willExit, handler: onAppExit)
        
        // TODO: This is inefficient!!! Wait till library is built before doing this.
        messenger.subscribeAsync(to: .Library.doneAddingTracks) {[weak self] in
            self?.recreateAllFolders()
        }
        
        pathControlWidget.url = nil
        
        recreateAllFolders()
        updateNavButtons()
    }
    
    private func recreateAllFolders() {
        
        tabView.tabViewItems.forEach {
            $0.viewController?.destroy()
        }
        
        tabView.tabViewItems.removeAll()
        
        tabs.removeAll()
        
        // Library source folders
        for tree in libraryDelegate.fileSystemTrees {
            createTabForFolder(tree.root, inTree: tree)
        }
        
        if let firstTabVC = self.tabs.values.first?.viewController as? TuneBrowserTabViewController {
            
            showFolder(firstTabVC.rootFolder, inTree: firstTabVC.tree, updateHistory: false)
            
            let location = firstTabVC.location
            updatePathWidget(forFolder: location.folder, inTree: location.tree)
        }
        
        // Shortcut folders (sidebar)
//        for folder in tuneBrowserUIState.sidebarUserFolders {
//            
//        }
    }
    
    @discardableResult private func createTabForFolder(_ folder: FileSystemFolderItem, inTree tree: FileSystemTree) -> TuneBrowserTabViewController {
        
        let tabVC = TuneBrowserTabViewController(pathControlWidget: self.pathControlWidget, tree: tree, rootFolder: folder)
        
        let tabViewItem = NSTabViewItem(viewController: tabVC)
        tabView.addTabViewItem(tabViewItem)
//        tabVC.view.anchorToSuperview()
        
        self.tabs[folder.url] = tabViewItem
        
        return tabVC
    }
    
//    private func showFirstSourceFolder() {
//        
//        respondToSidebarSelectionChange = false
//        tabView.selectTabViewItem(at: 0)
//        respondToSidebarSelectionChange = true
//        
//        // Select it in the sidebar
//    }
    
    func showFolder(_ folder: FileSystemFolderItem, inTree tree: FileSystemTree, updateHistory: Bool) {
        
        guard let currentTabVC = self.currentTabVC else {return}
        
        // If same folder as currently displayed, don't do anything
        if currentTabVC.location.tree == tree && currentTabVC.location.folder == folder {
            return
        }
        
        if updateHistory {
            
            history.notePreviousLocation(currentTabVC.location)
            updateNavButtons()
        }
        
        updatePathWidget(forFolder: folder, inTree: tree)
        
        // Check if any existing tab is already showing the target URL.
        if let existingTab = tabs[folder.url],
            let tabVC = existingTab.viewController as? TuneBrowserTabViewController {
            
            tabVC.scrollToTop()
            tabView.selectTabViewItem(existingTab)
            
        } else {
            
            createTabForFolder(folder, inTree: tree)
            tabView.showLastTab()
        }
        
        updateSidebarSelection()
    }
    
    private func recreatePathWidgetItems() {
        
        guard let currentTabVC = self.currentTabVC else {return}
        let pathComponents = currentTabVC.tree.relativePathComponents(forFolder: currentTabVC.rootFolder)
        
        pathControlWidget.pathItems = pathComponents.map {
            
            let item = NSPathControlItem()
            item.attributedTitle = $0.attributed(withFont: systemFontScheme.normalFont, andColor: systemColorScheme.primaryTextColor)
            return item
        }
    }
    
    private func updatePathWidget(forFolder folder: FileSystemFolderItem, inTree tree: FileSystemTree) {
        
        let pathComponents = tree.relativePathComponents(forFolder: folder)
        
        pathControlWidget.pathItems = pathComponents.map {
            
            let item = NSPathControlItem()
            item.attributedTitle = $0.attributed(withFont: systemFontScheme.normalFont, andColor: systemColorScheme.primaryTextColor)
            return item
        }
    }
    
    private func openFolder(notif: OpenTuneBrowserFolderCommandNotification) {
        showFolder(notif.folderToOpen, inTree: notif.treeContainingFolder, updateHistory: true)
    }
    
    // If the folder currently shown by the browser corresponds to one of the folder shortcuts in the sidebar, select that
    // item in the sidebar.
    func updateSidebarSelection() {
        
        if let currentLocation = currentTabVC?.location {
            messenger.publish(.tuneBrowser_displayedFolderChanged, payload: currentLocation)
        }
    }
    
    func updateNavButtons() {
        
        btnBack.enableIf(history.canGoBack)
        btnForward.enableIf(history.canGoForward)

        backHistoryMenu.removeAllItems()
        forwardHistoryMenu.removeAllItems()
        
        if history.canGoBack {
            
            for location in history.backStack.underlyingArray.reversed() {
                
                let item = TuneBrowserHistoryMenuItem(title: location.folderName, action: #selector(backHistoryMenuAction(_:)))
                item.location = location
                item.target = self
                
                backHistoryMenu.addItem(item)
            }
        }
        
        if history.canGoForward {
            
            for location in history.forwardStack.underlyingArray.reversed() {
                
                let item = TuneBrowserHistoryMenuItem(title: location.folderName, action: #selector(backHistoryMenuAction(_:)))
                item.location = location
                item.target = self
                
                forwardHistoryMenu.addItem(item)
            }
        }
    }
    
    private func onAppExit() {
        
//        tuneBrowserUIState.displayedColumns = browserView.tableColumns.filter {$0.isShown}
//        .map {TuneBrowserTableColumn(id: $0.identifier.rawValue, width: $0.width)}
    }
    
    override func destroy() {
        
        // Check if any existing tab is already showing the target URL.
        for tab in tabView.tabViewItems {
            
            if let tabVC = tab.viewController as? TuneBrowserTabViewController {
                tabVC.destroy()
            }
        }
        
        messenger.unsubscribeFromAll()
    }
}

extension TuneBrowserViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        recreatePathWidgetItems()
    }
    
    fileprivate func updatePathControlItemTheming() {
        
        for item in pathControlWidget.pathItems {
            item.attributedTitle = item.title.attributed(withFont: systemFontScheme.normalFont, andColor: systemColorScheme.primaryTextColor)
        }
    }
}

extension TuneBrowserViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainer.fillColor = systemColorScheme.backgroundColor
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        pathControlWidget.backgroundColor = systemColorScheme.backgroundColor
        updatePathControlItemTheming()
        
        [btnBack, btnForward].forEach {
            $0?.contentTintColor = systemColorScheme.buttonColor
        }
        
        imgHomeIcon.contentTintColor = systemColorScheme.buttonColor
    }
    
    fileprivate func backgroundColorChanged(_ newColor: NSColor) {
        
        rootContainer.fillColor = newColor
        pathControlWidget.backgroundColor = newColor
    }
    
    fileprivate func primaryTextColorChanged(_ newColor: NSColor) {
        updatePathControlItemTheming()
    }
}

extension NSTabView {
    
    func showLastTab() {
        
        if tabViewItems.isNonEmpty {
            selectTabViewItem(at: numberOfTabViewItems - 1)
        }
    }
}

class TuneBrowserHistoryMenuItem: NSMenuItem {
    
    var location: FileSystemFolderLocation!
}
