//
//  AppModeController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A contract for a controller that is responsible for presenting / dismissing a
/// particular application user interface mode.
///
protocol AppModeController {
    
    var mode: AppMode {get}
    
    func presentMode(transitioningFromMode previousMode: AppMode?)
    
    func dismissMode()
}
