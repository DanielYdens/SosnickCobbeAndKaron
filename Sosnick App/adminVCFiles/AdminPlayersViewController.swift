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
    
    
    var players = [Player]()
    var searchName = [Player]()
    var database = Firestore.firestore()
    var row : Int = 0
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playersTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        searchBar.delegate = self
        playersTable.delegate = self
        playersTable.dataSource = self
        getPlayers()
        // Do any additional setup after loading the view.
    }
    //search bar functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchName = players.filter({$0.name.prefix(searchText.count) == searchText})
        searching = true
        playersTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        view.endEditing(true)
        playersTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
    
        if editingStyle == .delete {
            let cancelAlert = UIAlertController(title: "Are You sure?", message: "This will permanently delete this user.", preferredStyle: UIAlertController.Style.alert)
            
            cancelAlert.addAction(UIAlertAction(title: "Yes, I'm sure", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
                //            self.addToDeleted()
                if self.searching{
    
                   // need to delete the auth version of the user now too
                    self.removeUsersRequests(UID: self.searchName[indexPath.row].uid)
                    self.database.collection("users").document(self.searchName[indexPath.row].uid).delete { (err) in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                            self.searchName.remove(at: indexPath.row)
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
                            print("Document successfully removed!")
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
            
            present(cancelAlert, animated: true, completion: nil)

        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return searchName.count
        }
        else{
            return players.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let playerCell = self.playersTable.dequeueReusableCell(withIdentifier: "PlayerCell") as! PlayersTableViewCell
        if searching { //if searching bring use the new array
            playerCell.name.text = searchName[indexPath.row].name
            if searchName[indexPath.row].profilePicURL != ""{
                playerCell.profilePicImageView.downloaded(from: searchName[indexPath.row].profilePicURL)
                playerCell.profilePicImageView.roundedImage()
            }
            else{
                playerCell.profilePicImageView.image = UIImage(named: "addProfilePicture")
            }
        }
        else{
            playerCell.name.text = players[indexPath.row].name
            if players[indexPath.row].profilePicURL != ""{
                playerCell.profilePicImageView.downloaded(from: players[indexPath.row].profilePicURL)
                playerCell.profilePicImageView.roundedImage()
            }
            else{
                playerCell.profilePicImageView.image = UIImage(named: "addProfilePicture")
            }
        }
        return playerCell
        
    }
    
    func getPlayers(){
        database.collection("users").whereField("Role", isEqualTo: "Player").getDocuments { (snapshot, Error) in
            if Error != nil{
                print(Error!)
                return
            }
            else{
                for document in snapshot!.documents{
                    let currentPlayer =  Player()
                    currentPlayer.uid = document.documentID
                    currentPlayer.name = document.get("First") as? String
                    currentPlayer.name += " "
                    currentPlayer.name += document.get("last") as? String ?? ""
                    currentPlayer.profilePicURL = document.get("profilePictureURL") as? String
                    self.players.append(currentPlayer)
                }
            }
            self.playersTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playersTable.deselectRow(at: indexPath, animated: true)
        row = indexPath.row
        performSegue(withIdentifier: "showPlayerProfile", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayerProfile"{
            let nextVC = segue.destination as! PlayerProfileInfoViewController
            if searching{
                nextVC.uid =  searchName[row].uid
                nextVC.profilePicURL = searchName[row].profilePicURL
            }
            else{
                nextVC.uid =  players[row].uid
                nextVC.profilePicURL = players[row].profilePicURL
            }
        }
    }
    
    func removeUsersRequests(UID: String){
        database.collection("userRequestB").whereField("uid", isEqualTo: UID).getDocuments { (snapshot, error) in
            if error != nil{
                print(error!)
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
    /*
    // MARK: - Navigation""

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */




}
