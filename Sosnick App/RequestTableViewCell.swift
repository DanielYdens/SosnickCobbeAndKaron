//
//  RequestTableViewCell.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 7/3/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import FirebaseFirestore
class RequestTableViewCell: UITableViewCell {

    
    var db = Firestore.firestore().collection("userMessageA")
    var userSeenTime : Int = 0
    var lastMessageTime : Int = 0
    
   
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var statusImageView: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var requestTitleLabel: UILabel!
    @IBOutlet weak var requestDescriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dotImageView: UIImageView!
    var request: Request?{
        didSet{
            self.updateUI()
        }
    }
    
    func blueDotSetup(){
        if userSeenTime < lastMessageTime {
            dotImageView.isHidden = false
        }
        else{
            dotImageView.isHidden = true
        }
        
    }
    func updateUI(){
        
        dotImageView.image = UIImage(named: "blue-dot")
//        db.document(self.request!.docID).getDocument { (DocumentSnapshot, Error) in
//            if Error != nil {
//                print(Error!)
//            }
//            else{
//                self.lastMessageTime = DocumentSnapshot?.get("mostRecentMessage") as! Int
//                self.userSeenTime = DocumentSnapshot?.get("userLastSeen") as! Int
//                self.blueDotSetup()
//            }
//        }
        
        let listener = db.document(self.request!.docID).addSnapshotListener { (DocumentSnapshot
            , Error) in
            if Error != nil {
                print(Error!)
            }
            else{
                self.lastMessageTime = DocumentSnapshot?.get("mostRecentMessage") as! Int
                self.userSeenTime = DocumentSnapshot?.get("userLastSeen") as! Int
                self.blueDotSetup()
                
            }
        }
       
        
    
      
        
        if request?.status == "userSubmitted" { //if status is just submitted do closed envelope
            statusImageView.image = UIImage(named: "closedEnvelope")
            statusLabel.text = "Status: Unread"
        }
        if request?.status == "adminReceived" { //if admin opens it show open envelope
            statusImageView.image = UIImage(named: "openEnvelope")
            statusLabel.text = "Status: Received"
        }
        
        if request?.status == "adminConfirmed" { //if admin confirms show pending symbol
            statusImageView.image = UIImage(named: "processing")
            statusImageView.contentMode = .scaleAspectFill
            statusLabel.text = "Status: In Processing"
        }
        if request?.isProcessed == true{ //if user completes show a check
            statusImageView.image = UIImage(named: "check")
            statusLabel.text = "Status: Completed"
        }
        
//        if request?.isProcessed == false{
//            statusImageView.image = UIImage(named: "pending2")
//        }
        
        dateLabel?.text = request?.date
        requestTitleLabel?.text =  request?.category
        requestDescriptionLabel?.text = request?.description
        //requestTitleLabel.adjustsFontSizeToFitWidth = true
        dateLabel.adjustsFontSizeToFitWidth = true
        
            
    }
}

