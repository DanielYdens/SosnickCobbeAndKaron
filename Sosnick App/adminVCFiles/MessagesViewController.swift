//
//  MessagesViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 7/17/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import FirebaseAuth

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
  
    
    @IBOutlet weak var backgroundToTypingView: UIView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        getMessageSentTime()
        storeMostRecentMessageSentTime()
        let messageDictionary = ["sender" : Auth.auth().currentUser?.email as Any, "messageBody" : messageTextField.text!, "time" : sentTime as Any]
        
        if isFirstMessageSent == false{
            
            database.document(documentID).collection("messages").addDocument(data: messageDictionary as [String : Any]) { (Error) in
                if Error != nil{ // check if add doc is what u really want
                    print(Error!)
                } else{
                    print("message successfully saved")
                    self.messageTextField.isEnabled = true
                    self.sendButton.isEnabled = true
                    self.messageTextField.text = ""
                    self.isFirstMessageSent = true
                    self.updateMessageStatus()
                    self.retrieveMessages()
                }
            }
        } else{
            database.document(documentID).collection("messages").addDocument(data: messageDictionary as [String : Any])
            print("already had a message in it")
            self.messageTextField.isEnabled = true
            self.sendButton.isEnabled = true
            self.messageTextField.text = ""
            self.retrieveMessages()
        }
    
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    var documentID : String = ""
    var messageArray : [Message] = [Message]()
    var userEmailAddress : String = ""
    let database = Firestore.firestore().collection("userMessageA")
    var isFirstMessageSent : Bool = false
    var sentTime : Int = 0
    var adminLastSeen : Int = 0
    var profilePictureURL : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextField.delegate = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        
        messageTableView.addGestureRecognizer(tapGesture)
        additionalSetup()
        getTime()
        storeLastSeen()
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.avatarImageView.roundedImage()
        let blueColor = UIColor(red: 0, green: 0.549, blue: 0.8471, alpha: 1.0)
        cell.messageBackground.backgroundColor = blueColor
        if messageArray.count > 10{
            messageTableView.transform = CGAffineTransform (scaleX: 1,y: -1);
            cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1);
        }
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email{
            
            cell.avatarImageView.image = UIImage(named: "large-logo")
            cell.messageBackground.backgroundColor = UIColor(white: 0.95, alpha: 1) // light grey
            cell.messageBody.textColor = .black
        }
        else{
            if profilePictureURL == ""{
                cell.avatarImageView.image = UIImage(named: "addProfilePicture")
                
                
            } else{
                
                cell.avatarImageView.downloaded(from: profilePictureURL)
                
            }
        }
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        
        return cell
    }
    
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    func retrieveMessages(){
        if isFirstMessageSent == true{
            database.document(documentID).collection("messages").order(by: "time").addSnapshotListener { (QuerySnapshot
                , Error) in
                if Error != nil{
                    print(Error!)
                } else{
                    var text : String = ""
                    var sender : String = ""
                    var timeStamp : Int = 0
                    self.messageArray.removeAll()
                    for document in QuerySnapshot!.documents{
                        text = document.get("messageBody") as! String
                        sender = document.get("sender") as! String
                        timeStamp = document.get("time") as! Int
                        let message = Message()
                        message.messageBody = text
                        message.sender = sender
                        message.time = timeStamp
                        self.messageArray.append(message)
                    }
                    self.configureTableView()
                    self.getProfilePicture()
                    self.messageTableView.reloadData()
                }
            }
        }
    }
    
    func updateMessageStatus(){
        let db = Firestore.firestore().collection("userRequestB")
        db.document(documentID).updateData(["message" : true])
    }

    
    
    func getMessageSentTime(){
        let date = Date()
        let timeSent = date.timeIntervalSince1970
        sentTime = Int(timeSent)
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
        adminLastSeen = Int(time)
    }
    func storeLastSeen(){
        database.document(documentID).updateData(["adminLastSeen" : adminLastSeen])
    }
    
    func storeMostRecentMessageSentTime(){
        database.document(documentID).updateData(["mostRecentMessage":sentTime])
    }
    func getProfilePicture(){
        let userDB = Firestore.firestore().collection("users")
        var email : String = ""
        for items in messageArray {
            if items.sender != Auth.auth().currentUser?.email{
                email = items.sender
            }
        }
        let docRef = userDB.whereField("Email", isEqualTo: email)
        docRef.getDocuments { (QuerySnapshot, Error) in
            if Error !=  nil{
                print(Error!)
                return
            }
            else{
                for document in QuerySnapshot!.documents{
                    self.profilePictureURL = document.get("profilePictureURL") as? String ?? ""
                }
                self.messageTableView.reloadData()
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

}
