//
//  NSEventExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSEvent {
    
    // Computes the direction of a swipe gesture.
    var gestureDirection: GestureDirection? {
        
        // No offset, no direction
        if deltaX == 0 && deltaY == 0 {
            return nil
        }
        
        // Determine absolute offset values along both axes.
        let absX = abs(deltaX), absY = abs(deltaY)
        
        // Check along which axis greater movement occurred.
        if absX > absY {
            
            // This is a horizontal gesture (left/right).
            return deltaX < 0 ? .right : .left
            
        } else {
            
            // This is a vertical gesture (up/down).
            return deltaY < 0 ? .down : .up
        }
    }
    
    // MARK: Media keys handling ------------------------
    
    var isKeyEvent: Bool {subtype.rawValue == 8}

    var keycode: Keycode {Keycode((data1 & 0xffff0000) >> 16)}

    var keyEvent: KeyEvent {
        
        let keyFlags = KeyFlags(data1 & 0x0000ffff)
        let keyPressed = ((keyFlags & 0xff00) >> 8) == 0xa
        let keyRepeat = (keyFlags & 0x1) == 0x1

        return KeyEvent(keycode: keycode, keyFlags: keyFlags, keyPressed: keyPressed, keyRepeat: keyRepeat, timestamp: Date())
    }

    var isMediaKeyEvent: Bool {
        
        let mediaKeys = [NX_KEYTYPE_PLAY, NX_KEYTYPE_PREVIOUS, NX_KEYTYPE_NEXT, NX_KEYTYPE_FAST, NX_KEYTYPE_REWIND]
        return isKeyEvent && mediaKeys.contains(keycode)
    }
}

