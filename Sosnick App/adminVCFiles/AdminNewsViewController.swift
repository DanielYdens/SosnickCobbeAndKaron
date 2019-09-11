//
//  AdminNewsViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 9/2/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AdminNewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverPresentationControllerDelegate, PopoverViewControllerDelegate, AdminPostCellDelegate{
    
    
    
 
    var newsPosts = [Post]()
    var row: Int = 0

    @IBOutlet weak var newsCollectionView: UICollectionView!
    

    override func viewDidAppear(_ animated: Bool) {
        fetchPosts()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newsCollectionView.delegate = self
        self.newsCollectionView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
       
        // Do any additional setup after loading the view.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.newsPosts.count
    }
    
    func optionButtonTapped(cell: AdminPostCell) {
        let indexPath = self.newsCollectionView.indexPath(for: cell)
        row = indexPath?.row ?? 0
        print(indexPath!.row)
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as! PopoverViewController
        vc.delegate = self
        vc.view.backgroundColor = UIColor.white
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 200, height: 55)
        
        passData(VC: vc)
        let ppc = vc.popoverPresentationController
        ppc?.permittedArrowDirections = .any
        ppc?.delegate = self
        ppc?.sourceView = cell.optionButton
    
        present(vc, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "adminPostCell", for: indexPath) as! AdminPostCell
        cell.delegate = self
        //creating the cell
        cell.captionLabel.numberOfLines = 0
        cell.captionLabel.text = newsPosts[indexPath.row].caption
        
        cell.postImageView.downloaded(from: newsPosts[indexPath.row].URL)
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
    func fetchPosts(){
        let database = Firestore.firestore()
        
        _ = database.collection("posts").order(by: "timeStamp").getDocuments { (snapshot, error) in
            if error != nil{
                print(error!)
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
    
    
    func passData(VC : PopoverViewController) {
        VC.postID = newsPosts[row].postID
       
    }
    
    @objc func loadList(notification: NSNotification){
        //load data here
        fetchPosts()
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
