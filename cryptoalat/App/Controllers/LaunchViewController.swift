//
//  ViewController.swift
//  cryptoalat
//
//  Created by Neo Ighodaro on 22/06/2018.
//  Copyright © 2018 TapSharp Interactive. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SettingsService.shared.loadSettings {
            self.routeToMainController()
        }
    }

    fileprivate func routeToMainController() {
        performSegue(withIdentifier: "Main", sender: self)
    }
    
}

