//
//  ProfileViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 8/15/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import NotificationBannerSwift
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    var database = Firestore.firestore()
    let imagePlayerPictureCache = NSCache<NSString, UIImage>()
    var uid =  Auth.auth().currentUser!.uid
    var cleatPreference : String = ""
    var bats: String = ""
    var throwingArm : String = ""
   

 
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var confirmButton: StyleButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var twitterHandleTextField: UITextField!
    @IBOutlet weak var instagramHandleTextField: UITextField!
    @IBOutlet weak var cleatPreferenceSegmentController: UISegmentedControl!
    @IBOutlet weak var apparelTopSizeTextField: UITextField!
    @IBOutlet weak var apparelBottomSizeTextField: UITextField!
    @IBOutlet weak var battingGloveSizeTextField: UITextField!
//    @IBOutlet weak var batsSegmentController: UISegmentedControl!
//    @IBOutlet weak var throwsSegmentController: UISegmentedControl!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    
    
    @IBAction func LogoutButtonPressed(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            self.navigationController?.popToRootViewController(animated: true)
            
        }
        catch{
            print("error: couldnt log out")
            
        }
        
    }
    
    
    
    @IBAction func cleatPreferenceSegmentChanged(_ sender: UISegmentedControl) {
        switch cleatPreferenceSegmentController.selectedSegmentIndex
        {
        case 0:
            print("First Segment Selected")
            cleatPreference = "Low"
        case 1:
            print("Second Segment Selected")
            cleatPreference = "Mid"
        default:
            break
        }
    }
    
//    @IBAction func batsSegmentChanged(_ sender: UISegmentedControl) {
//        switch batsSegmentController.selectedSegmentIndex
//        {
//        case 0:
//            print("First Segment Selected")
//            bats = "Right"
//        case 1:
//            print("Second Segment Selected")
//            bats = "Left"
//        default:
//            break
//        }
//    }
    
    
//    @IBAction func throwsSegmentChanged(_ sender: UISegmentedControl) {
//        switch throwsSegmentController.selectedSegmentIndex
//        {
//        case 0:
//            print("First Segment Selected")
//            throwingArm = "Right"
//        case 1:
//            print("Second Segment Selected")
//            throwingArm = "Left"
//        default:
//            break
//        }
//    }
    
    
    
    @IBAction func EditButtonPressed(_ sender: UIBarButtonItem) {
        firstNameTextField.isUserInteractionEnabled = true
        lastNameTextField.isUserInteractionEnabled = true
        dateOfBirthTextField.isUserInteractionEnabled = true
        twitterHandleTextField.isUserInteractionEnabled = true
        instagramHandleTextField.isUserInteractionEnabled = true
        cleatPreferenceSegmentController.isUserInteractionEnabled = true
        apparelTopSizeTextField.isUserInteractionEnabled = true
        apparelBottomSizeTextField.isUserInteractionEnabled = true
        battingGloveSizeTextField.isUserInteractionEnabled = true
        //batsSegmentController.isUserInteractionEnabled = true
        //throwsSegmentController.isUserInteractionEnabled = true
        confirmButton.isUserInteractionEnabled = true
        confirmButton.isHidden = false
    }
    
    @IBAction func confirmButtonPressed(_ sender: StyleButton) {
        let documentReference = database.collection("users").document(uid)
        documentReference.updateData([
            "First" : firstNameTextField.text!,
            "last" : lastNameTextField.text!,
            "dateOfBirth" : dateOfBirthTextField.text!,
            "twitterHandle" : twitterHandleTextField.text!,
            "instagramHandle" : instagramHandleTextField.text!,
            "apparelTopSize" : apparelTopSizeTextField.text!,
            "apparelBottomSize" : apparelBottomSizeTextField.text!,
            "battingGloveSize" : battingGloveSizeTextField.text!,
            "cleatPreference" : cleatPreference,
            "bats" : bats,
            "throws" : throwingArm
        ] ) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                let refreshAlert = UIAlertController(title: "Success!", message: "Your profile has been updated.", preferredStyle: UIAlertController.Style.alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    
                    
                }))
                self.present(refreshAlert, animated: true, completion: nil)
                self.confirmButton.isHidden = true
                self.confirmButton.isUserInteractionEnabled = false
                self.setupTextFields()
            }
    }
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.navBar.isHidden = false
        
    }
    
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        makeImageRound()
        profilePictureSetup()
        getProfilePicture()
        //displayProfilePicture()
        setupTextFields()
        
       
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 500)
       

        // Do any additional setup after loading the view.
    }
    
    func getProfilePicture(){
        let userDB = database.collection("users")
        userDB.document(uid).getDocument { (DocumentSnapshot
            , Error) in
            if Error != nil{
                if let error = Error{
                    self.handleError(error)
                }
            }
            else{
                
                if let profilePictureURL = DocumentSnapshot?.get("profilePictureURL") as? String{
                    let url = NSURL(string: profilePictureURL)
                    if (url!.absoluteString != ""){
                        self.downloadImage(url: url! as URL) { (image) in
                            if image != nil{
                                DispatchQueue.main.async {
                                    self.profileImageView.image = image
                                }
                            }
                            else{
                                
                                return
                            }
                            
                        }
                    }
                    
                }
            }
        }
    }
    
//    func displayProfilePicture(){
//          var pictureURL : String =  ""
//          let db =  Firestore.firestore().collection("users")
//          let documentRef = db.document(uid)
//          documentRef.getDocument { (documentSnap, Error) in
//              if Error != nil{
//                  if let error = Error{
//                      self.handleError(error)
//                  }
//                  return
//              }
//              else{
//                  pictureURL = (documentSnap?.get("profilePictureURL") as? String)!
//                  let url = NSURL(string: pictureURL)
//                  self.downloadImage(url: url! as URL) { (Image) in
//                          if Image != nil{
//                              DispatchQueue.main.async {
//                                  self.profileImageView.image = Image
//                              }
//
//                          }
//                          else{
//                              return
//                          }
//                      }
//
//                  self.profileImageView.roundedImage()
//
//
//
//                  }
//              }
//      }
//
    
    func setupTextFields(){
        let docRef = database.collection("users").document(uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.firstNameTextField.text = document.get("First") as? String
                self.lastNameTextField.text = document.get("last") as? String
                self.dateOfBirthTextField.text = document.get("dateOfBirth") as? String
                self.twitterHandleTextField.text = document.get("twitterHandle") as? String
                self.instagramHandleTextField.text = document.get("instagramHandle") as? String
                self.apparelTopSizeTextField.text = document.get("apparelTopSize") as? String
                self.apparelBottomSizeTextField.text = document.get("apparelBottomSize") as? String
                self.battingGloveSizeTextField.text = document.get("battingGloveSize") as? String
                //self.bats = document.get("bats") as? String ?? "Right"
                //self.throwingArm = document.get("throws") as? String ?? "Right"
                self.cleatPreference = document.get("cleatPreference") as? String ?? "Low"
                self.setupSegmentControllers(cleatPref: self.cleatPreference, batting: self.bats, throwing: self.throwingArm)
                
            } else {
                print("Document does not exist")
            }
        }
        firstNameTextField.isUserInteractionEnabled = false
        lastNameTextField.isUserInteractionEnabled = false
        dateOfBirthTextField.isUserInteractionEnabled = false
        twitterHandleTextField.isUserInteractionEnabled = false
        instagramHandleTextField.isUserInteractionEnabled = false
        cleatPreferenceSegmentController.isUserInteractionEnabled = false
        apparelBottomSizeTextField.isUserInteractionEnabled = false
        apparelTopSizeTextField.isUserInteractionEnabled = false
        battingGloveSizeTextField.isUserInteractionEnabled = false
        //batsSegmentController.isUserInteractionEnabled = false
        //throwsSegmentController.isUserInteractionEnabled = false
        confirmButton.isUserInteractionEnabled = false
        confirmButton.isHidden = true
    }
    
    func profilePictureSetup(){
        
        profileImageView.image = UIImage(named: "addProfilePicture")
        
        DispatchQueue.main.async{
            self.profileImageView.isUserInteractionEnabled = true
            self.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleProfileImageTapped)))
        }
    }
    
    @objc func handleProfileImageTapped(){
        print("it got tapped")
        
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        var selectedImageFromPicker :UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
            print(editedImage.size)
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
            print(originalImage.size)
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
            storeImage(Image: selectedImage)
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func storeImage(Image: UIImage){
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        let imageName = UUID().uuidString
        // Create a storage reference from our storage service
        let storageRef = storage.reference().child("\(imageName).png")
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        if let uploadData = Image.pngData() {
            storageRef.putData(uploadData, metadata: metadata) { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                print(metadata!)
                _ = storageRef.downloadURL(completion: { (URL, Error) in
                    if Error != nil {
                        print("error getting url")
                    }
                    else{
                        self.storeInUserDB(URL: URL!.absoluteString)
                    }
                })
            }
        }
       
    }
    func makeImageRound(){
        profileImageView.roundedImage3()
        
    }
    func storeInUserDB(URL: String){
        let database = Firestore.firestore().collection("users")
        database.document(uid).updateData(["profilePictureURL" : URL])
    }
    
  
        
        
        
        
        //
//        var pictureURL : String =  ""
//        let db = Firestore.firestore().collection("users")
//        let documentRef = db.document(uid)
//        documentRef.getDocument { (documentSnap, Error) in
//            if Error != nil{
//                if let error = Error{
//                    self.handleError(error)
//                }
//                return
//            }
//            else{
//                pictureURL = documentSnap?.get("profilePictureURL") as! String
//                let url = NSURL(string: pictureURL)
//                self.downloadImage(url: url! as URL) { (Image) in
//                    if Image != nil{
//                        DispatchQueue.main.async {
//                            self.profileImageView.image = Image
//                        }
//
//                    }
//                    else{
//                        return
//                    }
//                }
//                //self.profileImageView.downloaded(from: pictureURL)
//            }
//        }
//
    
    
    func setupSegmentControllers(cleatPref : String, batting : String, throwing: String){
        if cleatPref == "Low" || cleatPref == ""{
            self.cleatPreferenceSegmentController.selectedSegmentIndex = 0
        }
        else{
            self.cleatPreferenceSegmentController.selectedSegmentIndex = 1
        }
//        if batting == "Right" || batting == ""{
//            self.batsSegmentController.selectedSegmentIndex = 0
//        }
//        else{
//            self.batsSegmentController.selectedSegmentIndex = 1
//        }
//        if throwing == "Right" || throwing == ""{
//            self.throwsSegmentController.selectedSegmentIndex = 0
//        }
//        else{
//            self.throwsSegmentController.selectedSegmentIndex = 1
//        }
        
    }
    
    
//    func dealWithUrl(picURL: String){
//        if picURL != ""{
//            let url = URL(string: picURL)
//            URLSession.shared.dataTask(with: url!) { (data, response, Error) in
//                if Error != nil{
//                    print(Error!)
//                    return
//                }
//                DispatchQueue.global(qos: .userInitiated).async {
//
//                    // Bounce back to the main thread to update the UI
//                    DispatchQueue.main.async {
//                        self.profileImageView.image = UIImage(data: data!)
//                    }
//                }
//            }.resume()
//        }
//    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled Picker")
        dismiss(animated: true, completion: nil)
    }
    
   
//
//    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
//        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
//    }
//
//    func downloadImage(from url: URL, imageView : UIImageView) {
//        print("Download Started")
//        getData(from: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            print("Download Finished")
//            DispatchQueue.main.async() {
//                imageView.image = UIImage(data: data)
//            }
//        }
//    }
    
    
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
         
         if let cachedImage = imagePlayerPictureCache.object(forKey: url.absoluteString as NSString){
             print("in")
             completion(cachedImage)
             
         }
         else{
             URLSession.shared.dataTask(with: url) { (data, response, error) in
                 //download hit an error
                 if error != nil{
                     if let Error = error{
                        DispatchQueue.main.async {
                            self.handleError(Error)
                        }
                         
                     }
                     return
                 }
                 if let pictureData =  data{
                     self.imagePlayerPictureCache.setObject(UIImage(data: pictureData)!, forKey: url.absoluteString as NSString)
                     print("not in")
                     completion(UIImage(data: pictureData))
                 }
                 
                 
                 }.resume()
             
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
