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
            try Auth.auth().signOut() //if clicked log out signout the user and pop view controller ot root
            navigationController?.popToRootViewController(animated: true)
        }
        catch{
            //print("error: couldnt log out")
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true) //hide nav bar
        currentReq.haveData = false
        if self.isConnectedToInternet(){
            accessData() //if they have internet get data
        }
        else{
            let alert = UIAlertController(title: "Error", message: "No network connection, please try again", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil) //no internet present the alert
        }
        
    }

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor.white
        adminTableView.separatorStyle = .none
        self.hideKeyboardWhenTappedAround()
        //accessData()
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField

        textFieldInsideSearchBar?.backgroundColor = .white
        self.adminTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.adminTableView.dataSource = self
        self.adminTableView.delegate = self //want this view controller to be the delegate and data source fo the table
        self.searchBar.delegate = self
        

        

        // Do any additional setup after loading the view.
    }
    
    func accessData(){
        let db = Firestore.firestore()
        if currentReq.haveData == false{ //if no data
            db.collection("userRequestC").whereField("isProcessed", isEqualTo: false).order(by: "dateNum").getDocuments { (QuerySnapshot //get the documents that arent completed
                , Error) in
                if Error != nil{
                   // print("Error getting docs")
                    self.handleError(Error!)
                }
                else{
                    self.allUserRequests.removeAll() //empty all arrays
                    self.equipmentRequestsOnly.removeAll()
                    self.nonEquipmentRequests.removeAll()
                    for document in QuerySnapshot!.documents{ // for each document
                       // print("THE DATA IS: \(document.data())") //get all request data and put it into currentReq
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
                        if let name = document.get("name") as? String {
                            self.currentReq.name = name
                        }
                        
                        if let status =  document.get("status") as? String{
                            self.currentReq.status =  status
                        }
                        //self.currentReq = Request(category: document.get("category") as? String, description: document.get("description") as? String, date: document.get("date") as? String, isProcessed: document.get("isProcessed") as? Bool, dateNum: document.get("dateNum") as? Int, docID: document.documentID, user: document.get("user") as? String, message: document.get("message") as? Bool, name: document.get("name") as? String)
                        self.allUserRequests.append(self.currentReq) //append current req into the all requests array
                        
                    }
                    self.sortArrayIntoTwo(Array: self.allUserRequests) //sort the array into two
                    self.isInitialized = true //is now initialized
                    self.getUserRole() //get role
                    
                }
            }
        
       }
        
        
    }
    
    //search bar functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if role == "Admin"{ //if general admin
            searchRequest = allUserRequests.filter({$0.name.prefix(searchText.count) == searchText})//allow him to see all user requests in search
            
        }
        else{
            searchRequest = equipmentRequestsOnly.filter({$0.name.prefix(searchText.count) == searchText}) //if equipment admin only allow to see equipment requests in search
        }
        searching = true //is searching
        adminTableView.reloadData() //reload data for search
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false //not searching anymore
        searchBar.text = "" //clear search bar
        view.endEditing(true) //done editting
        adminTableView.reloadData() //reload table
    }
    
    //table view functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.adminTableView.setEmptyMessage("You currently have no active requests!")
        if searching {
            return searchRequest.count //if searching return the number of items in search request array
        }
        else{
            if role == "Admin"{ //if not searching and general admin
                return allUserRequests.count
            }
            else if role == "Equipment Admin"{ //if not searching and equipment admin
                return equipmentRequestsOnly.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        row = indexPath.row //get row
        adminTableView.deselectRow(at: indexPath, animated: true) //if selected row
        performSegue(withIdentifier: "adminGoToInfo", sender: self) //go to info
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.adminTableView.dequeueReusableCell(withIdentifier: "adminRequestCell") as! AdminTableViewCell //use the right cell in storyboard
        cell.backView.layer.cornerRadius = 12
        cell.backView.layer.shadowColor = UIColor(red: 10/255, green: 90/255, blue: 98/255, alpha: 1).cgColor
        cell.backView.layer.shadowOpacity = 0.75
        cell.backView.layer.shadowOffset = .zero
        cell.backView.layer.shadowRadius = 3
        cell.backView.layer.masksToBounds = false
        if isInitialized == true{ //if requests have been grabbed
            if searching { //if currently searching
                cell.adminReq = searchRequest[indexPath.row] //use search request results
            }
            else{ //if not searching
                if role == "Admin" { //if role is admin
                    let request = allUserRequests[indexPath.row] // show all requests
                    cell.adminReq = request
                }
                else if role == "Equipment Admin"{ //if role is equipment admin
                    let request = equipmentRequestsOnly[indexPath.row] //show all equipment requests
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
        if segue.identifier == "adminGoToInfo"{ //information of request screen
            let adminInfoScreen = segue.destination as! AdminRequestInfoViewController
            if searching{ //if searching pass all data of a specific search request row to next screen
                adminInfoScreen.currentRequestState = searchRequest[row].status
                adminInfoScreen.adminCategory = searchRequest[row].category
                adminInfoScreen.adminDate = searchRequest[row].date
                adminInfoScreen.adminDescription = searchRequest[row].description
                adminInfoScreen.userEmail = searchRequest[row].user
                adminInfoScreen.documentID = searchRequest[row].docID
                adminInfoScreen.messageStatus = searchRequest[row].message
                adminInfoScreen.requestStatus = searchRequest[row].status
            }
            else{
                if role == "Admin"{ //if not searching and role is admin pass correct request to next screen through segue
                    adminInfoScreen.currentRequestState = allUserRequests[row].status
                    adminInfoScreen.adminCategory = allUserRequests[row].category
                    adminInfoScreen.adminDate = allUserRequests[row].date
                    adminInfoScreen.adminDescription = allUserRequests[row].description
                    adminInfoScreen.userEmail = allUserRequests[row].user
                    adminInfoScreen.documentID = allUserRequests[row].docID
                    adminInfoScreen.messageStatus = allUserRequests[row].message
                    adminInfoScreen.requestStatus = allUserRequests[row].status
                }
                else{ //if not searching and role is equipment admin pass the correct equipment request info
                    adminInfoScreen.currentRequestState = equipmentRequestsOnly[row].status
                    adminInfoScreen.adminCategory = equipmentRequestsOnly[row].category
                    adminInfoScreen.adminDate = equipmentRequestsOnly[row].date
                    adminInfoScreen.adminDescription = equipmentRequestsOnly[row].description
                    adminInfoScreen.userEmail = equipmentRequestsOnly[row].user
                    adminInfoScreen.documentID = equipmentRequestsOnly[row].docID
                    adminInfoScreen.messageStatus = equipmentRequestsOnly[row].message
                    adminInfoScreen.requestStatus = equipmentRequestsOnly[row].status
                }
            }
           
        }
    }
    
    func sortArrayIntoTwo(Array: [Request]){ //jon wants to handle request that dont involve equipment, other admin will handle equipment req
        //sorts into different arrays
        for req in Array{
            if req.category == "Equipment"{
                equipmentRequestsOnly.append(req)
            }
            else{
                nonEquipmentRequests.append(req)
            }
        }
        nonEquipmentRequests = nonEquipmentRequests.reversed()
    }
    
    func getUserRole(){
        let userDatabase = Firestore.firestore()
        if let uid = Auth.auth().currentUser?.uid{
            let documentRef = userDatabase.collection("users").document(uid) //goes into user DB
            documentRef.getDocument { (snapshot, Error) in
                if Error != nil{
                    if let error = Error{
                        self.handleError(error)
                    }
                    return
                }
                else{
                    self.role = snapshot?.get("Role") as! String //get correct user and get their role
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
