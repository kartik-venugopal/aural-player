//
//  MainViewController.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 06/01/22.
//

import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let appTitleView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        appTitleView.image = PlatformImage(named: "AppTitle")!
        
        navigationItem.titleView = appTitleView
        
//        navigationController?.pushViewController(, animated: )
    }
    
    @IBAction func showEQAction(_ sender: Any) {
        presentViewController(withIdentifier: "EffectsTabBarController", inStoryboard: "Effects")
    }
    
    private func presentViewController(withIdentifier id: String, inStoryboard storyboardName: String) {
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        // Instantiate the view controller with the given storyboard identifier.
        let auxiliaryViewController: PlatformViewController = storyboard.instantiateViewController(identifier: id)
            
        // Present the view controller (push it onto the existing navigation stack).
        navigationController?.pushViewController(auxiliaryViewController, animated: true)
    }
}
