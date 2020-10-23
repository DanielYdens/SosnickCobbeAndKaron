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
    
    
    
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: StyleButton!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "forgotPass", sender: self)
//        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController //if user pressed forgot password button then they are taken to the forgotpassword flow
//        self.navigationController?.pushViewController(loginVC, animated: true)
        
    }
    

    
   
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil {
                //print(error!) //signing in the user
                self.handleError(error!)
                
            }
            else {
               // print("success baby")
                
                //self.performSegue(withIdentifier: "goToNext", sender: self)
                
                
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.overrideUserInterfaceStyle = .light
        imageView.image = UIImage(named: "apexWhite")
        UIView.animate(withDuration: 1) {
            self.imageView.frame.origin.y -= 500 //animate log in screen elements
            self.emailTextField.frame.size.height -= 50
            self.passwordTextField.frame.size.height -= 50
            self.loginButton.frame.size.height -= 50
            
        }
        setupTextFields()
        setupImageView()
        
        checkIfLoggedIn()
        
        //listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
    }
    
    deinit { //stop listening to hide/show events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification){
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height/2
            self.imageView.isHidden = true
            
            
        }
        else{
            view.frame.origin.y = 0
            imageView.isHidden = false
        }
        
       }
    func setupImageView(){
        
        imageView.backgroundColor = .clear
        imageView.isOpaque = false
        imageView.contentMode = .scaleAspectFit
    }
    
    func setupTextFields(){
        emailTextField.textColor = .white
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        emailTextField.backgroundColor = .darkGray
        emailTextField.addLine(position: .LINE_POSITION_BOTTOM, color: .white, width: 0.75)
        passwordTextField.textColor = .white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passwordTextField.backgroundColor = .darkGray
        passwordTextField.addLine(position: .LINE_POSITION_BOTTOM, color: .white, width: 0.75)
    }
    
    func checkIfLoggedIn(){
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            // ...
            if user != nil{ //if there is a user logged in already
                self.getUserRole(completion: { (isSuccess, role) in
                    if isSuccess != true{
                       // print("we failed") //fail
                    }
                    else{
                        self.storeFCMToken(uid: user!.uid) //else store token
                        if role == "Admin"  || role == "Equipment Admin"{ //check role
                            let adminVC = UIStoryboard(name: "Main", bundle:  nil).instantiateViewController(withIdentifier: "AdminTabBarController") as! UITabBarController
                            self.navigationController?.pushViewController(adminVC, animated: true)
                        } //take to specific flow based off of their role
                        else if role == "Player" {
                            
                            let userVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
                            self.navigationController?.pushViewController(userVC, animated: true)
                            //self.performSegue(withIdentifier: "goToUser", sender: self)
                        }
                        else{
                           // print("no role yet") //in the case of no role
                        }
                    }
                })
                
            }
            else{
               // print("not logged in") //  no user logged in
        }
    }
    }
    
    func getUserRole(completion: @escaping (Bool,String)-> Void){
        
        let isSuccess = true
        if let uid = Auth.auth().currentUser?.uid{ //uid is now the logged in users uid
            let documentRef = userDatabase.collection("users").document(uid)
            documentRef.getDocument { (snapshot, Error) in
                if Error != nil{
                   // print(Error!)
                    return
                }
                else{
                    self.role = snapshot?.get("Role") as! String //getting role
                    completion(isSuccess,self.role) //completion handler so you can now finish the check if logged in function
                    
                }
            }
        } else{
            return
        }
        
    }
    
    func storeFCMToken(uid: String){
        userDatabase.collection("users").document(uid).updateData(["fcmToken" : AppDelegate.MyVariables.fcmToken]) //storing the users fcmtoken for push notifications
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event) //if anywhere is touched the keyboard goes away
    }
    
    


}

