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
        messageTextField.endEditing(true) //cannot edit while send button pressed
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        getMessageSentTime() //getting message sent time
        storeMostRecentMessageSentTime() //storing most recent message sent time for the ability to display blue dot
        let messageDictionary = ["sender" : Auth.auth().currentUser?.email as Any, "messageBody" : messageTextField.text!, "time" : sentTime as Any] //sender is the email of the user and the message body is the text
        
        if isFirstMessageSent == false{ //if this is the first message within the conversation
             //add a new document to the messages database
            database.document(documentID).collection("messages").addDocument(data: messageDictionary as [String : Any]) { (Error) in
                if Error != nil{ // check if add doc is what u really want
                    //print(Error!)
                    if let error = Error{
                        self.handleError(error)
                    }
                } else{
                    print("message successfully saved")
                    self.messageTextField.isEnabled = true
                    self.sendButton.isEnabled = true
                    self.messageTextField.text = "" //reenable buttons and text field
                    self.isFirstMessageSent = true
                    self.updateMessageStatus() //updates to show that the conversation has been started and first message has been sent
                    self.retrieveMessages() //fetches all the messages in the conversation
                }
            }
        } else{
            database.document(documentID).collection("messages").addDocument(data: messageDictionary as [String : Any]) //if already had messages in the conversation
            print("already had a message in it")
            self.messageTextField.isEnabled = true //reenable the fields
            self.sendButton.isEnabled = true
            self.messageTextField.text = ""
            self.retrieveMessages() //retrieve the messages
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
        messageTableView.dataSource = self //want this file to fill the table view with all information and data
        messageTextField.delegate = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell") //register the correct cell for messaging table view cell
        configureTableView() //setup table view
        retrieveMessages() //get messages
        
        messageTableView.separatorStyle = .none
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        additionalSetup()
        getTime() //get current time
        storeLastSeen() //store the time
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count //return the number of messages in the message array
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell //using custom message cell nib
        cell.avatarImageView.roundedImage() //round the profile picture
        let blueColor = UIColor(red: 0, green: 0.549, blue: 0.8471, alpha: 1.0)
        cell.messageBackground.backgroundColor = blueColor //setting background to blue
        if messageArray.count > 10{ //if more than ten messages it needs to start with the most recent message on the bottom
            messageTableView.transform = CGAffineTransform (scaleX: 1,y: -1);
            cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1);
        }
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email{ //if it is the current logged in users message aka ADMIN
            
            cell.avatarImageView.image = UIImage(named: "apex") //use admin profile picture
            cell.messageBackground.backgroundColor = UIColor(white: 0.95, alpha: 1) // light grey
            cell.messageBody.textColor = .black //text of message to black
        }
        else{
            if profilePictureURL == ""{ // if no profile picture use the generic one
                cell.avatarImageView.image = UIImage(named: "addProfilePicture")
                
                
            } else{
                
                cell.avatarImageView.downloaded(from: profilePictureURL) // download it if there is one
                
            }
        }
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody //fill text field with message
        cell.senderUsername.text = messageArray[indexPath.row].sender //fill sender text field with sender email
        
        return cell
    }
    
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension //setting up height and row height
        messageTableView.estimatedRowHeight = 120.0
    }
    
    func retrieveMessages(){
        if isFirstMessageSent == true{ //if already messages in the conversation
            database.document(documentID).collection("messages").order(by: "time").addSnapshotListener { (QuerySnapshot
                , Error) in //look into the database and order the messages by time
                if Error != nil{
                    if let error = Error{
                        self.handleError(error)
                    }
                } else{
                    var text : String = ""
                    var sender : String = ""
                    var timeStamp : Int = 0
                    self.messageArray.removeAll() //empty the message array
                    for document in QuerySnapshot!.documents{ //for each document in snapshot
                        text = document.get("messageBody") as! String //get message
                        sender = document.get("sender") as! String //get sender
                        timeStamp = document.get("time") as! Int //get time sent
                        let message = Message()
                        message.messageBody = text
                        message.sender = sender
                        message.time = timeStamp
                        self.messageArray.append(message) //append message to the array
                    }
                    self.configureTableView() //configure the table
                    self.getProfilePicture() //get the profile picture
                    self.messageTableView.reloadData() //reload table
                }
            }
        }
    }
    
    func updateMessageStatus(){
        let db = Firestore.firestore().collection("userRequestC")
        db.document(documentID).updateData(["message" : true]) //updating a conversation in database to show that initial message is sent
    }

    
    
    func getMessageSentTime(){
        let date = Date()//get date
        let timeSent = date.timeIntervalSince1970 //since 1970
        sentTime = Int(timeSent) //update sent time
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        UIView.animate(withDuration: 0.25) {
            self.heightConstraint.constant = 358 //when user clicks the message field to type their message then the field moves up for the keyboard
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.25) {
            self.heightConstraint.constant = 50 //when they stop editting it goes down
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true) //when they tap the table view cant edit message text field
    }
    
    
    func additionalSetup(){
        messageTableView.separatorStyle = .none //no separator between messages
        messageTextField.layer.borderWidth = 1 //border and rounded for the users typing field
        messageTextField.layer.cornerRadius = 5
        
    }
    
    func getTime(){
        let date = Date()
        let time = date.timeIntervalSince1970
        adminLastSeen = Int(time) //update the time when admin has seen the most recent message
    }
    func storeLastSeen(){
        database.document(documentID).updateData(["adminLastSeen" : adminLastSeen]) //update in database
    }
    
    func storeMostRecentMessageSentTime(){
        database.document(documentID).updateData(["mostRecentMessage":sentTime]) //update most recent message time in database
    }
    func getProfilePicture(){
        let userDB = Firestore.firestore().collection("users")
        var email : String = ""
        for items in messageArray {
            if items.sender != Auth.auth().currentUser?.email{ //if the messages email does not equal the current user set the email to that sender
                email = items.sender
            }
        }
        let docRef = userDB.whereField("Email", isEqualTo: email) //go into user DB where they have that email
        docRef.getDocuments { (QuerySnapshot, Error) in //get documents
            if Error !=  nil{
                if let error = Error{
                    self.handleError(error)
                }
                return
            }
            else{
                for document in QuerySnapshot!.documents{ //get the profile picture URL
                    self.profilePictureURL = document.get("profilePictureURL") as? String ?? ""
                }
                self.messageTableView.reloadData() //reload data in table
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
