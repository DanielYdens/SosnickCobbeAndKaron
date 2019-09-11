//
//  AdminTabBarControllerViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 8/16/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit

class AdminTabBarControllerViewController: UITabBarController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
