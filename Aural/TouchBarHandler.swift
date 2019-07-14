//
//  TouchBarHandler.swift
//  Aural
//
//  Created by Wald Schlafer on 7/14/19.
//  Copyright © 2019 Anonymous. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
class TouchBarHandler: NSObject, NSTouchBarDelegate {
    
    func makeTouchBar() -> NSTouchBar? {
        
        print("MUTHU !!!")
        
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        // 2
        touchBar.customizationIdentifier = "myTB"
        // 3
        touchBar.defaultItemIdentifiers = [makeID("Info"), makeID("RateAdjustment"), makeID("Decrease")]
        // 4
        touchBar.customizationAllowedItemIdentifiers = [NSTouchBarItem.Identifier(rawValue: "Rate"), NSTouchBarItem.Identifier(rawValue: "Add"), NSTouchBarItem.Identifier(rawValue: "Remove")]
        
        return touchBar
    }
    
    private func makePlayerTouchBar() -> NSTouchBar {
        
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        // 2
        touchBar.customizationIdentifier = "myTB-Player"
        // 3
        touchBar.defaultItemIdentifiers = [makeID("Info"), makeID("Bookmark"), makeID("Favorite")]
        // 4
        touchBar.customizationAllowedItemIdentifiers = [NSTouchBarItem.Identifier(rawValue: "Rate"), NSTouchBarItem.Identifier(rawValue: "Add"), NSTouchBarItem.Identifier(rawValue: "Remove")]
        
        return touchBar
    }
    
    private func makeID(_ str: String) -> NSTouchBarItem.Identifier {
        return NSTouchBarItem.Identifier(rawValue: str)
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        
        switch identifier.rawValue {
            
        case "Player":
            
            let plItem = NSPopoverTouchBarItem(identifier: identifier)
            plItem.collapsedRepresentationLabel = "Player"
            plItem.showsCloseButton = true
            plItem.popoverTouchBar = makePlayerTouchBar()
            return plItem
            
        case "Info":
            
            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
            //            let muthu = NSTouchBar
            customViewItem.view = NSButton(title: "", image: NSImage(named: "MoreInfo")!, target: self, action: #selector(addAction(_:)))
            return customViewItem
//
//        case "Increase":
//
//            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
//            //            customViewItem.view = NSButton(title: "Mute", target: self, action: #selector(muteAction(_:)))
//            customViewItem.view = NSButton(title: "Add", image: addButton.image!, target: addButton.target, action: addButton.action)
//            return customViewItem
//
//        case "Decrease":
//
//            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
//            //            customViewItem.view = NSButton(title: "Mute", target: self, action: #selector(muteAction(_:)))
//            customViewItem.view = removeButton
//            return customViewItem
            
        case "RateAdjustment":

            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
                        customViewItem.view = NSTextField(labelWithString: " Rate ")
//            customViewItem.view = slider ?? NSTextField(labelWithString: " Rate ")
            return customViewItem

        default: return nil
            
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        print("Added !!!")
    }
    
    @IBAction func removeAction(_ sender: Any) {
        print("Removed !!!")
    }
}
