//
//  UploadToSocialViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 8/23/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseFirestore
import UserNotifications

class UploadToSocialViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // NOT CURRENTLY BEING USED IN APP
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var postButton: StyleButton!
    @IBOutlet weak var captionTextField: UITextField!
    
    var picker = UIImagePickerController()
    var timeSent : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.uploadImageView.image = image
            selectButton.isHidden = true
            postButton.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func selectImagePressed(_ sender: UIButton) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func postPressed(_ sender: StyleButton) {
        postButton.isUserInteractionEnabled =  false
        let storage = Storage.storage()
        let imageName = UUID().uuidString
        let storageRef = storage.reference().child("NewsPosts").child("\(imageName).png")
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"

        if let uploadData = uploadImageView.image?.pngData(){
           storageRef.putData(uploadData, metadata: metadata) { (metadata, error) in
                if error != nil{
                    if let Error = error {
                        self.handleError(Error)
                    }
                    return
                }
               // print(metadata!)
                _ = storageRef.downloadURL(completion: { (URL, Error) in
                    if Error != nil {
                        //print("error getting url")
                    }
                    else{
                        self.getPostTime()
                        self.storeInPostDB(URL: URL!.absoluteString,postID: imageName)
                    }
            })
        }
        
    }
    }
    
    func storeInPostDB(URL: String, postID: String){
        if let caption = captionTextField.text{
            let database = Firestore.firestore().collection("posts")
            database.document(postID).setData(["postID" : postID, "URL" : URL,"caption" : caption, "timeStamp" : timeSent]) { (Error) in
                if let err = Error {
                   // print("Error writing document:\(err)")
                } else{
                   // print("Document successfully written")
                    
                    let refreshAlert = UIAlertController(title: "Success!", message: "The post has been uploaded!", preferredStyle: UIAlertController.Style.alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                       // print("Handle Ok logic here")
                        self.captionTextField.text = ""
                        self.uploadImageView.image = nil
                        self.selectButton.isHidden = false
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.postButton.isUserInteractionEnabled =  true
                    self.present(refreshAlert, animated: true,completion: nil)
                }
            }
        }
    }
    
    func getPostTime(){
        let date = Date()
        let time = 999999999 - date.timeIntervalSince1970
        timeSent = Int(time) //fills specific sent time
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
