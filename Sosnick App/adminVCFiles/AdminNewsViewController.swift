//
//  AdminNewsViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 9/2/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import Alamofire
import SwiftyJSON
import OAuth2




class AdminNewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, AdminPostCellDelegate{
    
    
    
    // NOT CURRENTLY BEING USED IN APP
    let imagePostsCache = NSCache<NSString, UIImage>()
    var newsPosts = [Post]()
    var row: Int = 0
    var userID = ""
    var token = ""
    //var images = [String]()
    var db = Firestore.firestore()
    
    let oauth2 = OAuth2CodeGrantNoTokenType(settings: [
    "client_id": "603532347144383",
    "client_secret": "209394f22ff416eff13446598a0df753",
    "app_id": "603532347144383",
    "app_secret": "209394f22ff416eff13446598a0df753",
    "scope" : "user_profile,user_media",
    "authorize_uri": "https://api.instagram.com/oauth/authorize",
    "token_uri": "https://api.instagram.com/oauth/access_token",
    "response_type": "code",
    "redirect_uris": ["https://acrobat.adobe.com/us/en"],
    "keychain": false,
    "title": "InstagramViewer",
    "secret_in_body" : true
    ] as OAuth2JSON)
    
    //"apexbaseball://oauth/callback"
       
    let params : [String : String] = [ "app_id" : "603532347144383", "app_secret" : "209394f22ff416eff13446598a0df753", "grant_type" : "authorization_code", "redirect_uri": "https://acrobat.adobe.com/us/en", "code" : "AQBc4VbcOCy4fTrvo0_epuL4jRrG555VthSAJ6Y1HB_4KaT0hNKhrx4p8m4WIkPwQGiND3gmJrf9xFkyYRTLizubH-Wk7nVNd8Jq9K_UeJHbvORj7ql_J6UT15fgqgidkWf3TcXI4dpoR2dLzMVvmJDeBI00bxVmeyuB8vG8PFdptLQ672C5QkOFGWFsUY-zIO3r9XSO86r9M50_acwAxWva-bKDZrN0j8JDehMGB3M8YQ"
       ]

    @IBOutlet weak var newsCollectionView: UICollectionView!
    

    @IBAction func syncButtonPressed(_ sender: UIButton) {
        oauth2.logger = OAuth2DebugLogger(.trace)
        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeContext = self
        
        oauth2.authorize(params: ["app_id" : "603532347144383"]) { (json, error) in
            if let JSON = json{
                print("worked!")
                print(JSON)
            }
            else{
                print("error! \(error)")
            }
        }
//        oauth2.authorize(p) { authParameters, erro
       // r in
//            if let params = authParameters {
//                print("Authorized! Access token is in `oauth2.accessToken`")
//                print("Authorized! Additional parameters: \(params)")
//            }
//            else {
//                print("Authorization was canceled or went wrong: \(error)")   // error will not be nil
//            }
//        }
//        self.oauth2.authorizeEmbedded(from: self) { (oauthJSON, oauthError) in
//            if oauthError != nil{
//                print(oauthError)
//            }
//            else{
//                print(oauthJSON)
//            }
//
//        }
//
        
//        let base = URL(string: "https://api.instagram.com")!
//        let url = base.appendingPathComponent("apexbaseball")
//
//        let req = oauth2.request(forURL: url)
//
//        //req.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
//
//        let loader = OAuth2DataLoader(oauth2: oauth2)
//        loader.perform(request: req) { response in
//            do {
//                //let dict = try response.responseJSON()
//
//               // try self.oauth2.doAuthorize(params: nil)
//                DispatchQueue.main.async {
//
//                }
//            }
//            catch let error {
//                DispatchQueue.main.async {
//                    // an error occurred
//                    print(error)
//                }
//            }
//        }
  
        
        
        
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//        let storage = Storage.storage()
//        for post in newsPosts {
//            let storageRef = storage.reference().child("NewsPosts").child("\(post.postID!).jpeg")
//            let Image = imagePostsCache.object(forKey: post.postID as NSString)
//            if let uploadData = Image?.jpegData(compressionQuality: 0.75){
//                    storageRef.putData(uploadData, metadata: metadata) { (metadata, error) in
//                        if error != nil{
//                            if let Error = error {
//                                self.handleError(Error)
//                            }
//                            return
//                        }
//                        _ = storageRef.downloadURL(completion: { (URL, Error) in
//                                if Error != nil {
//                                    print("error getting url")
//                                }
//                                else{
//                                    self.storeInPostDB(URL: URL!.absoluteString)
//                                }
//                        })
//                        print("success")
//                    }
//
//            }
//        }
    }
    
    func storeInPostDB(URL: String){
        let database = Firestore.firestore().collection("posts")
        database.addDocument(data: ["url" : URL]) { (Error) in
            if Error != nil{
                if let error = Error {
                    self.handleError(error)
                }
            }
            else{
                print("success! url stored")
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if self.isConnectedToInternet(){
            //fetchPosts()
            getInstagramAccessToken()
            
        }
        else{
            let alert = UIAlertController(title: "Error", message: "No network connection, please try again", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //checkIfThereIsAnyReminders()
        
        self.newsCollectionView.delegate = self
        self.newsCollectionView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
       
       
        // Do any additional setup after loading the view.
    }
    

    
    func getImage(id: String){
            let localParams : [String : String] = ["fields" : "id,media_type,media_url", "access_token" : token]
            Alamofire.request("https://graph.instagram.com/\(id)", method: .get, parameters: localParams).validate().responseJSON { (response) in
                switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        print("JSON: \(json)")
                        let instagramPost = Post()
                        let url = json["media_url"].stringValue
                        instagramPost.URL = url
                        let imageID = json["id"].stringValue
                        instagramPost.postID = imageID
                        self.newsPosts.append(instagramPost)
                        self.newsCollectionView.reloadData()
                        print("reloaded")
                    case .failure(let error):
                        print(error)
                }
            }
            
        }
        func getMediaList(){
            //getInstagramCode()
          
            let localParams : [String : String] = ["fields" : "id,caption", "access_token" : token]
            Alamofire.request("https://graph.instagram.com/me/media", method: .get, parameters: localParams).validate().responseJSON { (response) in
                       switch response.result {
                           case .success(let value):
                               let json = JSON(value)
                               print("JSON: \(json)")
                               for (key,subJson):(String, JSON) in json["data"] {
                                  // Do something you want
                                //print("ID IS: ", subJson["id"])
                                self.getImage(id: subJson["id"].stringValue)
                               }
                           case .failure(let error):
                               print(error)
                       }
                   }
            
        }
    //    func getInstagramCode()->String{
    //        var code = ""
    //    }
        
        func getInstagramAccessToken(){
            
            
            Alamofire.request("http://api.instagram.com/oauth/access_token", method: .post, parameters: params).validate().responseJSON { (response) in
                switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        print("JSON: \(json)")
                        self.token = json["access_token"].stringValue
                        self.userID = json["user_id"].stringValue
                        //self.getUserNode(userID: userID, accessToken: token)
                        self.getMediaList()
                        print(self.token)
                    case .failure(let error):
                        print(error)
                }
            }
        }
        

    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.newsPosts.count
    }
    
    
//    func optionButtonTapped(cell: AdminPostCell) {
//        let indexPath = self.newsCollectionView.indexPath(for: cell)
//        row = indexPath?.row ?? 0
//        print(indexPath!.row)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as! PopoverViewController
//        vc.delegate = self
//        vc.view.backgroundColor = UIColor.white
//        vc.modalPresentationStyle = .popover
//        vc.preferredContentSize = CGSize(width: 200, height: 55)
//
//        passData(VC: vc)
//     let ppc = vc.popoverPresentationController
//      ppc?.permittedArrowDirections = .any
//       ppc?.delegate = self
//       ppc?.sourceView = cell.optionButton
//
//        present(vc, animated: true, completion: nil)
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "adminPostCell", for: indexPath) as! AdminPostCell
        cell.delegate = self
        //creating the cell
//        cell.captionLabel.numberOfLines = 0
//        cell.captionLabel.text = newsPosts[indexPath.row].caption
        
        let url = NSURL(string: newsPosts[indexPath.row].URL)
        if let postID = newsPosts[indexPath.row].postID {
            downloadImage(id: postID, url: url! as URL) { (Image) in
                if Image != nil{
                    DispatchQueue.main.async {
                        cell.postImageView.image = Image
                    }
                }
                else{
                    return
                }
            }
        }
        
        cell.postImageView.contentMode = .scaleAspectFill
        
     
       
        
        return cell
    }
    

   
 
    
    @IBAction func addPostButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "massComm") as? MassCommunicationViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }

  
//    @IBAction func optionButtonPressed(_ sender: UIButton) {
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as! PopoverViewController
//
//        vc.delegate = self
//        vc.view.backgroundColor = UIColor.white
//        vc.modalPresentationStyle = .popover
//        vc.preferredContentSize = CGSize(width: 200, height: 125)
//
//
//        let ppc = vc.popoverPresentationController
//        ppc?.permittedArrowDirections = .any
//        ppc?.delegate = self
//        ppc?.sourceView = sender
//
//        present(vc, animated: true, completion: nil)
//
//
//    }
    
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        return .none
//    }
    
    
    func fetchPosts(){
        let database = Firestore.firestore()
        
        _ = database.collection("posts").order(by: "timeStamp").getDocuments { (snapshot, error) in
            if error != nil{
                if let Error = error{
                    self.handleError(Error)
                }
                return
            }
            else{
                self.newsPosts.removeAll()
                for document in snapshot!.documents{
                    let currentPost = Post()
                    currentPost.caption = document.get("caption") as? String
                    currentPost.URL = document.get("URL") as? String
                    currentPost.postID =  document.get("postID") as? String
                    self.newsPosts.append(currentPost)
                }
                self.newsCollectionView.reloadData()
            }
        }
    }
    
    
//    func passData(VC : PopoverViewController) {
//        VC.postID = newsPosts[row].postID
//
//    }
    
    @objc func loadList(notification: NSNotification){
        //load data here
        fetchPosts()
    }
    
    
    func downloadImage(id: String, url: URL, completion: @escaping (UIImage?) -> Void) {
        
        if let cachedImage = imagePostsCache.object(forKey: id as NSString){
            print("in")
            completion(cachedImage)
            
        }
        else{
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                //download hit an error
                if error != nil{
                    if let Error = error{
                        self.handleError(Error)
                    }
                    return
                }
                if let pictureData =  data{
                    self.imagePostsCache.setObject(UIImage(data: pictureData)!, forKey: id as NSString)
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
