//
//  RequestViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 7/2/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import NotificationBannerSwift
import QuartzCore

class RequestViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    

    @IBAction func submitButtonPressed(_ sender: UIBarButtonItem) {
        submitButton.isEnabled = false
        
        var ref: DocumentReference? = nil
        if let userName = name{
            ref = db.collection("userRequestB").addDocument(data: [
                "category": pickerTextField.text!,
                "description": descriptionTextField.text!,
                "isProcessed" : false,
                "date" : requestDate,
                "uid" : userUID,
                "dateNum" : 999999999999 - requestDateNum,
                "user" : Auth.auth().currentUser?.email ?? "",
                "message" : false,
                "name" : userName
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.initializeChatVariables(DocumentID: ref!.documentID)
                    self.pickerTextField.text = ""
                    self.descriptionTextField.text = ""
                    self.submitButton.isEnabled = true
                    let banner = GrowingNotificationBanner(title: "Success!", subtitle: "Your request has been submitted and will be processed as soon as possible", leftView: self.leftView, style: .success)
                    banner.show()
                    
                    
                }
            }
        }
    }

    @IBOutlet weak var pickerTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextView!
    

    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    var name : String? = ""
    let leftView = UIImageView(image: #imageLiteral(resourceName: "greenCheck"))
    var userUID : String = ""
    let categories = ["","Equipment","Airfare","Concert/Event Tickets","Hotel", "Other"]
    let db = Firestore.firestore()
    var requestDate : String = ""
    var requestDateNum : Int = 0 // FIXME dont have so many globals
    var isNil = false
    
   // var date =
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        getName()
        getUID()
//        view.addBackground(imageName: "stadium", contentMode: .scaleAspectFill)
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerTextField.inputView = pickerView
        getCurrentDate()
        initializeDescriptionTextView()
        self.title = "Concierge Request"
       
        // Do any additional setup after loading the view.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        descriptionTextField.borderStyle = UITextField.BorderStyle.roundedRect
//        descriptionTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.top
//    }
    
    func initializeDescriptionTextView(){ //initilizes the description text wrapping etc
        descriptionTextField.layer.cornerRadius = 10.0
        pickerTextField.layer.borderWidth = 1
        descriptionTextField.layer.borderWidth = 1
        pickerTextField.layer.cornerRadius = 5.0
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = categories[row]
    }
    
    func getCurrentDate(){
        let date =  Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        requestDate = "\(month)/\(day)/\(year)"
        let timeInterval = date.timeIntervalSince1970
        requestDateNum = Int(timeInterval)
    }
    
    func initializeChatVariables(DocumentID : String){
        
        db.collection("userMessageA").document(DocumentID).setData([
            "adminLastSeen": 0,
            "adminMostRecentMessage": 0,
            "mostRecentMessage": 0,
            "userLastSeen": 0
            
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
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
    func getUID(){
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                userUID = user.uid
            }
        } else{
            print("not logged in")
        }
    }


    func getName(){
        let userDB = Firestore.firestore().collection("users")
        userDB.whereField("Email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (QuerySnapshot, Error) in
            if Error != nil{
                if let error = Error{
                    self.handleError(error)
                }
                return
            }
            else{
                print(QuerySnapshot!.count)
                print(Auth.auth().currentUser!.email!)
                for document in QuerySnapshot!.documents{
                    print(document.data())
                    if let first = document.get("First") as? String{
                        self.name = first
                    }
                    self.name? += " "
                    if let last = document.get("last") as? String{
                        self.name? += last
                    }
                    
                }
            }
        }
    }



}




