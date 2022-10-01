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
//import Alamofire

class NewsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let imagePostsCache = NSCache<NSString, UIImage>()
    var cachePostImage : UIImage?
    var posts = [Post]()
    
    struct Parameters : Encodable {
        let app_id : String
        let app_secret : String
        let grant_type : String
        let redirect_uri : String
        let code : String
        
    }
    
    let parameters = Parameters(app_id : "app_id=603532347144383", app_secret : "app_secret=209394f22ff416eff13446598a0df753", grant_type: "grant_type=authorization_code", redirect_uri: "redirect_uri=https://acrobat.adobe.com/us/en", code: "code=AQC16WoSZFi1_str_9Zpf60gj1Cu9sJj25VeAlH2qdPSNLRoYvY3deWasC9M3QeBOPPcE7obHTwsWKXJhQolaVshXdEF_fp5u6RORh2h-aqoy9X0P9Il1auE96tEaMdlJWeY3A4ytIV7Uwi_ulVDff8rUBMaxeyuGsGX6LsODNkewc9cVsp5bLojJN--6jQ6SfWMEaSFHlC8ns7tgJWyLaWcxWt0LA-8hvGvksZFublrHg")
    
//    Alamofire.request("https://httpbin.org/post",
//               method: .post,
//               parameters: login,
//               encoder: JSONParameterEncoder.default).response { response in
//        debugPrint(response)
//    }
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
       
        fetchPosts()
        
        // Do any additional setup after loading the view.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCell
        //creating the cell
        cell.backgroundColor = UIColor(red: 6/255, green: 91/255, blue: 99/255, alpha: 1)
        
        
        //cell.postImageView.downdownloaded(from: posts[indexPath.row].URL)
        let url = NSURL(string: posts[indexPath.row].URL)
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
