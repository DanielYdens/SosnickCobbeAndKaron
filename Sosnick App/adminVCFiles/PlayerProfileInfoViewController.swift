//
//  PlayerProfileInfoViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 8/28/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class PlayerProfileInfoViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var updateProfileButton: StyleButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var twitterHandleTextField: UITextField!
    @IBOutlet weak var instagramHandleTextField: UITextField!
    @IBOutlet weak var cleatPreferenceSegmentController: UISegmentedControl!
    @IBOutlet weak var apparelTopSizeTextField: UITextField!
    @IBOutlet weak var apparelBottomSizeTextField: UITextField!
    @IBOutlet weak var battingGloveSizeTextField: UITextField!
   // @IBOutlet weak var throwsSegmentController: UISegmentedControl!
    
   // @IBOutlet weak var batsSegmentController: UISegmentedControl!
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    var db = Firestore.firestore()
    var uid : String = ""
    var battingStance : String = ""
    var throwingArm : String = ""
    var cleatPreference : String = ""
    var profilePicURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.scrollView.delegate = self
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 500)
        setupTextFields()
        setupProfilePicture()
        // Do any additional setup after loading the view.
    }
    
    func setupTextFields(){
        let docRef = db.collection("users").document(uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.firstNameTextField.text = document.get("First") as? String
                self.lastNameTextField.text = document.get("last") as? String
                self.dateOfBirthTextField.text = document.get("dateOfBirth") as? String
                self.twitterHandleTextField.text = document.get("twitterHandle") as? String
                self.instagramHandleTextField.text = document.get("instagramHandle") as? String
                self.apparelTopSizeTextField.text = document.get("apparelTopSize") as? String
                self.apparelBottomSizeTextField.text = document.get("apparelBottomSize") as? String
                self.battingGloveSizeTextField.text = document.get("battingGloveSize") as? String
//                self.battingStance = document.get("bats") as? String ?? "Right"
//                self.throwingArm = document.get("throws") as? String ?? "Right"
                self.cleatPreference = document.get("cleatPreference") as? String ?? "Low"
                self.emailTextField.text = document.get("Email") as? String
                self.setupSegmentControllers(cleatPref: self.cleatPreference)
                
            } else {
                print("Document does not exist")
            }
        }
        firstNameTextField.isUserInteractionEnabled = false
        lastNameTextField.isUserInteractionEnabled = false
        dateOfBirthTextField.isUserInteractionEnabled = false
        twitterHandleTextField.isUserInteractionEnabled = false
        instagramHandleTextField.isUserInteractionEnabled = false
        cleatPreferenceSegmentController.isUserInteractionEnabled = false
        apparelBottomSizeTextField.isUserInteractionEnabled = false
        apparelTopSizeTextField.isUserInteractionEnabled = false
        battingGloveSizeTextField.isUserInteractionEnabled = false
        //batsSegmentController.isUserInteractionEnabled = false
        //throwsSegmentController.isUserInteractionEnabled = false
        updateProfileButton.isUserInteractionEnabled = false
        updateProfileButton.isHidden = true
        
    }
    
    func setupSegmentControllers(cleatPref: String){
        if cleatPref == "Low" || cleatPref == ""{
            self.cleatPreferenceSegmentController.selectedSegmentIndex = 0
        }
        else{
            self.cleatPreferenceSegmentController.selectedSegmentIndex = 1
        }
//        if batting == "Right" || batting == ""{
//            self.batsSegmentController.selectedSegmentIndex = 0
//        }
//        else{
//            self.batsSegmentController.selectedSegmentIndex = 1
//        }
//        if throwing == "Right" || throwing == ""{
//            self.throwsSegmentController.selectedSegmentIndex = 0
//        }
//        else{
//            self.throwsSegmentController.selectedSegmentIndex = 1
//        }
        
    }
    func setupProfilePicture(){
        if profilePicURL == ""{
            profilePicture.image =  UIImage(named: "addProfilePicture")
            profilePicture.roundedImage()
        } else{
            profilePicture.downloaded(from: profilePicURL)
            profilePicture.roundedImage()
            
        }
    }
    
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        firstNameTextField.isUserInteractionEnabled = true
        lastNameTextField.isUserInteractionEnabled = true
        dateOfBirthTextField.isUserInteractionEnabled = true
        twitterHandleTextField.isUserInteractionEnabled = true
        instagramHandleTextField.isUserInteractionEnabled = true
        cleatPreferenceSegmentController.isUserInteractionEnabled = true
        apparelTopSizeTextField.isUserInteractionEnabled = true
        apparelBottomSizeTextField.isUserInteractionEnabled = true
        battingGloveSizeTextField.isUserInteractionEnabled = true
        //batsSegmentController.isUserInteractionEnabled = true
        //throwsSegmentController.isUserInteractionEnabled = true
        updateProfileButton.isHidden = false
        updateProfileButton.isUserInteractionEnabled = true
    }
    
    
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        let documentReference = db.collection("users").document(uid)
        documentReference.updateData([
            "First" : firstNameTextField.text!,
            "last" : lastNameTextField.text!,
            "dateOfBirth" : dateOfBirthTextField.text!,
            "twitterHandle" : twitterHandleTextField.text!,
            "instagramHandle" : instagramHandleTextField.text!,
            "apparelTopSize" : apparelTopSizeTextField.text!,
            "apparelBottomSize" : apparelBottomSizeTextField.text!,
            "battingGloveSize" : battingGloveSizeTextField.text!,
            "cleatPreference" : cleatPreference
            //"bats" : battingStance,
            //"throws" : throwingArm
        ] ) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                let refreshAlert = UIAlertController(title: "Success!", message: "Your profile has been updated.", preferredStyle: UIAlertController.Style.alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    
                    
                }))
                self.present(refreshAlert, animated: true, completion: nil)
                self.updateProfileButton.isHidden = true
                self.updateProfileButton.isUserInteractionEnabled = false
                self.setupTextFields()
            }
        }
    }
    
//    @IBAction func batsSegmentChanged(_ sender: UISegmentedControl) {
//        switch batsSegmentController.selectedSegmentIndex
//        {
//        case 0:
//            print("First Segment Selected")
//            battingStance = "Right"
//        case 1:
//            print("Second Segment Selected")
//            battingStance = "Left"
//        default:
//            break
//        }
//    }
    
//    @IBAction func throwingSegmentChanged(_ sender: UISegmentedControl) {
//        switch throwsSegmentController.selectedSegmentIndex
//        {
//        case 0:
//            print("First Segment Selected")
//            throwingArm = "Right"
//        case 1:
//            print("Second Segment Selected")
//            throwingArm = "Left"
//        default:
//            break
//        }
//    }
    
    
    @IBAction func cleatPreferenceChanged(_ sender: UISegmentedControl) {
        
        switch cleatPreferenceSegmentController.selectedSegmentIndex
        {
        case 0:
            print("First Segment Selected")
            cleatPreference = "Low"
        case 1:
            print("Second Segment Selected")
            cleatPreference = "Mid"
        default:
            break
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
