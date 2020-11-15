//
//  ApexBlogViewController.swift
//  Apex Baseball
//
//  Created by Daniel Ydens on 9/8/20.
//  Copyright © 2020 Daniel Ydens. All rights reserved.
//

import UIKit
import WebKit
import FirebaseFirestore
import FirebaseAuth


class ApexBlogViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    let uid =  Auth.auth().currentUser!.uid
    var current : Int = 0
    var messages : [massMessage] = []
    
    override func viewDidAppear(_ animated: Bool) {
        checkIfThereIsAnyReminders()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBlog()
        // Do any additional setup after loading the view.
    }
    
    func loadBlog() {
        let url = URL(string: "https://www.apexbaseball.com/apex-blog")!
        webView.load(URLRequest(url: url))
    }

    @IBAction func notificationButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToNotifs", sender: self)
    }
    
    func checkIfThereIsAnyReminders(){
            self.current = 0
            var lastViewed : String = ""
            Firestore.firestore().collection("users").document(uid).getDocument(completion: { (snapshot, error) in
                if let Error = error {
                    self.handleError(Error)
                }
                else{
                    if let lastViewedMC = snapshot?.get("lastViewedMC") as? String {
                        lastViewed =  lastViewedMC
                        Firestore.firestore().collection("massCommunication").order(by: "timeStamp").getDocuments { (snapshot, error) in
                            if let Error = error{
                                self.handleError(Error)
                            }
                            if (lastViewed == "") {
                                //var count = 0
                                self.messages.removeAll()
                                for document in snapshot!.documents {
                                    let currentMessage = massMessage()
                                    currentMessage.title = document.get("title") as? String
                                    currentMessage.message = document.get("message") as? String
                                    currentMessage.docID = document.documentID
                                    self.messages.append(currentMessage)
                                }
                                
                                self.presentAlert()
                            }
                            else{
                                var found = false
                                self.messages.removeAll()
                                for document in snapshot!.documents{
                                    
                                    if document.documentID == lastViewed{
                                        found = true
                                        continue
    
                                    }
                                    if (found){
                                        let currentMessage = massMessage()
                                        currentMessage.title = document.get("title") as? String
                                        currentMessage.message = document.get("message") as? String
                                        currentMessage.docID = document.documentID
                                        self.messages.append(currentMessage)
                                    }
                                }
                                if(self.messages.count > 0){
                                    self.presentAlert()
                                }
                            }
                        }
                    }
                }
            })
                
            
            
        }
    
    func presentAlert(){
        if (messages.count > 0){
            let refreshAlert = UIAlertController(title: messages[current].title, message: messages[current].message, preferredStyle: UIAlertController.Style.alert) //presents a popup asking if they want to admin complete the request
            let okayAction = UIAlertAction(title: "OK", style: .default) { (action) in
                Firestore.firestore().collection("users").document(self.uid).updateData(["lastViewedMC":self.messages[self.current].docID!])
                
            self.current+=1
                
            if(self.current < self.messages.count){
                    self.presentAlert()
                }
            }
            
            refreshAlert.addAction(okayAction)
            self.present(refreshAlert, animated: true, completion: nil)
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
