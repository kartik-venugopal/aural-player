//
//  StringInputReceiver.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

// A callback interface that allows StringInputPopover to communicate with its clients (i.e. any UI views that use StringInputPopover to receive string input from the user) in a generic loosely-coupled way.
protocol StringInputReceiver {
    
    // Asks the client to validate the given string input. Returns true if the input string is valid, false otherwise. Optional errorMsg return value describes the validation error if there is one.
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?)
    
    // Tells the client to accept the given (validated) string received from the user
    func acceptInput(_ string: String)
    
    // Returns a message that is used when prompting the user for string input, describing the information being requested. e.g. "Please enter the preset name:"
    var inputPrompt: String {get}
    
    // Returns an appropriate (optional) default value for the information being requested. e.g. "New preset"
    var defaultValue: String? {get}
}
