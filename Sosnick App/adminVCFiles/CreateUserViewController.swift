//
//  CreateUserViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 7/21/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift
import FirebaseFirestore
import FirebaseAuth

class CreateUserViewController: UIViewController {

    var uid : String = ""
    var leftView = UIImageView(image: #imageLiteral(resourceName: "error"))
    var database =  Firestore.firestore().collection("users")
    var role : String = "Player"
    
    @IBOutlet weak var firstTextField: UITextField!
    
    @IBOutlet weak var registerButton: StyleButton!
    
    @IBOutlet weak var lastTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch roleSegmentedControl.selectedSegmentIndex
        { //set role to whatever segment the admin selects
        case 0:
           // print("First Segment Selected")
            role = "Player"
        case 1:
          //  print("Second Segment Selected")
            role = "Admin"
        case 2:
          //  print("third segment selected")
            role = "Equipment Admin"
        default:
            break
        }
    }
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        var repeated = false
        database.getDocuments { (snapshot, error) in // go into the user database
            if error != nil{
                if let Error = error{
                    self.handleError(Error)
                }
                return
            }
            else{
                for document in snapshot!.documents{ //if there is already an user email for that user then show an alert
                    if self.emailTextField.text == document.get("Email") as? String {
                        let repeatAlert = UIAlertController(title: "You already have this Email registered to an account!", message: "Please enter a different email.", preferredStyle: UIAlertController.Style.alert)
                        
                        repeatAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                         //   print("Handle Ok logic here")
                            self.clearTextFields() // clear text fields
                            repeated = true // admin added a repeat user
                        }))
                        self.present(repeatAlert, animated: true,completion: nil) //present the alert
                        
                        
                    }
                }
            }
        }
        if repeated == false { //if not a repeat
            if let secondaryApp = FirebaseApp.app(name: "CreatingUsersApp") {
                let secondaryAppAuth = Auth.auth(app: secondaryApp)
                
                // Create user in secondary app.
                secondaryAppAuth.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in //creating the user without having them sign in
                    if error != nil {
                       // print(error!)
                    } else {
                        //Print created users email.
                       // print(user!.user.email!)
                        self.uid = user!.user.uid
                        //Print current logged in users email.
                       // print(Auth.auth().currentUser?.email ?? "default")
                        
                        try! secondaryAppAuth.signOut() //sign them out autimatically
                        self.createUserInformation()
                        
                        let refreshAlert = UIAlertController(title: "Success!", message: "A new user has been created!", preferredStyle: UIAlertController.Style.alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                            print("Handle Ok logic here")
                        
                        }))
                        self.present(refreshAlert, animated: true,completion: nil)
                        self.clearTextFields() //show alert telling them that it succeeded and clear the fields
                    }
                }
            }
        }
    }
    
    func setupFonts() {
        guard let customFont = UIFont(name: "ErasITC-Medium", size: UIFont.labelFontSize + 5) else {
                   fatalError("""
                       Failed to load the "CustomFont-Light" font.
                       Make sure the font file is included in the project and the font name is spelled correctly.
                       """
                   )
        }
        firstTextField.font = customFont
        lastTextField.font = customFont
        passwordTextField.font = customFont
        emailTextField.font = customFont
        

    }
    
    func createUserInformation(){
        database.document(uid).setData([//create all the initial user informationa and update it in the user DB
            "First" : firstTextField.text!,
            "last" : lastTextField.text!,
            "profilePictureURL" : "",
            "Email": emailTextField.text!.lowercased(),
            "Role" : role,
            "instagramHandle" : "",
            "twitterHandle" : "",
            "dateOfBirth" : "",
            "cleatPreference" : "Low",
            "apparelTopSize" : "",
            "apparelBottomSize" : "",
            "battingGloveSize" : "",
            "fcmToken" : ""
            
            ])
    }
        
        
//        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
//            if error != nil{
//                print(error!)
//                let banner = NotificationBanner(title: "Error!", subtitle: "Please enter a valid email and password.", leftView: self.leftView, style: .danger)
//                banner.show()
//            }
//            else{
//                print("registration successfull!")
//                self.leftView = UIImageView(image: #imageLiteral(resourceName: "greenCheck"))
//                let banner2 = NotificationBanner(title: "Error!", subtitle: "Success! New User has been added!", leftView: self.leftView, style: .success)
//                banner2.show()
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isConnectedToInternet(){
            registerButton.isUserInteractionEnabled = true //make sure user is connected to internet
        }
        else{
            let alert = UIAlertController(title: "Error", message: "No network connection, please try again", preferredStyle: .alert) //if no network
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(okAction)
            
            registerButton.isUserInteractionEnabled = false
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFonts()
        backgroundImage.image = UIImage(named: "apexLogo")
        self.title = "Register New Users"
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }
    
    func clearTextFields(){
        firstTextField.text = ""
        lastTextField.text = ""
        emailTextField.text = "" //sets all text fields to blank
        passwordTextField.text = ""
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
