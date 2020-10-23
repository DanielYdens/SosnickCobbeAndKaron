 //
//  SecondViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 6/18/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
 
 class SecondViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    

    var uid = ""
    let db = Firestore.firestore()
    var userData: [Request] = []
    var currentReq = Request()
    var isInitialized = false
    var row = 0
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
 
    
    @IBOutlet weak var table: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.separatorStyle = .none
        self.view.subviews.forEach { $0.isHidden = true }
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            activityIndicator.style = UIActivityIndicatorView.Style.white
        } else {
            // Fallback on earlier versions
        }
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        checkUser()
        //checkDatabase()
       
        // Do any additional setup after loading the view.
        
        self.table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.table.dataSource = self
        self.table.delegate = self
        self.title = "Requests"
        
        //view.addBackground(imageName: "baseballborder", contentMode: .scaleAspectFill)

        //retrieveNewRequests()
        
    }
    
    func checkUser(){
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                uid = user.uid
                checkDatabase()
            }
        } else{
            print("not logged in")
        }
    }
    
    func checkDatabase(){
        print(uid)
        print("went")
        if currentReq.haveData == false {
            db.collection("userRequestC").whereField("uid", isEqualTo: uid).whereField("isProcessed", isEqualTo: false).order(by: "dateNum").addSnapshotListener{ (querySnapshot,
                Error) in
                if Error != nil{
                    print("error getting docs")
                }
                else{
                    self.userData.removeAll()
                    for document in querySnapshot!.documents{
                        //print("\(document.documentID) => \(document.data())")
                        self.currentReq = Request()
                        
                        if let category = document.get("category") as? String {
                            self.currentReq.category = category
                        }
                        if let description = document.get("description") as? String {
                            self.currentReq.description = description
                        }
                        if let date = document.get("date") as? String {
                            self.currentReq.date = date
                        }
                        if let isProcessed = document.get("isProcessed") as? Bool {
                            self.currentReq.isProcessed = isProcessed
                        }
                        if let dateNum = document.get("dateNum") as? Int {
                            self.currentReq.dateNum = dateNum
                        }
                        self.currentReq.docID = document.documentID
                        if let user = document.get("user") as? String {
                            self.currentReq.user = user
                        }
                        if let message = document.get("message") as? Bool {
                            self.currentReq.message = message
                        }
                        if let status =  document.get("status") as? String{
                            self.currentReq.status = status
                        }
                        //self.currentReq = Request(category: document.get("category") as! String, description: document.get("description") as! String, date: document.get("date") as! String, isProcessed: document.get("isProcessed") as! Bool, dateNum: document.get("dateNum") as! Int, docID: document.documentID, user: document.get("user") as! String, message: document.get("message") as! Bool)
                        self.currentReq.haveData = true
                        self.userData.append(self.currentReq)
                        
                        }
                    }
                    self.stopActivityIndicator()
                    self.isInitialized = true
                    self.table.reloadData()
                
                }
            
            
            }
        }
        //need to change to requests -> documents -> field uid
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        row = indexPath.row
        table.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToInfo", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if userData.count == 0 {
            self.table.setEmptyMessage("You currently have no active requests! Click the plus button below to submit a new request!")
        } else {
            self.table.restore()
        }

        return userData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.table.dequeueReusableCell(withIdentifier: "RequestTableViewCell") as! RequestTableViewCell
        if isInitialized == true{
            
            cell.contentView.backgroundColor = UIColor.white// make it go edge to edge
            cell.backView.layer.cornerRadius = 12
            cell.backView.layer.shadowColor = UIColor(red: 10/255, green: 90/255, blue: 98/255, alpha: 1).cgColor
            cell.backView.layer.shadowOpacity = 0.75
            cell.backView.layer.shadowOffset = .zero
            cell.backView.layer.shadowRadius = 3
            cell.backView.layer.masksToBounds = false
            
            //var test: String = userData[0].category as! String
    //        print("displaying table")
    //        print(currentReq.date)
            let request =  userData[indexPath.row]
            cell.request = request //filling in table view with request data
           
            return cell
        }
        return cell
    }
    

    func stopActivityIndicator() {
      self.view.subviews.forEach { $0.isHidden = false }
      self.activityIndicator.stopAnimating()
      self.view.isUserInteractionEnabled = true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToRequest"{
//            let nextVC = segue.destination as! RequestViewController
//            nextVC.userUID = uid
//        }
        if segue.identifier == "goToInfo"{
            let theNextVC = segue.destination as! InfoViewController
            theNextVC.reqCategory = userData[row].category
            theNextVC.reqDescription = userData[row].description
            theNextVC.reqDate = userData[row].date
            theNextVC.reqNum = userData[row].dateNum
            theNextVC.docID = userData[row].docID
            theNextVC.isMessagesCreated = userData[row].message
            
        }
        
        
        
    }
    
//    func retrieveNewRequests(){
//        if isInitialized == true{
//        db.collection("requests").whereField("uid", isEqualTo: uid).addSnapshotListener { (QuerySnapshot
//            , Error) in
//            if QuerySnapshot!.isEmpty {
//                print("no data")
//            }
//            else {
//
//                for document in QuerySnapshot!.documents{
//                    var newRequest = Request(category: document.get("category") as! String, description: document.get("description") as! String, date: document.get("date") as! String, isProcessed: document.get("isProcessed") as! String)
//                    self.userData.append(newRequest)
//                }
//                self.table.reloadData()
//            }
//            }
//        }
    
    
    
//        db.collection("requests").wherefiredocument("SF")
//            .addSnapshotListener { documentSnapshot, error in
//                guard let document = documentSnapshot else {
//                    print("Error fetching document: \(error!)")
//                    return
//                }
//                guard let data = document.data() else {
//                    print("Document data was empty.")
//                    return
//                }
//                print("Current data: \(data)")
//        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


