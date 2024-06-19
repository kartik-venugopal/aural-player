//
//  FavoriteGroupsViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoritesTableViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: tableView)
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor], handler: tableTextColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primarySelectedTextColor, \.secondarySelectedTextColor],
                                                     handler: selectedTextColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.textSelectionColor,
                                                     handler: textSelectionColorChanged(_:))
        
        messenger.subscribe(to: .Favorites.itemAdded, handler: tableView.reloadData)
        messenger.subscribe(to: .Favorites.itemsRemoved, handler: tableView.reloadData)
    }
}

extension FavoritesTableViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    // Override this !!!
    @objc var numberOfFavorites: Int {
        0
    }
    
    // Override this !!!
    @objc func nameOfFavorite(forRow row: Int) -> String? {
        nil
    }
    
    // Override this !!!
    @objc func image(forRow row: Int) -> NSImage {
        .imgGroup
    }
    
    // ----------------
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        numberOfFavorites
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let columnId = tableColumn?.identifier,
              columnId == .cid_favoriteColumn,
              let nameOfFavorite = nameOfFavorite(forRow: row) else {return nil}
        
        let builder = TableCellBuilder()
            .withText(text: nameOfFavorite,
                      inFont: systemFontScheme.normalFont,
                      andColor: systemColorScheme.primaryTextColor,
                      selectedTextColor: systemColorScheme.primarySelectedTextColor)
            .withImage(image: image(forRow: row))
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: columnId, inRow: row)
    }
}

extension FavoritesTableViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        tableView.reloadData()
    }
}

extension FavoritesTableViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        tableView.setBackgroundColor(systemColorScheme.backgroundColor)
        tableView.reloadData()
    }
    
    func tableTextColorChanged(_ newColor: NSColor) {
        tableView.reloadData()
    }
    
    func selectedTextColorChanged(_ newColor: NSColor) {
        tableView.reloadRows(tableView.selectedRowIndexes)
    }
    
    func textSelectionColorChanged(_ newColor: NSColor) {
        tableView.redoRowSelection()
    }
}

