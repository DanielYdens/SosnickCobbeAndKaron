//
//  UserMessagesViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 7/17/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import FirebaseAuth

class UserMessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var backgroundToTypingView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        getMessageSentTime()
        storeMostRecentMessageSentTime()
        let messageDictionary = ["sender" : Auth.auth().currentUser?.email as Any, "messageBody" : messageTextField.text!, "time" : messageTime as Any]
        
        if messagesCreatedStatus == false{
            
            messageDB.document(documentID).collection("messages").addDocument(data: messageDictionary as [String : Any]) { (Error) in
                if Error != nil{ // check if add doc is what u really want
                    if let error = Error{
                        self.handleError(error)
                    }
                } else{
                    print("message successfully saved")
                    self.messageTextField.isEnabled = true
                    self.sendButton.isEnabled = true
                    self.messageTextField.text = ""
                    self.messagesCreatedStatus = true
                    self.updateMessageStatus()
                    self.retrieveMessages()
                }
            }
        } else{
            messageDB.document(documentID).collection("messages").addDocument(data: messageDictionary as [String : Any])
            print("already had a message in it")
            self.messageTextField.isEnabled = true
            self.sendButton.isEnabled = true
            self.messageTextField.text = ""
            self.retrieveMessages()
        }
        
        
        
        
        
        
    }
    
    var documentID : String = ""
    var messageArray : [Message] = [Message]()
    let messageDB = Firestore.firestore().collection("userMessageA")
    let userDB = Firestore.firestore().collection("users")
    var messagesCreatedStatus : Bool = false
    var messageTime : Int = 0
    var timeForUserLastSeen : Int = 0
    var profilePicURL : String = ""
    var adminProfilePicURL : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextField.delegate = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        getProfilePicture()
        getTime()
        storeLastSeen()
        configureTableView()
        retrieveMessages()
        additionalSetup()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.avatarImageView.roundedImage()
        let blueColor = UIColor(red: 0, green: 0.549, blue: 0.8471, alpha: 1.0)
        let greyColor = UIColor(white: 0.95, alpha: 1)
        cell.messageBackground.backgroundColor = blueColor
        cell.senderUsername.textColor = .white
        if messageArray.count > 10{
            messageTableView.transform = CGAffineTransform (scaleX: 1,y: -1);
            cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1);
        }
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email{
            cell.messageBackground.backgroundColor = greyColor
            cell.senderUsername.textColor = .black
            cell.messageBody.textColor = .black
            if profilePicURL == ""{
                cell.avatarImageView.image = UIImage(named: "addProfilePicture")
                
               
            } else{
                
                cell.avatarImageView.downloaded(from: profilePicURL)
                
            }
        }
        else{
            cell.avatarImageView.image = UIImage(named: "large-logo")
            
        
           
        }
       
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        
        
        return cell
        
        
    }
    
 
    
   
    
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 500.0
        
    }
    
    func retrieveMessages(){
        if messagesCreatedStatus == true {
            messageDB.document(documentID).collection("messages").order(by: "time").addSnapshotListener { (QuerySnapshot
            , Error) in
            if Error != nil{
                if let error = Error{
                    self.handleError(error)
                }
            } else{
                var text : String = ""
                var sender : String = ""
                var timeSent : Int = 0
                self.messageArray.removeAll()
                for document in QuerySnapshot!.documents{
                    text = document.get("messageBody") as! String
                   
                    sender = document.get("sender") as! String
                    timeSent = document.get("time") as! Int
                    let message = Message()
                    message.messageBody = text
                    message.sender = sender
                    message.time = timeSent
                    self.messageArray.append(message)
                }
                self.configureTableView()
                self.messageTableView.reloadData()
                
            }
        }
            
        
        }
    }
    func updateMessageStatus(){
        let db = Firestore.firestore().collection("userRequestB")
        db.document(documentID).updateData(["message" : true])
    }
    
    func getProfilePicture(){
        let userDB = Firestore.firestore().collection("users")
        let currentUserUID = Auth.auth().currentUser?.uid
        let docRef = userDB.document(currentUserUID!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.profilePicURL = document.get("profilePictureURL") as! String
                self.messageTableView.reloadData()
            } else {
                print("Document does not exist")
            }
        }
    }
    
  
    
    func getMessageSentTime(){
        let date = Date()
        let timeSent = date.timeIntervalSince1970
        messageTime = Int(timeSent) //fills specific sent time
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        UIView.animate(withDuration: 0.25) {
            self.heightConstraint.constant = 358
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.25) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    
    func additionalSetup(){
        messageTableView.separatorStyle = .none
        messageTextField.layer.borderWidth = 1
        messageTextField.layer.cornerRadius = 5
        
    }
    func getTime(){
        let date = Date()
        let time = date.timeIntervalSince1970
        timeForUserLastSeen = Int(time)
    }
    func storeLastSeen(){
        messageDB.document(documentID).updateData(["userLastSeen" : timeForUserLastSeen])
    }
    
    func storeMostRecentMessageSentTime(){
        messageDB.document(documentID).updateData(["adminMostRecentMessage":messageTime])
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
