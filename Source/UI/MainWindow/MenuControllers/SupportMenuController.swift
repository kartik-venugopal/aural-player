//
//  SupportMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Provides actions for the Help menu
 */
class SupportMenuController: NSObject {
    
    private lazy var updatesDialog: UpdatesDialogController = UpdatesDialogController()
    
    private lazy var workspace: NSWorkspace = NSWorkspace.shared
    
    private let httpClient: HTTPClient = .shared
    private let supportURL: URL = URL(string: "https://github.com/maculateConception/aural-player/wiki")!
    private let latestReleaseURL: URL = URL(string: "https://github.com/maculateConception/aural-player/releases/latest")!
    
    // Opens the online (Wiki) support documentation
    @IBAction func onlineSupportAction(_ sender: Any) {
        workspace.open(supportURL)
    }
    
    @IBAction func checkForUpdatesAction(_ sender: Any) {
        
        updatesDialog.showWindow(self)
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            do {
                
                guard let redirectURL = try self.httpClient.performGETForRedirect(toURL: self.latestReleaseURL),
                      redirectURL.path.contains("releases/tag/"),
                      let myAppVersion = AppVersion(versionString: NSApp.appVersion),
                      let latestAppVersion = AppVersion(versionString: redirectURL.lastPathComponent) else {
                    
                    self.handleError()
                    return
                }
                
                DispatchQueue.main.async {
                    
                    if myAppVersion < latestAppVersion {
                        self.updatesDialog.updateIsAvailable(version: latestAppVersion)
                    } else {
                        self.updatesDialog.noUpdatesAvailable()
                    }
                }
                
            } catch {
                self.handleError()
            }
        }
    }
    
    private func handleError() {
        
        DispatchQueue.main.async {
            self.updatesDialog.showError()
        }
    }
}

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
        
        if lhs.patchVersion < rhs.patchVersion {return true}
        else if lhs.patchVersion > rhs.patchVersion {return false}
        
        // They are exactly equal.
        return false
    }
}
