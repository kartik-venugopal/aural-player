//
//  SupportMenuController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
    
    private lazy var workspace: NSWorkspace = .shared
    
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
