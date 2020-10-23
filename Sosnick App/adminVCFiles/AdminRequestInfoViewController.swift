//
//  AdminRequestInfoViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 7/16/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import NotificationBannerSwift

class AdminRequestInfoViewController: UIViewController, UINavigationBarDelegate {

    
    @IBAction func completeButtonPressed(_ sender: UIButton) {
        
        if currentRequestState == "adminConfirmed" {
            let refreshAlert = UIAlertController(title: "Are You sure?", message: "This will mark this request as completed", preferredStyle: UIAlertController.Style.alert) //presents a popup asking if they want to admin complete the request
            
            refreshAlert.addAction(UIAlertAction(title: "Yes, I'm sure", style: .default, handler: { (action: UIAlertAction!) in //if they click yes im sure
               // print("Handle Ok logic here")
                let documentRef = self.database.collection("userRequestC").document(self.documentID)
                //go into user request database
                
                documentRef.updateData([
                    "isProcessed" : true //update the status to admin confirmed
                ]) { err in
                    if err != nil { //if there is an error print it
                      //  print("Error updating document: \(err)")
                        print(err!)
                    } else {
                       // print("Document successfully updated")
                        let banner = GrowingNotificationBanner(title: "Success!", subtitle: "The status of the request has been changed to complete", leftView: self.leftView, style: .success) //show a success notification
                        banner.show()
                        
                        _ = self.navigationController?.popViewController(animated: true)//pop the view controller
                        
                    }
                    
                }
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
               // print("Handle Cancel Logic here") //if they click cancel do nothing
            }))
            
            present(refreshAlert, animated: true, completion: nil) //show popup
        }
        else{
            let refreshAlert = UIAlertController(title: "Are You sure?", message: "This will mark this request as pending", preferredStyle: UIAlertController.Style.alert) //presents a popup asking if they want to admin complete the request
            
            refreshAlert.addAction(UIAlertAction(title: "Yes, I'm sure", style: .default, handler: { (action: UIAlertAction!) in //if they click yes im sure
               // print("Handle Ok logic here")
                let documentRef = self.database.collection("userRequestC").document(self.documentID)
                //go into user request database
                
                documentRef.updateData([
                    "status" : "adminConfirmed" //update the status to admin confirmed
                ]) { err in
                    if err != nil { //if there is an error print it
                      //  print("Error updating document: \(err)")
                        print(err)
                    } else {
                       // print("Document successfully updated")
                        let banner = GrowingNotificationBanner(title: "Success!", subtitle: "The status of the request has been changed to pending", leftView: self.leftView, style: .success) //show a success notification
                        banner.show()
                        
                        _ = self.navigationController?.popViewController(animated: true)//pop the view controller
                        
                    }
                    
                }
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
               // print("Handle Cancel Logic here") //if they click cancel do nothing
            }))
            
            present(refreshAlert, animated: true, completion: nil) //show popup
        }
      
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true) //if they click back pop view controller
    }
    
    @IBAction func goToMessagesClicked(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "goToMessages", sender: self) //if they click chat go to messages VC
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMessages"{
            let nextVC = segue.destination as! UserMessagesViewController
            nextVC.role = "Admin"
            nextVC.messagesCreatedStatus = messageStatus
            nextVC.documentID = documentID
            
        }
    }
       
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var confirmCompleteButton: StyleButton!
    
    @IBOutlet weak var userLabel: UITextField!
   
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var categoryLabel: UITextField!
    @IBOutlet weak var dateLabel: UITextField!
    @IBOutlet weak var chatButton: UIBarButtonItem!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var currentRequestState : String = ""
    var adminCategory : String  = ""
    var adminDescription : String = ""
    var adminDate : String = ""
    var userEmail : String = ""
    var documentID : String = ""
    let database = Firestore.firestore()
    let leftView = UIImageView(image: #imageLiteral(resourceName: "greenCheck"))
    var messageStatus : Bool = false
    var requestStatus : String  = ""

    override func viewWillAppear(_ animated: Bool) {
        if currentRequestState == "adminConfirmed" {
            confirmCompleteButton.setTitle("Complete", for: .normal)
        }
        else{
            confirmCompleteButton.setTitle("Confirm", for: .normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fontSetup()
        backgroundImage.image = UIImage(named:"apexLogo")
        updateStatusIfNeeded() //if admin hasnt viewed request yet update status
        fillInformation() //fill information of request into correct spot
        setUnedittable() //make the fields unedditable
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        descriptionTextView.layer.borderWidth = 0.5 //ascetic adjustments
        descriptionTextView.clipsToBounds = true
        self.hideKeyboardWhenTappedAround() //hide key board if taps anywhere
    }
    
    func fontSetup()  {
        backButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "ErasITC-Medium", size: 15)!], for: UIControl.State.normal)
        chatButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "ErasITC-Medium", size: 15)!], for: UIControl.State.normal)
    }
    
    func fillInformation(){
        userLabel.text = userEmail
        categoryLabel.text = adminCategory //filling all the information of the request into the correct position on screen
        dateLabel.text = adminDate
        descriptionTextView.text = adminDescription
    }
    
    func setUnedittable(){
        userLabel.isUserInteractionEnabled = false
        categoryLabel.isUserInteractionEnabled = false // all of it cannot be editted
        dateLabel.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
    }
    
    func updateStatusIfNeeded(){
        if requestStatus == "userSubmitted"{ //if the admin hasnt opened the request yet
            database.collection("userRequestC").document(documentID).updateData(["status" : "adminReceived"]) //update the status to show that admin has viewed it
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
