//
//  UIViewControllerExtensions.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 24/09/22.
//

import UIKit

extension UIViewController {
    
    func presentPrompt(withTitle title: String, message: String, placeholderText: String? = nil, saveHandler: @escaping (String) -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = placeholderText
        }

        // add the buttons/actions to the view controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in

            let inputName = alertController.textFields![0].text
            saveHandler(inputName ?? "")
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        present(alertController, animated: true, completion: nil)
    }
}
