//
//  AlertWindowController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class AlertWindowController: SingletonWindowController, ModalComponentProtocol {
    
    override var windowNibName: String? {"Alerts"}
    
    @IBOutlet weak var icon: NSImageView!
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var lblInfo: NSTextField!
    
    @IBOutlet weak var btnOK: NSButton!
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    func showAlert(_ alertType: AlertType, _ title: String, _ message: String, _ info: String) {
        
        if !self.isWindowLoaded {
            _ = theWindow
        }
        
        switch alertType {
            
        case .error:    icon.image = Images.imgError
            
        case .warning:  icon.image = Images.imgWarning

        default:    icon.image = Images.imgWarning
            
        }
        
        lblTitle.stringValue = title
        lblMessage.stringValue = message
        lblInfo.stringValue = info
        
        theWindow.showCenteredOnScreen()
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        theWindow.close()
    }
}

enum AlertType {
    
    case error
    case warning
    case info
}
