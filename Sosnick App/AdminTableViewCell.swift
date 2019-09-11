//
//  AdminTableViewCell.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 7/15/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class AdminTableViewCell : UITableViewCell {
    
    var adminSeenTime : Int = 0
    var lastMessageTime : Int = 0
    var db = Firestore.firestore().collection("userMessageA")
    var userDB = Firestore.firestore().collection("users")
    var name : String = ""
    
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    @IBOutlet weak var dotImageView: UIImageView!
    
    @IBOutlet weak var isProcessedImageView: UIImageView!
    
    @IBOutlet weak var userLabel: UILabel!
    
    var adminReq : Request?{
        didSet{
            self.updateUI()
            
        }
    }
    
    func blueDotSetup(){
        if adminSeenTime < lastMessageTime {
            dotImageView.isHidden = false
        }
        else{
            dotImageView.isHidden = true
        }
    }
    
    func updateUI(){
        
        
        dotImageView.image = UIImage(named: "blue-dot")
        db.document(adminReq!.docID).addSnapshotListener { (DocumentSnapshot
            , Error) in
            if Error != nil {
                print(Error!)
            }
            else{
                self.lastMessageTime = DocumentSnapshot?.get("adminMostRecentMessage") as! Int
                self.adminSeenTime = DocumentSnapshot?.get("adminLastSeen") as! Int
                self.blueDotSetup()
            }
        }
        
        if adminReq?.isProcessed == false{
            isProcessedImageView.image = UIImage(named: "pending2")
        }
        dateLabel?.text = adminReq?.date
        categoryLabel?.text =  adminReq?.category
        descriptionTextLabel?.text = adminReq?.description
        //requestTitleLabel.adjustsFontSizeToFitWidth = true
        dateLabel.adjustsFontSizeToFitWidth = true
        categoryLabel.adjustsFontSizeToFitWidth = true
        //userLabel.text = adminReq?.u
        userLabel.text = adminReq?.name
        
    }
    
}
