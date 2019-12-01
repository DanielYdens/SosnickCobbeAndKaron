//
//  PopoverViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 9/3/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class PopoverViewController: UIViewController {
    // NOT CURRENTLY BEING USED IN APP
    @IBOutlet weak var deleteButton: UIButton!
    
    var postID : String = ""
    var delegate : PopoverViewControllerDelegate?
    let database = Firestore.firestore()
    let storage = Storage.storage()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.gray.cgColor
        
        // Do any additional setup after loading the view.
    }
    
 
  

    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        database.collection("posts").document(postID).delete { (err) in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        let storageRef = storage.reference().child("NewsPosts").child("\(postID).png")
        storageRef.delete { (err) in
            if let err = err {
                print("Error removing storage: \(err)")
            } else {
                print("storage successfully removed!")
            }
        }
       NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        self.dismiss(animated: true, completion: nil)
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

protocol PopoverViewControllerDelegate {
    func passData(VC : PopoverViewController)
}
