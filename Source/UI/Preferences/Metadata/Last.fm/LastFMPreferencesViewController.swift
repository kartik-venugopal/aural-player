//
//  LastFMPreferencesViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class LastFMPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    override var nibName: NSNib.Name? {"LastFMPreferences"}
    
    @IBOutlet weak var btnEnableScrobbling: CheckBox!
    @IBOutlet weak var btnEnableLoveUnlove: CheckBox!
    
    @IBOutlet weak var lblAuthInstructions1: NSTextField!
    @IBOutlet weak var lblAuthInstructions2: NSTextField!
    
    @IBOutlet weak var imgAuthStatus: NSImageView!
    @IBOutlet weak var lblAuthStatus: NSTextField!
    
    @IBOutlet weak var btnReauthenticate: NSButton!
    @IBOutlet weak var btnGrantPermission: NSButton!
    @IBOutlet weak var btnGetSessionKey: NSButton!
    
    @IBOutlet weak var sessionKeyActivitySpinner: NSProgressIndicator!
    
    private var lastFMToken: LastFMToken? = nil
    
    private var lastFMPrefs: LastFMPreferences {
        preferences.metadataPreferences.lastFM
    }
    
    var preferencesView: NSView {
        view
    }
    
    func resetFields() {
        
        btnEnableScrobbling.onIf(lastFMPrefs.enableScrobbling)
        btnEnableLoveUnlove.onIf(lastFMPrefs.enableLoveUnlove)
        
        if lastFMPrefs.sessionKey == nil {
            showLastFMAuthFields()
            
        } else {
            hideLastFMAuthFields()
        }
        
        self.lastFMToken = nil
    }
    
    private func showLastFMAuthFields() {
        
        lblAuthInstructions1.show()
        lblAuthInstructions2.show()
        
        imgAuthStatus.image = .imgError
        imgAuthStatus.contentTintColor = .red
        lblAuthStatus.stringValue = "(Not Authenticated)"
        btnReauthenticate.hide()
        
        btnGrantPermission.show()
        
        btnGetSessionKey.disable()
        btnGetSessionKey.show()
    }
    
    private func hideLastFMAuthFields() {
        
        sessionKeyActivitySpinner.dismiss()
        
        lblAuthInstructions1.hide()
        lblAuthInstructions2.hide()
        
        imgAuthStatus.image = .imgCheck
        imgAuthStatus.contentTintColor = .green
        lblAuthStatus.stringValue = "(Authenticated)"
        btnReauthenticate.show()
        
        btnGrantPermission.hide()
        btnGetSessionKey.hide()
    }
    
    @IBAction func reauthenticateAction(_ sender: Any) {
        
        // Reset token
        self.lastFMToken = nil
        
        // Reset session key
        lastFMPrefs.sessionKey = nil
        
        // Allow the user to re-authenticate.
        showLastFMAuthFields()
    }
    
    @IBAction func grantPermissionAction(_ sender: Any) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            do {
                
                let token = try lastFMClient.getToken()
                
                self.lastFMToken = token
                try lastFMClient.requestUserAuthorization(withToken: token)
                
                DispatchQueue.main.async {
                    self.btnGetSessionKey.enable()
                }
                
            } catch let httpError as HTTPError {
                
                NSLog("Failed to get Last.fm API token. HTTP Error: \(httpError.code)")
                self.showAlert("Failed to get Last.fm API token", "HTTP Error \(httpError.code)", "\(httpError.description)")
                
            } catch {
                
                NSLog("Failed to get Last.fm API token. Error: \(error.localizedDescription)")
                self.showAlert("Failed to get Last.fm API token", "Error", "\(error.localizedDescription)")
            }
        }
    }
    
    private func showAlert(_ title: String, _ message: String, _ info: String) {
        
        DispatchQueue.main.async {
            _ = DialogsAndAlerts.genericErrorAlert(title, message, info).showModal()
        }
    }
    
    @IBAction func getSessionKeyAction(_ sender: Any) {
        
        sessionKeyActivitySpinner.animate()

        DispatchQueue.global(qos: .userInteractive).async {
            
            do {
                
                guard let token = self.lastFMToken else {return}
                
                let session = try lastFMClient.getSession(forToken: token)
                
                self.lastFMPrefs.sessionKey = session.key
                
                DispatchQueue.main.async {
                    self.hideLastFMAuthFields()
                }
                
            } catch let httpError as HTTPError {
                
                NSLog("Failed to get Last.fm API session key. HTTP Error: \(httpError.code)")
                self.showAlert("Failed to get Last.fm API session key.", "HTTP Error \(httpError.code)", "\(httpError.description)")
                
            } catch {
                
                NSLog("Failed to get Last.fm API session key. Error: \(error.localizedDescription)")
                self.showAlert("Failed to get Last.fm API session key.", "Error", "\(error.localizedDescription)")
            }
        }
    }
    
    func save() throws {
        
        let lastFMPrefs = preferences.metadataPreferences.lastFM
        
        lastFMPrefs.enableScrobbling = btnEnableScrobbling.isOn
        lastFMPrefs.enableLoveUnlove = btnEnableLoveUnlove.isOn
        
        self.lastFMToken = nil
    }
}
