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
        self.navigationController?.popViewController(animated: true) //if back button pressed click back
    }
    
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        messageTextField.endEditing(true) //cant edit once button is pressed
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        getMessageSentTime() //get current time
        storeMostRecentMessageSentTime() //store it in database
        let messageDictionary = ["sender" : Auth.auth().currentUser?.email as Any, "messageBody" : messageTextField.text!, "time" : messageTime as Any] //put message information in dictionary
        
        if messagesCreatedStatus == false{ //if first message has not been sent yet
            
            messageDB.document(documentID).collection("messages").addDocument(data: messageDictionary as [String : Any]) { (Error) in //go into messages database and add a new conversation document
                if Error != nil{
                    if let error = Error{
                        self.handleError(error)
                    }
                } else{
                    print("message successfully saved") //success
                    self.messageTextField.isEnabled = true
                    self.sendButton.isEnabled = true //reenable buttons and text field and clear it
                    self.messageTextField.text = ""
                    self.messagesCreatedStatus = true
                    self.updateMessageStatus()
                    self.retrieveMessages()
                }
            }
        } else{ //if first message has already been created
            messageDB.document(documentID).collection("messages").addDocument(data: messageDictionary as [String : Any]) //go into the conversation in the DB and add document for text
            print("already had a message in it")
            self.messageTextField.isEnabled = true //reenable buttons and text field and clear text field
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
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell") //use correct cell
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
        return messageArray.count //return # of messages in message array
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell //use correct cell for table
        cell.avatarImageView.roundedImage() //round the image
        let blueColor = UIColor(red: 0, green: 0.549, blue: 0.8471, alpha: 1.0) //different colors for different user messages YOU VS OTHER USER
        let greyColor = UIColor(white: 0.95, alpha: 1)
        cell.messageBackground.backgroundColor = blueColor //automatically blue
        cell.senderUsername.textColor = .white
        if messageArray.count > 10{ //if messages are greater than 10
            messageTableView.transform = CGAffineTransform (scaleX: 1,y: -1); //need to flip to show most recent at bottom
            cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1);
        }
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email{ //if sender of that message is you
            cell.messageBackground.backgroundColor = greyColor //use grey color
            cell.senderUsername.textColor = .black //text is black
            cell.messageBody.textColor = .black
            if profilePicURL == ""{ //if no profile picture
                cell.avatarImageView.image = UIImage(named: "addProfilePicture") //show generic
                
               
            } else{
                
                cell.avatarImageView.downloaded(from: profilePicURL) //show correct profile pic
                
            }
        }
        else{
            cell.avatarImageView.image = UIImage(named: "apex") //if not you then show admin logo
            
        
           
        }
       
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender //fill correct data
        
        
        return cell
        
        
    }
    
 
    
   
    
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 500.0 //table view setup
        
    }
    
    func retrieveMessages(){
        if messagesCreatedStatus == true { //if already a first message sent
            messageDB.document(documentID).collection("messages").order(by: "time").addSnapshotListener { (QuerySnapshot //go into messages and add a listener
            , Error) in
            if Error != nil{
                if let error = Error{
                    self.handleError(error)
                }
            } else{
                var text : String = ""
                var sender : String = ""
                var timeSent : Int = 0
                self.messageArray.removeAll() //reset array
                for document in QuerySnapshot!.documents{
                    text = document.get("messageBody") as! String
                   
                    sender = document.get("sender") as! String
                    timeSent = document.get("time") as! Int
                    let message = Message()
                    message.messageBody = text
                    message.sender = sender
                    message.time = timeSent
                    self.messageArray.append(message) //fill array with messages
                }
                self.configureTableView()
                self.messageTableView.reloadData() //reload with new data
                
            }
        }
            
        
        }
    }
    func updateMessageStatus(){
        let db = Firestore.firestore().collection("userRequestC")
        db.document(documentID).updateData(["message" : true]) //update to show that a first message has been sent
    }
    
    func getProfilePicture(){
        let userDB = Firestore.firestore().collection("users")
        let currentUserUID = Auth.auth().currentUser?.uid
        let docRef = userDB.document(currentUserUID!) //go into user database and find current user
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.profilePicURL = document.get("profilePictureURL") as! String //get their profile picture url
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
            self.heightConstraint.constant = 358 //when they click the typing field it moves up to accomodate for keyboard
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.25) {
            self.heightConstraint.constant = 50 //moves back down
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    
    func additionalSetup(){
        messageTableView.separatorStyle = .none
        messageTextField.layer.borderWidth = 1
        messageTextField.layer.cornerRadius = 5 //rounded
        
    }
    func getTime(){
        let date = Date()
        let time = date.timeIntervalSince1970
        timeForUserLastSeen = Int(time) //get time and update user seen helps will blue dot
    }
    func storeLastSeen(){
        messageDB.document(documentID).updateData(["userLastSeen" : timeForUserLastSeen])
    }
    
    func storeMostRecentMessageSentTime(){
        messageDB.document(documentID).updateData(["adminMostRecentMessage":messageTime]) //update most recent message sent time in database
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
