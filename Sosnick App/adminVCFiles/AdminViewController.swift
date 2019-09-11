//
//  AdminViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 7/14/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class AdminViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var adminTableView: UITableView!
    
    var searchRequest : [Request] = []
    var allUserRequests : [Request] = []
    var equipmentRequestsOnly : [Request] = []
    var nonEquipmentRequests : [Request] = []
    var currentReq = Request()
    var isInitialized = false
    var row = 0
    var role : String = ""
    var searching = false
    
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch{
            print("error: couldnt log out")
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
//        accessData()
    }

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accessData()
        
        self.adminTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.adminTableView.dataSource = self
        self.adminTableView.delegate = self
        self.searchBar.delegate = self
        

        

        // Do any additional setup after loading the view.
    }
    
    func accessData(){
        let db = Firestore.firestore()
       if currentReq.haveData == false{
        db.collection("userRequestB").whereField("isProcessed", isEqualTo: false).order(by: "dateNum").addSnapshotListener { (QuerySnapshot
            , Error) in
            if Error != nil{
                print("Error getting docs")
            }
            else{
                self.allUserRequests.removeAll()
                self.equipmentRequestsOnly.removeAll()
                self.nonEquipmentRequests.removeAll()
                for document in QuerySnapshot!.documents{
                    print("THE DATA IS: \(document.data())")
                    self.currentReq = Request(category: document.get("category") as! String, description: document.get("description") as! String, date: document.get("date") as! String, isProcessed: document.get("isProcessed") as! Bool, dateNum: document.get("dateNum") as! Int, docID: document.documentID, user: document.get("user") as! String, message: document.get("message") as! Bool, name: document.get("name") as! String)
                    self.allUserRequests.append(self.currentReq)
                    
                }
                self.sortArrayIntoTwo(Array: self.allUserRequests)
                self.isInitialized = true
                self.getUserRole()
                
            }
        }
        
       }
        
    }
    
    //search bar functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if role == "Admin"{
            searchRequest = nonEquipmentRequests.filter({$0.name.prefix(searchText.count) == searchText})
            
        }
        else{
            searchRequest = equipmentRequestsOnly.filter({$0.name.prefix(searchText.count) == searchText})
        }
        searching = true
        adminTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        view.endEditing(true)
        adminTableView.reloadData()
    }
    
    //table view functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchRequest.count
        }
        else{
            if role == "Admin"{
                return nonEquipmentRequests.count
            }
            else if role == "Equipment Admin"{
                return equipmentRequestsOnly.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        row = indexPath.row
        adminTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "adminGoToInfo", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.adminTableView.dequeueReusableCell(withIdentifier: "adminRequestCell") as! AdminTableViewCell
        
        if isInitialized == true{
            if searching {
                cell.adminReq = searchRequest[indexPath.row]
            }
            else{
                if role == "Admin" {
                    let request = nonEquipmentRequests[indexPath.row]
                    cell.adminReq = request
                }
                else if role == "Equipment Admin"{
                    let request = equipmentRequestsOnly[indexPath.row]
                    cell.adminReq = request
                }
            }
            //var test: String = userData[0].category as! String
            //        print("displaying table")
            //        print(currentReq.date)
            
            
            //filling in table view with request data
            
            return cell
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adminGoToInfo"{
            let adminInfoScreen = segue.destination as! AdminRequestInfoViewController
            if searching{
                adminInfoScreen.adminCategory = searchRequest[row].category
                adminInfoScreen.adminDate = searchRequest[row].date
                adminInfoScreen.adminDescription = searchRequest[row].description
                adminInfoScreen.userEmail = searchRequest[row].user
                adminInfoScreen.documentID = searchRequest[row].docID
                adminInfoScreen.messageStatus = searchRequest[row].message
            }
            else{
                if role == "Admin"{
                    adminInfoScreen.adminCategory = nonEquipmentRequests[row].category
                    adminInfoScreen.adminDate = nonEquipmentRequests[row].date
                    adminInfoScreen.adminDescription = nonEquipmentRequests[row].description
                    adminInfoScreen.userEmail = nonEquipmentRequests[row].user
                    adminInfoScreen.documentID = nonEquipmentRequests[row].docID
                    adminInfoScreen.messageStatus = nonEquipmentRequests[row].message
                }
                else{
                    adminInfoScreen.adminCategory = equipmentRequestsOnly[row].category
                    adminInfoScreen.adminDate = equipmentRequestsOnly[row].date
                    adminInfoScreen.adminDescription = equipmentRequestsOnly[row].description
                    adminInfoScreen.userEmail = equipmentRequestsOnly[row].user
                    adminInfoScreen.documentID = equipmentRequestsOnly[row].docID
                    adminInfoScreen.messageStatus = equipmentRequestsOnly[row].message
                }
            }
           
        }
    }
    
    func sortArrayIntoTwo(Array: [Request]){ //jon wants to handle request that dont involve equipment, other admin will handle equipment req
        for req in Array{
            if req.category == "Equipment"{
                equipmentRequestsOnly.append(req)
            }
            else{
                nonEquipmentRequests.append(req)
            }
        }
        equipmentRequestsOnly = equipmentRequestsOnly.reversed()
        nonEquipmentRequests = nonEquipmentRequests.reversed()
    }
    
    func getUserRole(){
        let userDatabase = Firestore.firestore()
        if let uid = Auth.auth().currentUser?.uid{
            let documentRef = userDatabase.collection("users").document(uid)
            documentRef.getDocument { (snapshot, Error) in
                if Error != nil{
                    print(Error!)
                    return
                }
                else{
                    self.role = snapshot?.get("Role") as! String
                    self.adminTableView.reloadData()
                   
                    
                }
            }
        } else{
            return
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
