//
//  NSApplicationExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

extension NSApplication {
    
    ///
    /// The version number of this application (used in a request header for all requests sent to MusicBrainz). Used to idenfity this app to MusicBrainz.
    ///
    var appVersion: String {Bundle.main.infoDictionary?["CFBundleShortVersionString", String.self] ?? "3.0.0"}
}
