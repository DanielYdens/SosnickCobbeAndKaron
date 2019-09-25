//
//  CancelledRequestsViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 8/15/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class CompletedRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var table: UITableView!
    var uid : String  = ""
    var completedUserData : [Request] = []
    var currentRequest = Request()
    var isInitialized = false
    var row = 0
    let database = Firestore.firestore()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completedUserData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.table.dequeueReusableCell(withIdentifier: "CompletedRequestCell") as! CompletedRequestsTableViewCell
        if isInitialized == true{
            
            //var test: String = userData[0].category as! String
            //        print("displaying table")
            //        print(currentReq.date)
            let request =  completedUserData[indexPath.row]
           
            cell.request = request //filling in table view with request data
            
            return cell
        }
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationBar.isHidden = false

    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        checkUser()
        
        self.table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.table.dataSource = self
        self.table.delegate = self
        // Do any additional setup after loading the view.
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
        
        if currentRequest.haveData == false {
            database.collection("userRequestB").whereField("uid", isEqualTo: uid).whereField("isProcessed", isEqualTo: true).order(by: "dateNum").addSnapshotListener{ (querySnapshot,
                Error) in
                if Error != nil{
                    print("error getting docs")
                }
                else{
                    self.completedUserData.removeAll()
                    for document in querySnapshot!.documents{
                        print("\(document.documentID) => \(document.data())")
                        self.currentRequest = Request()
                        if let category = document.get("category") as? String {
                            self.currentRequest.category = category
                        }
                        if let description = document.get("description") as? String {
                            self.currentRequest.description = description
                        }
                        if let date = document.get("date") as? String {
                            self.currentRequest.date = date
                        }
                        if let isProcessed = document.get("isProcessed") as? Bool {
                            self.currentRequest.isProcessed = isProcessed
                        }
                        if let dateNum = document.get("dateNum") as? Int {
                            self.currentRequest.dateNum = dateNum
                        }
                        self.currentRequest.docID = document.documentID
                        if let user = document.get("user") as? String {
                            self.currentRequest.user = user
                        }
                        if let message = document.get("message") as? Bool {
                            self.currentRequest.message = message
                        }
                        //self.currentRequest = Request(category: document.get("category") as! String, description: document.get("description") as! String, date: document.get("date") as! String, isProcessed: document.get("isProcessed") as! Bool, dateNum: document.get("dateNum") as! Int, docID: document.documentID, user: document.get("user") as! String, message: document.get("message") as! Bool)
                        self.currentRequest.haveData = true
                        self.completedUserData.append(self.currentRequest)
                        
                    }
                }
                self.isInitialized = true
                self.table.reloadData()
                
                
            }
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
