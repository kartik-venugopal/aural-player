//
//  PlayQueueSimpleViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueSimpleViewController: PlayQueueViewController {
    
    override var nibName: NSNib.Name? {"PlayQueueSimpleView"}
    
    override var playQueueView: PlayQueueView {
        .simple
    }
    
    override var rowHeight: CGFloat {30}
    
    // MARK: Table view delegate / data source --------------------------------------------------------------------------------------------------------
    
    override func moveTracks(from sourceIndices: IndexSet, to destRow: Int) {
        
        super.moveTracks(from: sourceIndices, to: destRow)
        
        // Tell the other (sibling) tables to refresh
        messenger.publish(.PlayQueue.refresh, payload: [PlayQueueView.expanded, PlayQueueView.tabular])
    }
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = trackList[row], let column = tableColumn?.identifier else {return nil}
        
        switch column {
            
        case .cid_index:
            
            let builder = TableCellBuilder()
            
            if track == playQueueDelegate.currentTrack {
                builder.withImage(image: .imgPlayFilled, inColor: systemColorScheme.activeControlColor)
                
            } else {
                builder.withText(text: "\(row + 1)",
                                        inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                        selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                        bottomYOffset: systemFontScheme.tableYOffset)
            }
            
            return builder.buildCell(forTableView: tableView, forColumnWithId: column, inRow: row)
            
        case .cid_trackName:
            
            let titleAndArtist = track.titleAndArtist
            guard let cell = tableView.makeView(withIdentifier: .cid_trackName, owner: nil) as? AttrCellView else {return nil}
            
            if let artist = titleAndArtist.artist {
                cell.update(artist: artist, title: titleAndArtist.title)
                
            } else {
                cell.update(title: titleAndArtist.title)
            }
            
            cell.realignTextBottom(yOffset: systemFontScheme.tableYOffset)
            
            cell.row = row
            cell.rowSelectionStateFunction = {[weak tableView] in
                tableView?.selectedRowIndexes.contains(row) ?? false
            }
            
            return cell
            
        case .cid_duration:
            
            let builder = TableCellBuilder()
            
            builder.withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                    inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                    selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                    bottomYOffset: systemFontScheme.tableYOffset)
            
            return builder.buildCell(forTableView: tableView, forColumnWithId: column, inRow: row)
            
        default:
            
            return nil
        }
    }
}

class AttrCellView: NSTableCellView {
    
    var row: Int = -1
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    var attrText: NSAttributedString?
    var selectedAttributedText: NSAttributedString?
    
    lazy var textFieldConstraintsManager = LayoutConstraintsManager(for: textField!)
    
    func update(artist: String, title: String) {
        
        let muthu = "\(artist)  ".attributed(font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor) + title.attributed(font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor)
        
        let selMuthu = "\(artist)  ".attributed(font: systemFontScheme.normalFont, color: systemColorScheme.secondarySelectedTextColor) + title.attributed(font: systemFontScheme.normalFont, color: systemColorScheme.primarySelectedTextColor)
        
        muthu.addAttribute(.paragraphStyle, value: NSMutableParagraphStyle.byTruncatingTail, range: NSMakeRange(0, muthu.length))
        
        self.attributedText = muthu
        self.attrText = muthu
        self.selectedAttributedText = selMuthu
    }
    
    func update(title: String) {
        
        let muthu = title.attributed(font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor)
        let selMuthu = title.attributed(font: systemFontScheme.normalFont, color: systemColorScheme.primarySelectedTextColor)
        
        muthu.addAttribute(.paragraphStyle, value: NSMutableParagraphStyle.byTruncatingTail, range: NSMakeRange(0, muthu.length))
        
        self.attributedText = muthu
        self.attrText = muthu
        self.selectedAttributedText = selMuthu
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            self.attributedText = rowIsSelected ? self.selectedAttributedText : self.attrText
        }
    }
    
    // Constraints
    func realignTextBottom(yOffset: CGFloat) {
        
        textFieldConstraintsManager.removeAll(withAttributes: [.bottom])
        textFieldConstraintsManager.setBottom(relatedToBottomOf: self, offset: yOffset)
    }
}
