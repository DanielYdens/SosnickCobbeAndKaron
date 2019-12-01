//
//  SCKNewsViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 10/21/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit

class SCKNewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var composeButton: UIBarButtonItem!
    
    @IBOutlet weak var ImagesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ImagesTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell") //use correct cell
        self.ImagesTable.dataSource = self
        self.ImagesTable.delegate = self

        // Do any additional setup after loading the view.
    }
    //delegate protocol stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.ImagesTable.dequeueReusableCell(withIdentifier: "feedCell") as! SCKNewsFeedCell
        return cell
    }
    
    
    @IBAction func composeButtonPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "goToMass", sender: self) // when pressed go to mass communication screen
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
