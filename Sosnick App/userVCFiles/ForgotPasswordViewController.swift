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
        
        directionsLabel.numberOfLines = 0 //text wrap
        // Do any additional setup after loading the view.
    }
    


    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func sendEmailButtonPressed(_ sender: UIButton) {
        
        _ = Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (Error) in
            if Error != nil{ //send password reset email to certain email
                if let error = Error{
                    self.handleError(error)
                }
                print("error happend")
            }
            else{
                print("email sent successfully")
                let refreshAlert = UIAlertController(title: "Email has been sent successfully!", message: "Please check that you have received it in order to reset your password.", preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    print("yay")
                }))
                self.present(refreshAlert, animated: true, completion: nil) //show an alert telling them that the email has been sent
                
                    
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
