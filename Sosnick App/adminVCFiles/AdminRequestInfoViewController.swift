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

    
    @IBAction func completeButtonPressed(_ sender: UIBarButtonItem) {
        let refreshAlert = UIAlertController(title: "Are You sure?", message: "This will mark this request as complete", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes, I'm sure", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            let documentRef = self.database.collection("userRequestB").document(self.documentID)
            
            
            documentRef.updateData([
                "isProcessed" : true
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                    let banner = GrowingNotificationBanner(title: "Success!", subtitle: "The status of the request has been changed to completed", leftView: self.leftView, style: .success)
                    banner.show()
                    
                    _ = self.navigationController?.popViewController(animated: true)
                    
                }
                
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
        
      
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goToMessagesClicked(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "goToMessages", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMessages"{
            let nextVC = segue.destination as! MessagesViewController
            nextVC.userEmailAddress = userEmail
            nextVC.isFirstMessageSent = messageStatus
            nextVC.documentID = documentID
            
        }
    }
       
    @IBOutlet weak var userLabel: UITextField!
   
    @IBOutlet weak var categoryLabel: UITextField!
    @IBOutlet weak var dateLabel: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var adminCategory : String  = ""
    var adminDescription : String = ""
    var adminDate : String = ""
    var userEmail : String = ""
    var documentID : String = ""
    let database = Firestore.firestore()
    let leftView = UIImageView(image: #imageLiteral(resourceName: "greenCheck"))
    var messageStatus : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fillInformation()
        setUnedittable()
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.clipsToBounds = true
     
        // Do any additional setup after loading the view.
    }
    
    func fillInformation(){
        userLabel.text = userEmail
        categoryLabel.text = adminCategory
        dateLabel.text = adminDate
        descriptionTextView.text = adminDescription
    }
    
    func setUnedittable(){
        userLabel.isUserInteractionEnabled = false
        categoryLabel.isUserInteractionEnabled = false
        dateLabel.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
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
