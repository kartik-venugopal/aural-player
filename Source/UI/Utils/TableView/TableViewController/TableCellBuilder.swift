//
//  TableCellBuilder.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

typealias TableCellCreationFunction = (NSTableView, NSUserInterfaceItemIdentifier) -> AuralTableCellView?

class TableCellBuilder {
    
    static let noCell: TableCellBuilder = .init(cellFactory: {_,_ in nil})
    
    private var text: String? = nil
    private var font: NSFont? = nil
    private var alignment: NSTextAlignment? = nil
    private var bottomYOffset: CGFloat? = nil
    private var centerYOffset: CGFloat? = nil
    private var textColor: NSColor? = nil
    private var selectedTextColor: NSColor? = nil
    
    private var attributedText: NSAttributedString? = nil
    private var selectedAttributedText: NSAttributedString? = nil

    private var image: NSImage? = nil
    private var imageColor: NSColor? = nil
    
    private let cellFactory: TableCellCreationFunction
    
    init() {

        cellFactory = {tableView, columnId in
            tableView.makeView(withIdentifier: columnId, owner: nil) as? AuralTableCellView
        }
    }

    init<T: AuralTableCellView>(ofType type: T.Type) {

        cellFactory = {tableView, columnId in
            tableView.makeView(withIdentifier: columnId, owner: nil) as? T
        }
    }
    
    fileprivate init(cellFactory: @escaping TableCellCreationFunction) {
        self.cellFactory = cellFactory
    }
    
    @discardableResult func withText(text: String, inFont font: NSFont, andColor color: NSColor, selectedTextColor: NSColor, bottomYOffset: CGFloat? = nil, centerYOffset: CGFloat? = nil) -> TableCellBuilder {
        
        self.text = text
        
        self.font = font
        self.bottomYOffset = bottomYOffset
        self.centerYOffset = centerYOffset
        
        self.textColor = color
        self.selectedTextColor = selectedTextColor
        
        return self
    }
    
    @discardableResult func withTextAlignment(_ alignment: NSTextAlignment) -> TableCellBuilder {
        
        self.alignment = alignment
        return self
    }
    
    @discardableResult func withAttributedText(strings: [(text: String, font: NSFont, color: NSColor)], selectedTextColors: [NSColor], bottomYOffset: CGFloat? = nil, centerYOffset: CGFloat? = nil) -> TableCellBuilder {
        
        var attStr: NSMutableAttributedString = strings[0].text.attributed(font: strings[0].font, color: strings[0].color)
        var selAttStr: NSMutableAttributedString = strings[0].text.attributed(font: strings[0].font, color: selectedTextColors[0])
        
        if strings.count > 1 {
            
            for index in 1..<strings.count {
                
                attStr = attStr + strings[index].text.attributed(font: strings[index].font, color: strings[index].color)
                selAttStr = selAttStr + strings[index].text.attributed(font: strings[index].font, color: selectedTextColors[index])
            }
        }

        attStr.addAttribute(.paragraphStyle, value: NSMutableParagraphStyle.byTruncatingTail, range: NSMakeRange(0, attStr.length))
        selAttStr.addAttribute(.paragraphStyle, value: NSMutableParagraphStyle.byTruncatingTail, range: NSMakeRange(0, selAttStr.length))
        
        self.attributedText = attStr
        self.selectedAttributedText = selAttStr
        
        self.bottomYOffset = bottomYOffset
        
        return self
    }
    
    @discardableResult func withImage(image: NSImage, inColor color: NSColor? = nil) -> TableCellBuilder {
        
        self.image = image
        self.imageColor = color
        
        return self
    }
    
    func buildCell(forTableView tableView: NSTableView, forColumnWithId columnId: NSUserInterfaceItemIdentifier, inRow row: Int) -> AuralTableCellView? {

        guard let cell = cellFactory(tableView, columnId) else {return nil}
        
        if let attributedText = self.attributedText, let selectedAttributedText = self.selectedAttributedText {
            
            cell.attributedText = attributedText
            
            cell.unselectedAttributedText = attributedText
            cell.selectedAttributedText = selectedAttributedText
            
        } else if let text = self.text, let selectedTextColor = self.selectedTextColor {
            
            cell.text = text
            cell.textFont = self.font
            cell.textColor = self.textColor
            
            cell.unselectedTextColor = self.textColor
            cell.selectedTextColor = selectedTextColor
        }
        
        if let alignment = self.alignment {
            cell.textField?.alignment = alignment
        }
        
        if let bottomYOffset = self.bottomYOffset {
            cell.realignTextBottom(yOffset: bottomYOffset)
            
        } else if let centerYOffset = self.centerYOffset {
            cell.realignTextCenterY(yOffset: centerYOffset)
        }
        
        cell.textField?.showIf(attributedText != nil || text != nil)
        
        if let image = self.image {
            
            cell.image = image
            
            if let imageColor = self.imageColor {
                cell.imageColor = imageColor
            }
        }
        
        cell.imageView?.showIf(image != nil)
        
        cell.rowSelectionStateFunction = {[weak tableView] in
            tableView?.selectedRowIndexes.contains(row) ?? false
        }
        
        return cell
    }
    
    func buildGenericCell<T: AuralTableCellView>(ofType type: T.Type, forTableView tableView: NSTableView, forColumnWithId columnId: NSUserInterfaceItemIdentifier, inRow row: Int) -> T? {

        guard let cell = tableView.makeView(withIdentifier: columnId, owner: nil) as? T else {return nil}
        
        if let attributedText = self.attributedText, let selectedAttributedText = self.selectedAttributedText {
            
            cell.attributedText = attributedText
            
            cell.unselectedAttributedText = attributedText
            cell.selectedAttributedText = selectedAttributedText
            
        } else if let text = self.text, let selectedTextColor = self.selectedTextColor {
            
            cell.text = text
            cell.textFont = self.font
            cell.textColor = self.textColor
            
            cell.unselectedTextColor = self.textColor
            cell.selectedTextColor = selectedTextColor
        }
        
        if let alignment = self.alignment {
            cell.textField?.alignment = alignment
        }
        
        if let bottomYOffset = self.bottomYOffset {
            cell.realignTextBottom(yOffset: bottomYOffset)
            
        } else if let centerYOffset = self.centerYOffset {
            cell.realignTextCenterY(yOffset: centerYOffset)
        }
        
        cell.textField?.showIf(attributedText != nil || text != nil)
        
        if let image = self.image {
            
            cell.image = image
            
            if let imageColor = self.imageColor {
                cell.imageColor = imageColor
            }
        }
        
        cell.imageView?.showIf(image != nil)
        
        cell.rowSelectionStateFunction = {[weak tableView] in
            tableView?.selectedRowIndexes.contains(row) ?? false
        }
        
        return cell
    }
    
    func buildCell(forOutlineView outlineView: NSOutlineView, forColumnWithId columnId: NSUserInterfaceItemIdentifier, havingItem item: Any) -> AuralTableCellView? {

        guard let cell = cellFactory(outlineView, columnId) else {return nil}
        
        if let attributedText = self.attributedText, let selectedAttributedText = self.selectedAttributedText {
            
            cell.attributedText = attributedText
            
            cell.unselectedAttributedText = attributedText
            cell.selectedAttributedText = selectedAttributedText
            
        } else if let text = self.text, let selectedTextColor = self.selectedTextColor {
            
            cell.text = text
            cell.textFont = self.font
            cell.textColor = self.textColor
            
            cell.unselectedTextColor = self.textColor
            cell.selectedTextColor = selectedTextColor
        }
        
        if let alignment = self.alignment {
            cell.textField?.alignment = alignment
        }
        
        if let bottomYOffset = self.bottomYOffset {
            cell.realignTextBottom(yOffset: bottomYOffset)
            
        } else if let centerYOffset = self.centerYOffset {
            cell.realignTextCenterY(yOffset: centerYOffset)
        }
        
        cell.textField?.showIf(attributedText != nil || text != nil)
        
        if let image = self.image, let imageColor = self.imageColor {
            
            cell.image = image
            cell.imageColor = imageColor
        }
        
        cell.imageView?.showIf(image != nil)
        
        cell.rowSelectionStateFunction = {[weak outlineView] in
            outlineView?.isItemSelected(item) ?? false
        }
        
        return cell
    }
}
