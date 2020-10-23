//
//  MassCommunicationViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 10/21/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MassCommunicationViewController: UIViewController {


    @IBOutlet weak var sendButton: StyleButton!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var database = Firestore.firestore()
    var messageDate : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "ErasITC-Medium", size: 15)!], for: UIControl.State.normal)
        getCurrentDate()
        backgroundImage.image = UIImage(named: "apexLogo")
        messageTextView.layer.cornerRadius = 5
        messageTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        messageTextView.layer.borderWidth = 0.5 //ascetic adjustments
        messageTextView.clipsToBounds = true
        self.hideKeyboardWhenTappedAround() //if they tap anywhere around screen hide keyboard
        // Do any additional setup after loading the view.
    }
    

    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true) //when back button pressed go back to news view controllers
    }
    
    
    @IBAction func sendButtonPressed(_ sender: StyleButton) {
        let refreshAlert = UIAlertController(title: "Are You sure?", message: "This will send out a message to all users.", preferredStyle: UIAlertController.Style.alert) //Are you sure alert
        
        refreshAlert.addAction(UIAlertAction(title: "Yes, I'm sure", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            if let messageText = self.messageTextView.text {
                if let titleText = self.titleTextField.text { self.database.collection("massCommunication").addDocument(data: ["message" : messageText, "title" : titleText, "timeStamp" : self.messageDate]) // when yes im sure button pressed create a document within mass communication  that has the data of the message and title
                }
           }
            
            self.messageTextView.text = ""
            self.titleTextField.text = ""
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here") //if clicked no do nothing
        }))
        
        present(refreshAlert, animated: true, completion: nil) //present alert
        
    }
    
    func getCurrentDate(){
        let date =  Date()
       // requestDate = "\(month)/\(day)/\(year)"
        let timeInterval = date.timeIntervalSince1970
        messageDate = Int(timeInterval)
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
