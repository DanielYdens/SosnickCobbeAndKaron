//
//  NewsViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 8/15/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import Alamofire
import SwiftyJSON

class NewsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let imagePostsCache = NSCache<NSString, UIImage>()
    var cachePostImage : UIImage?
    var posts = [Post]()
    var userID = ""
    var token = ""
    var images = [String]()
    
    let params : [String : String] = [ "app_id" : "603532347144383", "app_secret" : "209394f22ff416eff13446598a0df753", "grant_type" : "authorization_code", "redirect_uri": "https://acrobat.adobe.com/us/en", "code" : "AQDXLaJz7jsrRyVFxs1oAtCAg0FqGJtL32pY9vuxQt64G3jP6yeQKkP14MMQUXwrzwn6fh--WoY08QPJgA7a0VnqYVRvm2U6jdWIJuCBU_1_ouluuJnfVHPjtA5kGCVfsPUBNTXo3TbjuCJpt8p7x9LDvrhYqF_OSR4-8u_sgFYxPtSU44TsrA4ODUOH4COyPfzf-KfPfF-7lzN2UcPVFZqfKHEp03KMOWpje4jufjQL4g"
    ]
    
    let codeParams : [String : String] = ["app_id" : "603532347144383", "redirect_uri" : "https://acrobat.adobe.com/us/en", "scope" : "user_profile,user_media", "response_type" : "code"]
        //= Parameters(app_id : "603532347144383", app_secret : "209394f22ff416eff13446598a0df753", grant_type: "authorization_code", redirect_uri: "https://acrobat.adobe.com/us/en", code: "AQC16WoSZFi1_str_9Zpf60gj1Cu9sJj25VeAlH2qdPSNLRoYvY3deWasC9M3QeBOPPcE7obHTwsWKXJhQolaVshXdEF_fp5u6RORh2h-aqoy9X0P9Il1auE96tEaMdlJWeY3A4ytIV7Uwi_ulVDff8rUBMaxeyuGsGX6LsODNkewc9cVsp5bLojJN--6jQ6SfWMEaSFHlC8ns7tgJWyLaWcxWt0LA-8hvGvksZFublrHg")
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
       
        fetchPosts()
        //getInstagramAccessToken()
        
        
        
        // Do any additional setup after loading the view.
    }
    func getImage(id: String){
        let localParams : [String : String] = ["fields" : "id,media_type,media_url", "access_token" : token]
        Alamofire.request("https://graph.instagram.com/\(id)", method: .get, parameters: localParams).validate().responseJSON { (response) in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("JSON: \(json)")
                    let url = json["media_url"].stringValue
                    self.images.append(url)
                    self.collectionView.reloadData()
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
    
    
    
//    func getUserNode(userID : String, accessToken : String) {
//        let localParams : [String : String] = ["fields" : "id,username" , "access_token" : accessToken]
//        var username = ""
//        Alamofire.request("https://graph.instagram.com/\(userID)?fields=id,username&acess_token=\(accessToken)", method: .get, parameters: localParams).validate().responseJSON { (response) in
//            switch response.result {
//                case .success(let value):
//                    let json = JSON(value)
//                    print("JSON: \(json)")
//                    username = json["username"].stringValue
//                    print(username)
//                case .failure(let error):
//                    print(error)
//            }
//        }
//
//
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCell
        //creating the cell
        
       // cell.captionLabel.numberOfLines = 0
        //cell.captionLabel.text = posts[indexPath.row].caption
        
        //cell.postImageView.downdownloaded(from: posts[indexPath.row].URL)
        //let url = NSURL(string: posts[indexPath.row].URL)
        let url = NSURL(string: images[indexPath.row])
        downloadImage(url: url! as URL) { (Image) in
            if Image != nil{
                
                DispatchQueue.main.async {
                    cell.postImageView.image = Image
                }
            
            }
            else{
                return
            }
        }
        cell.postImageView.contentMode = .scaleAspectFill
        
        
        
        
        return cell
    }
    
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
                self.posts.removeAll()
                for document in snapshot!.documents{
                    let currentPost = Post()
                    currentPost.caption = document.get("caption") as? String
                    currentPost.URL = document.get("URL") as? String
                    currentPost.postID =  document.get("postID") as? String
                    self.posts.append(currentPost)
                }
                self.collectionView.reloadData()
            }
        }
    }
    
  
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        
        if let cachedImage = imagePostsCache.object(forKey: url.absoluteString as NSString){
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
                    self.imagePostsCache.setObject(UIImage(data: pictureData)!, forKey: url.absoluteString as NSString)
                    print("not in")
                    completion(UIImage(data: pictureData))
                }
                
                
            }.resume()
            
            }
        }
    
    
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
