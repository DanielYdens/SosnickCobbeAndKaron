//
//  InfoViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 7/11/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import FirebaseFirestore
import NotificationBannerSwift

class InfoViewController: UIViewController {
    
    

    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true) //if back button pressed pop
    }
    
    @IBAction func chatButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToUserMessages", sender: self) //if chat button pressed go to chat
    }
    
//    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) { //allow for edits of text fields
//        categoryTextField.isUserInteractionEnabled = true
//        descriptionTextView.isUserInteractionEnabled = true
//        submitButton.isHidden = false
//        submitButton.isUserInteractionEnabled = true
//
//    }
    

    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.isNavigationBarHidden = false
        fillDataAndInitialize()

        self.title = "Request Information"
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    let leftView = UIImageView(image: #imageLiteral(resourceName: "greenCheck"))
    var reqCategory : String = ""
    var reqDescription : String = ""
    var reqDate : String = ""
    let db = Firestore.firestore()
    var reqNum = 0
    var docID = ""
    var isMessagesCreated : Bool = false
    
    func fillDataAndInitialize(){ //fills in different text views with request data and set
        self.navigationController?.navigationBar.isHidden=false
        //submitButton.isHidden = true
        //submitButton.isUserInteractionEnabled = false
        categoryTextField.text = reqCategory
        categoryTextField.isUserInteractionEnabled = false
        descriptionTextView.text = reqDescription
        descriptionTextView.isUserInteractionEnabled = false
        dateTextField.text = reqDate
        dateTextField.isUserInteractionEnabled = false
    }
    @IBAction func  completePressed(_ sender: UIButton) {
        let documentRef = db.collection("userRequestC").document(docID)
        
        
        documentRef.updateData([
            "isProcessed" : true
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated") //success
                let banner = GrowingNotificationBanner(title: "Success!", subtitle: "Your request has been updated and will be processed as soon as possible.", leftView: self.leftView, style: .success)
                banner.show()
                _ = self.navigationController?.popViewController(animated: true)
                
            }
        }
        

    }
    
    @IBAction func CancelButtonPressed(_ sender: UIBarButtonItem) { //cancel button pressed
        let cancelAlert = UIAlertController(title: "Are You sure?", message: "This will permanently delete this request.", preferredStyle: UIAlertController.Style.alert)
        
        cancelAlert.addAction(UIAlertAction(title: "Yes, I'm sure", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here") //alert asking if the user is sure, if yes delete
//            self.addToDeleted()
            self.deleteItems()
            
        }))
        
        cancelAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here") //do nothing if cancel
        }))
        
        present(cancelAlert, animated: true, completion: nil) //present cancel alert
        
        
        
    }
    
    func deleteItems(){ //go into request database and delete correct document
        db.collection("userRequestC").document(docID).delete { (Error) in
            if let Error = Error{
                print("Error removing document: \(Error)")
            }
            else{
                print("document was removed") //success and pop
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
        
//        db.collection("userMessageA").document(docID).collection("messages").getDocuments { (QuerySnapshot
//            , Error) in
//            if Error != nil{
//                print("error getting messages documents \(Error!)")
//            }
//            else{
//                for document in QuerySnapshot!.documents{
//                    if document.exists{
//                        document.reference.delete(completion: { (Error) in
//                            if Error != nil{
//                                print(Error!)
//                            }
//                            else{
//                                print("deleted message doc successfully")
//                            }
//
//                        })
//                    }
//
//                }
//                self.deleteOuterDocument()
//
//
//            }
//        }
        
    
  
//    func deleteOuterDocument(){
//        db.collection("userMessageA").document(docID).delete { (Error) in
//            if Error != nil{
//                print(Error!)
//            }
//            else{
//                print("success!")
//            }
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToUserMessages"{ //segue for messages, pass doc ID and message status as data
            let messagesVC = segue.destination as! UserMessagesViewController
            messagesVC.documentID = docID
            messagesVC.messagesCreatedStatus = isMessagesCreated
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
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
