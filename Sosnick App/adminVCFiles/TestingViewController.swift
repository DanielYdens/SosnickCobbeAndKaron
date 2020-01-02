//
//  TestingViewController.swift
//  Apex Baseball
//
//  Created by Daniel Ydens on 12/27/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import WebKit
import FirebaseAuth
import FirebaseFirestore

class TestingViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webVIew: WKWebView!
    
    var messages : [massMessage] = []
    var current = 0
    let uid =  Auth.auth().currentUser!.uid
    
    override func viewDidAppear(_ animated: Bool) {
        
        let url = URL(string: "https://instagram.com/apexbaseball")!
        webVIew.load(URLRequest(url: url))
        webVIew.allowsBackForwardNavigationGestures = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfThereIsAnyReminders()
        webVIew.navigationDelegate = self as WKNavigationDelegate
        // Do any additional setup after loading the view.
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
    
    
    @IBAction func massCommButtonPressed(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "massComm") as? MassCommunicationViewController
        self.navigationController?.pushViewController(vc!, animated: true)
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
