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
 
  

   
    

  
    
    @IBOutlet weak var table: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            db.collection("userRequestB").whereField("uid", isEqualTo: uid).whereField("isProcessed", isEqualTo: false).order(by: "dateNum").addSnapshotListener{ (querySnapshot,
                Error) in
                if Error != nil{
                    print("error getting docs")
                }
                else{
                    self.userData.removeAll()
                    for document in querySnapshot!.documents{
                        print("\(document.documentID) => \(document.data())")
                        self.currentReq = Request(category: document.get("category") as! String, description: document.get("description") as! String, date: document.get("date") as! String, isProcessed: document.get("isProcessed") as! Bool, dateNum: document.get("dateNum") as! Int, docID: document.documentID, user: document.get("user") as! String, message: document.get("message") as! Bool)
                        self.currentReq.haveData = true
                        self.userData.append(self.currentReq)
                        
                        }
                    }
                    self.isInitialized = true
                    self.table.reloadData()
                    self.printAllInArray(Array: self.userData)
                
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
        return userData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.table.dequeueReusableCell(withIdentifier: "RequestCell") as! RequestTableViewCell
        if isInitialized == true{
            
            //var test: String = userData[0].category as! String
    //        print("displaying table")
    //        print(currentReq.date)
            let request =  userData[indexPath.row]
            printAllInArray(Array: userData)
            cell.request = request //filling in table view with request data
           
            return cell
        }
        return cell
    }
    
    func printAllInArray(Array: [Request]){
        for reqs in Array{
            printRequest(Request: reqs)
        }
    }
   
    func printRequest(Request : Request){
        print(Request.category)
        print(Request.date)
        print(Request.description)
        print(Request.isProcessed)
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


