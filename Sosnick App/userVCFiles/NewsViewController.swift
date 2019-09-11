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

class NewsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
    var posts = [Post]()
   
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
        cell.captionLabel.numberOfLines = 0
        cell.captionLabel.text = posts[indexPath.row].caption
        
        cell.postImageView.downloaded(from: posts[indexPath.row].URL)
        cell.postImageView.contentMode = .scaleAspectFill
        
        
        
        
        return cell
    }
    
    func fetchPosts(){
        let database = Firestore.firestore()
        
        _ = database.collection("posts").order(by: "timeStamp").getDocuments { (snapshot, error) in
            if error != nil{
                print(error!)
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
