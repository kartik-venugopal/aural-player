//
//  AppVersion.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Abstraction for an application version with logic for comparison to another app version.
///
struct AppVersion: Comparable {
    
    let versionString: String
    
    let majorVersion: Int
    let minorVersion: Int
    let patchVersion: Int
    
    init?(versionString: String) {
        
        let components = versionString.split(separator: ".")
        guard components.count == 3 else {return nil}
        
        // Ensure that the version string only contains numbers.
        let numbers: [Int] = components.compactMap {Int($0)}
        guard numbers.count == 3 else {return nil}
        
        self.versionString = versionString
     
        majorVersion = numbers[0]
        minorVersion = numbers[1]
        patchVersion = numbers[2]
    }
    
    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        
        if lhs.majorVersion < rhs.majorVersion {return true}
        else if lhs.majorVersion > rhs.majorVersion {return false}
        
        if lhs.minorVersion < rhs.minorVersion {return true}
        else if lhs.minorVersion > rhs.minorVersion {return false}
        
        return lhs.patchVersion < rhs.patchVersion
    }
}
