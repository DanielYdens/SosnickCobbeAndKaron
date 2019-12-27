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

    var urlArray = [String]()
    
  
    
   
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
       
        //fetchPosts()
        //getInstagramAccessToken()
        getImageURLSFromStorage()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func getImageURLSFromStorage(){
        let db = Firestore.firestore()
        db.collection("posts").getDocuments { (snapshot, Error) in
            if Error != nil{
                if let error = Error {
                    self.handleError(error)
                }
            }
            else{
                self.urlArray.removeAll()
                for document in snapshot!.documents {
                    if let url = document.get("url") as? String{
                        self.urlArray.append(url)
                    }
                }
                self.collectionView.reloadData()
            }
        }
        
    }
   
    
//    func getInstagramCode()->String{
//        var code = ""
//    }
    

    
    
    
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
        return self.urlArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCell
        //creating the cell
        
       // cell.captionLabel.numberOfLines = 0
        //cell.captionLabel.text = posts[indexPath.row].caption
        
        //cell.postImageView.downdownloaded(from: posts[indexPath.row].URL)
        //let url = NSURL(string: posts[indexPath.row].URL)
        let url = NSURL(string: urlArray[indexPath.row])
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
