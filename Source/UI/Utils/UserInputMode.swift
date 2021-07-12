//
//  UserInputMode.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

// A user input mode that determines how the user provided a certain input, which in turn
// determines how the corresponding command should be executed by the app.
// Certain functions, such as player seeking, use this mode.
enum UserInputMode {

    // A discrete input is one that occurs as a single separate event.
    // eg. when a user clicks a menu item.
    case discrete
    
    // A continuous input is one that occurs as part of a continuous sequence of similar events.
    // eg. when a user scrolls using a mouse or trackpad.
    // Many such events are generated one after the other.
    case continuous
}
