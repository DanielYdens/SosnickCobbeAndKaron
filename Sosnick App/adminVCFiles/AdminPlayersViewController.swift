//
//  AdminPlayersViewController.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 8/28/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class AdminPlayersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var playersTable: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let imagePlayerPictureCache = NSCache<NSString, UIImage>()
    var players = [Player]()
    var searchName = [Player]()
    var database = Firestore.firestore()
    var row : Int = 0
    var searching = false
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isConnectedToInternet(){ //if connected to the internet, get the players
            getPlayers()
        }
        else{ //if not connected present an error alert
            let alert = UIAlertController(title: "Error", message: "No network connection, please try again", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playersTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell") //register correct cell
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField

        textFieldInsideSearchBar?.backgroundColor = .white
        searchBar.delegate = self //setup
        playersTable.delegate = self
        playersTable.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    //search bar functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchName = players.filter({$0.name.prefix(searchText.count) == searchText}) //filter through players and get all those who fit the search
        searching = true //shows user is currently searching
        playersTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false //not searching anymore
        searchBar.text = "" //clear
        view.endEditing(true) //no editting
        playersTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
    
        if editingStyle == .delete { //if admin swipes and tries to delete a user
            let cancelAlert = UIAlertController(title: "Are You sure?", message: "This will permanently delete this user.", preferredStyle: UIAlertController.Style.alert)
            
            cancelAlert.addAction(UIAlertAction(title: "Yes, I'm sure", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here") //present a alert asking if they really want to go through with it
                //            self.addToDeleted()
                if self.searching{ //if searching and they clicked yes on alert
    
                   // need to delete the auth version of the user now too
                    self.removeUsersRequests(UID: self.searchName[indexPath.row].uid)
                    self.database.collection("users").document(self.searchName[indexPath.row].uid).delete { (err) in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                            self.searchName.remove(at: indexPath.row) //delete user
                            self.playersTable.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                    
                }
                else{
                    self.removeUsersRequests(UID: self.players[indexPath.row].uid)
                    self.database.collection("users").document(self.players[indexPath.row].uid).delete { (err) in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!") //deleting user
                            self.players.remove(at: indexPath.row)
                            self.playersTable.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                }
                self.playersTable.reloadData()
                
            }))
            
            cancelAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            present(cancelAlert, animated: true, completion: nil) //present the alert

        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return searchName.count //if searching present the search array
        }
        else{
            return players.count //if not then just present the normal players array
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let playerCell = self.playersTable.dequeueReusableCell(withIdentifier: "PlayerCell") as! PlayersTableViewCell
        if searching { //if searching use the searching array
            playerCell.name.text = searchName[indexPath.row].name
            if searchName[indexPath.row].profilePicURL != ""{ //if profile picture url exists
                
                let url = NSURL(string: searchName[indexPath.row].profilePicURL)
                downloadImage(url: url! as URL) { (Image) in
                    if Image != nil{
                        DispatchQueue.main.async {
                             playerCell.profilePicImageView.image = Image //show profile picture
                        }
                        
                    }
                    else{
                        return
                    }
                }
                playerCell.profilePicImageView.roundedImage()
            }
            else{
                playerCell.profilePicImageView.image = UIImage(named: "addProfilePicture")
            }
        }
        else{ //similar to above but not searching so you use the players array
            playerCell.name.text = players[indexPath.row].name
            if players[indexPath.row].profilePicURL != ""{
                
                
                let url = NSURL(string: players[indexPath.row].profilePicURL)
                downloadImage(url: url! as URL) { (Image) in
                    if Image != nil{
                        DispatchQueue.main.async {
                            playerCell.profilePicImageView.image = Image
                        }
                        
                    }
                    else{
                        return
                    }
                    }
                playerCell.profilePicImageView.roundedImage()
            }
            else{
                playerCell.profilePicImageView.image = UIImage(named: "addProfilePicture")
            }
        }
        return playerCell
        
    }
    
    func getPlayers(){
        database.collection("users").whereField("Role", isEqualTo: "Player").getDocuments { (snapshot, Error) in //go into the user DB and grab all the players documents
            if Error != nil{
                if let error = Error{
                    self.handleError(error)
                }
                return
            }
            else{
                self.players.removeAll()
                for document in snapshot!.documents{
                    let currentPlayer =  Player() //load player into array
                    currentPlayer.uid = document.documentID
                    currentPlayer.name = document.get("First") as? String
                    currentPlayer.name += " "
                    currentPlayer.name += document.get("last") as? String ?? ""
                    currentPlayer.profilePicURL = document.get("profilePictureURL") as? String
                    self.players.append(currentPlayer)
                }
            }
            self.playersTable.reloadData() //refresh data
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playersTable.deselectRow(at: indexPath, animated: true)
        row = indexPath.row //if clicked a specific player go to their profile
        performSegue(withIdentifier: "showPlayerProfile", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayerProfile"{
            let nextVC = segue.destination as! PlayerProfileInfoViewController
            if searching{//if searching, passing data from search name array
                nextVC.uid =  searchName[row].uid
                nextVC.profilePicURL = searchName[row].profilePicURL
            }
            else{ //if not searching, passing data from normal player array
                nextVC.uid =  players[row].uid
                nextVC.profilePicURL = players[row].profilePicURL
            }
        }
    }
    
    func removeUsersRequests(UID: String){
        database.collection("userRequestC").whereField("uid", isEqualTo: UID).getDocuments { (snapshot, error) in //go into user array where the uid matches UID and delete the documents for them
            if error != nil{
                if let Error = error{
                    self.handleError(Error)
                }
                return
            }
            else{
                for document in snapshot!.documents{
                    document.reference.delete(completion: { (error) in
                        if let error = error {
                            print("Error removing document: \(error)")
                        } else {
                            print("Document successfully removed!")
                         
                        }
                    })
                }
            }
        }
        
    }
    
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        
        if let cachedImage = imagePlayerPictureCache.object(forKey: url.absoluteString as NSString){ //if already in the image cache
            print("in")
            completion(cachedImage)
            
        }
        else{ //if not already in the cache
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                //download hit an error
                if error != nil{
                    if let Error = error{
                        self.handleError(Error)
                    }
                    return
                }
                if let pictureData =  data{
                    self.imagePlayerPictureCache.setObject(UIImage(data: pictureData)!, forKey: url.absoluteString as NSString) //get data for picture and put it in the cache
                    print("not in")
                    completion(UIImage(data: pictureData))
                }
                
                
                }.resume()
            
        }
    }
    /*
    // MARK: - Navigation""

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */




}
