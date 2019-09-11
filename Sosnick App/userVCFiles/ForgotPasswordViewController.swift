//
//  ForgotPasswordViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 8/8/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Forgot Password?"
        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func sendEmailButtonPressed(_ sender: UIButton) {
        
        _ = Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (Error) in
            if Error != nil{
                print(Error!)
                print("error happend")
            }
            else{
                print("email sent successfully")
                let refreshAlert = UIAlertController(title: "Email has been sent successfully!", message: "Please check that you have received it in order to reset your password.", preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    print("yay")
                }))
                self.present(refreshAlert, animated: true, completion: nil)
                
                    
            }
        }
        
        
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
