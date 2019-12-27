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

class AdminNewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, AdminPostCellDelegate{
    
    
    // NOT CURRENTLY BEING USED IN APP
    let imagePostsCache = NSCache<NSString, UIImage>()
    var newsPosts = [Post]()
    var row: Int = 0
    var userID = ""
    var token = ""
    //var images = [String]()
    var db = Firestore.firestore()
       
    let params : [String : String] = [ "app_id" : "603532347144383", "app_secret" : "209394f22ff416eff13446598a0df753", "grant_type" : "authorization_code", "redirect_uri": "https://acrobat.adobe.com/us/en", "code" : "AQByhVoZU4F680DG02dWic1611LHPhenG3fBnIP_7IyRrDZ5nAnJ7YCyEukkBtl4QTm0cW7s1Rw4_2iO5089uH1QyUgvLKaiPGe_Q2er7j63vMKkxQy0rSkaHLMUMWT1uiUbE5JHwhOqi6Y6VX-FaeLSdGDiVcsgr0ktFOHtXIuYNlWsJsb2ME9yI_rT6DXY8oNXYapVqgUbghschynon5Y_1w1cTESbEc9IM_uhK5Vg5A"
       ]

    @IBOutlet weak var newsCollectionView: UICollectionView!
    

    @IBAction func syncButtonPressed(_ sender: UIButton) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let storage = Storage.storage()
        for post in newsPosts {
            let storageRef = storage.reference().child("NewsPosts").child("\(post.postID!).jpeg")
            let Image = imagePostsCache.object(forKey: post.postID as NSString)
            if let uploadData = Image?.jpegData(compressionQuality: 0.75){
                    storageRef.putData(uploadData, metadata: metadata) { (metadata, error) in
                        if error != nil{
                            if let Error = error {
                                self.handleError(Error)
                            }
                            return
                        }
                        print("success")
                    }
                                     
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
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "uploadPosts") as? UploadToSocialViewController
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
