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
    }
}
