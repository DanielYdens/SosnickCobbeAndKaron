//
//  ViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 6/18/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift
import FirebaseFirestore
import FirebaseAuth

class ViewController: UIViewController {
    
    let leftView = UIImageView(image: #imageLiteral(resourceName: "error"))
    var role : String = ""
    let userDatabase = Firestore.firestore()
    
    
    
    
    @IBOutlet weak var sosnickImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    
    
    @IBAction func loginPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil {
                print(error!)
                self.handleError(error!)
                
            }
            else {
                print("success baby")
                
                //self.performSegue(withIdentifier: "goToNext", sender: self)
                
                
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        do{
//            try Auth.auth().signOut()
//            self.navigationController?.popToRootViewController(animated: true)
//            
//        }
//        catch{
//            print("error: couldnt log out")
//            
//        }
        
        checkIfLoggedIn()
        // Do any additional setup after loading the view.
        // 4- this will add it with the default imageName and edited contextMode
        view.addBackground(imageName: "matt-moore", contentMode: .scaleAspectFill)
        
        sosnickImage.layer.borderWidth = 1.0
        sosnickImage.layer.masksToBounds = false
        sosnickImage.layer.borderColor = UIColor.white.cgColor
        //sosnickImage.layer.cornerRadius = sosnickImage.frame.size.width/2
        sosnickImage.clipsToBounds = true
        
    }
    
    func checkIfLoggedIn(){
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            // ...
            if user != nil{
                self.getUserRole(completion: { (isSuccess, role) in
                    if isSuccess != true{
                        print("we failed")
                    }
                    else{
                        self.storeFCMToken(uid: user!.uid)
                        if role == "Admin"  || role == "Equipment Admin"{
                            let adminVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdminTabBarController") as! UITabBarController
                            self.navigationController?.pushViewController(adminVC, animated: true)
                        }
                        else if role == "Player" {
                            
                            let userVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
                            self.navigationController?.pushViewController(userVC, animated: true)
                            //self.performSegue(withIdentifier: "goToUser", sender: self)
                        }
                        else{
                            print("no role yet")
                        }
                    }
                })
                
            }
            else{
                print("not logged in")
        }
    }
    }
    
    func getUserRole(completion: @escaping (Bool,String)-> Void){
        
        let isSuccess = true
        if let uid = Auth.auth().currentUser?.uid{
            let documentRef = userDatabase.collection("users").document(uid)
            documentRef.getDocument { (snapshot, Error) in
                if Error != nil{
                    print(Error!)
                    return
                }
                else{
                    self.role = snapshot?.get("Role") as! String
                    completion(isSuccess,self.role)
                    
                }
            }
        } else{
            return
        }
        
    }
    
    func storeFCMToken(uid: String){
        userDatabase.collection("users").document(uid).updateData(["fcmToken" : AppDelegate.MyVariables.fcmToken])
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    


}

