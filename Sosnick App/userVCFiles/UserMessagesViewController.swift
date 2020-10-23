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
import NotificationCenter
import FirebaseStorage

class UserMessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var backgroundToTypingView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var cameraImageView: UIImageView!
    
    @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true) //if back button pressed click back
    }
    
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if messageTextField.text != "" {
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
        
    }
    
    var screenshotPictureCache = NSCache<NSString, UIImage>()
    var documentID : String = ""
    var messageArray : [Message] = [Message]()
    let messageDB = Firestore.firestore().collection("userMessageA")
    let userDB = Firestore.firestore().collection("users")
    var messagesCreatedStatus : Bool = false
    var messageTime : Int = 0
    var timeForUserLastSeen : Int = 0
    var profilePicURL : String = ""
    var adminProfilePicURL : String = ""
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    var role : String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backBarButtonItem.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "ErasITC-Medium", size: 15)!], for: UIControl.State.normal)
        cameraImageView.image = UIImage(named: "camera")
        cameraImageView.isUserInteractionEnabled = true
        cameraImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        self.view.subviews.forEach { $0.isHidden = true }
//        activityIndicator.center = self.view.center
//        activityIndicator.hidesWhenStopped = true
//        if #available(iOS 13.0, *) {
//            activityIndicator.style = UIActivityIndicatorView.Style.white
//        } else {
//            // Fallback on earlier versions
//        }
//        view.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
//        self.view.isUserInteractionEnabled = false
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextField.delegate = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell") //use correct cell
        messageTableView.register(UINib(nibName: "ScreenshotTableViewCell", bundle: nil), forCellReuseIdentifier: "ScreenshotTableViewCell") //use correct cell
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        //getProfilePicture()
        getTime()
        storeLastSeen()
        configureTableView()
        retrieveMessages()
        additionalSetup()
        // Do any additional setup after loading the view.
    }
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage){
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("failed to upload image: ", error!)
                    return
                }
                ref.downloadURL { (url, error) in
                    if error != nil {
                        print("error fetching download URL: ", error!)
                        return
                    }
                    if let imageURL = url?.absoluteString {
                        self.sendMessageWithImageURL(imageURL: imageURL)
                    }
                }
            }
        }
        
    }
    
    private func sendMessageWithImageURL(imageURL : String){
        messageTextField.endEditing(true) //cant edit once button is pressed
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        getMessageSentTime() //get current time
        storeMostRecentMessageSentTime() //store it in database
        let messageDictionary = ["sender" : Auth.auth().currentUser?.email as Any, "imageURL" : imageURL, "time" : messageTime as Any] //put message information in dictionary
        
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
    
//    @objc func keyboardWillShow(_ notification: Notification) {
//        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height
//            UIView.animate(withDuration: 0.25) {
//                self.heightConstraint.constant = keyboardHeight + self.messageTextField.layer.frame.height + 20 //when they click the typing field it moves up to accomodate for keyboard
//                self.view.layoutIfNeeded()
//            }
//        }
//    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        UIView.animate(withDuration: 0.25) {
            self.heightConstraint.constant = 358//when they click the typing field it moves up to accomodate for keyboard
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.25) {
            self.heightConstraint.constant = 58//when they click the typing field it moves up to accomodate for keyboard
            self.view.layoutIfNeeded()
        }
        
    }
    

    
    
    func stopActivityIndicator() {
      self.view.subviews.forEach { $0.isHidden = false }
      self.activityIndicator.stopAnimating()
      self.view.isUserInteractionEnabled = true
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count //return # of messages in message array
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let screenshotCell = messageTableView.dequeueReusableCell(withIdentifier: "ScreenshotTableViewCell", for: indexPath) as! ScreenshotTableViewCell
        let cell = messageTableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell //use correct cell for table
        
        print("message text: ", messageArray[indexPath.row].messageBody)
        print("message imageurl: ", messageArray[indexPath.row].imageURL)
        screenshotCell.userMessagesViewController = self
        if messageArray[indexPath.row].imageURL != "" {
            if let imageURL = URL(string: messageArray[indexPath.row].imageURL) {
                print(imageURL)
                downloadImage(url: imageURL, rowNumber: indexPath.row) { (image) in
                    if image != nil {
                        DispatchQueue.main.async {
                            screenshotCell.screenshotImageView?.image = image
                        }
                    }
                }
            }
            
            
//            screenshotCell.imageView?.loadImageUsingCacheWithUrlString(urlString: messageArray[indexPath.row].imageURL)
            return screenshotCell
            
        }
        else{
            let blueColor = UIColor(red: 0, green: 0.549, blue: 0.8471, alpha: 1.0) //different colors for different user messages YOU VS OTHER USER
            let greyColor = UIColor(white: 0.95, alpha: 1)
            cell.messageBackground.backgroundColor = greyColor //automatically blue
            cell.senderUsername.textColor = .black
            cell.messageBody.textColor = .black
//            if messageArray.count > 10{ //if messages are greater than 10
//                messageTableView.transform = CGAffineTransform (scaleX: 1,y: -1); //need to flip to show most recent at bottom
//                cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1);
//            }
            if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email{ //if sender of that message is you
                cell.messageBackground.backgroundColor = blueColor //use grey color
                cell.senderUsername.textColor = .white //text is black
                cell.messageBody.textColor = .white
            }
            
            
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender //fill correct data
        }
        return cell
        
        
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messageArray.count-1, section: 0)
            self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
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
                self.messageArray.removeAll() //reset array
                for document in QuerySnapshot!.documents{
                    let message = Message()
                    if let text = document.get("messageBody") as? String {
                        message.messageBody = text
                    }
                    if let sender = document.get("sender") as? String {
                        message.sender = sender
                    }
                    if let timeSent = document.get("time") as? Int {
                        message.time = timeSent
                    }
                    if let imageURL = document.get("imageURL") as? String {
                        message.imageURL = imageURL
                    }
                    
                    self.messageArray.append(message) //fill array with messages
                }
                self.configureTableView()
                self.messageTableView.reloadData() //reload with new data
                self.scrollToBottom()
                
            }
        }
            
        
        }
    }
    func updateMessageStatus(){
        let db = Firestore.firestore().collection("userRequestC")
        db.document(documentID).updateData(["message" : true]) //update to show that a first message has been sent
    }
    
//    func getProfilePicture(){
//        let userDB = Firestore.firestore().collection("users")
//        let currentUserUID = Auth.auth().currentUser?.uid
//        let docRef = userDB.document(currentUserUID!) //go into user database and find current user
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                self.profilePicURL = document.get("profilePictureURL") as! String //get their profile picture url
//                self.messageTableView.reloadData()
//            } else {
//                print("Document does not exist")
//            }
//        }
//    }
    
  
    
    func getMessageSentTime(){
        let date = Date()
        let timeSent = date.timeIntervalSince1970
        messageTime = Int(timeSent) //fills specific sent time
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
        if role == "Admin" {
            messageDB.document(documentID).updateData(["adminLastSeen" : timeForUserLastSeen])
        }
        else{
            messageDB.document(documentID).updateData(["userLastSeen" : timeForUserLastSeen])
        }
        
    }
    
    func storeMostRecentMessageSentTime(){
        if role == "Admin" {
            messageDB.document(documentID).updateData(["mostRecentMessage":messageTime])
        }
        else{
            messageDB.document(documentID).updateData(["adminMostRecentMessage":messageTime])
        }
         //update most recent message sent time in database
    }
    
    func downloadImage(url: URL, rowNumber : Int, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = screenshotPictureCache.object(forKey: url.absoluteString as NSString){ //if already in the image cache
            print("in : " , url)
           
            completion(cachedImage)
            
        }
        else{ //if not already in the cache
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                //download hit an error
                if error != nil{
                    if let Error = error{
                        self.handleError(Error)
                        return
                    }
                    
                }
                if let pictureData = data{
                    self.screenshotPictureCache.setObject(UIImage(data: pictureData)!, forKey: url.absoluteString as NSString) //get data for picture and put it in the cache
                    print("not in : " , url)
                    completion(UIImage(data: pictureData))
                    DispatchQueue.main.async {
                        let indexPosition = IndexPath(row: rowNumber, section: 0)
                        self.messageTableView.reloadRows(at: [indexPosition], with: .none)
                        
                    }
                   
                }
                
                
                }.resume()
            
        }
    }
    
    //zooming in on image view logic
    var startingFrame : CGRect?
    var blackBackgroundView : UIView?
    var startingImageView : UIImageView?
    
    
    func performZoomInForImageView(startingImageView: UIImageView) {
        print("Performing zoom logic")
        
        startingFrame =  startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.contentMode = .scaleAspectFit
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.image = startingImageView.image
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                
                let height = self.view.frame.height//self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }) { (completed) in
                //do nada
            }
        }
        
        
        
    }
    

    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        print("handleZoomOut")
        if let zoomOutImageView = tapGesture.view {
            //need to animatew back to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.startingImageView?.isHidden = false
            }) { (completed) in
                zoomOutImageView.removeFromSuperview()
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
