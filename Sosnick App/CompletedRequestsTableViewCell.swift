//
//  CompletedRequestsTableViewCell.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 8/20/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class CompletedRequestsTableViewCell : UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var requestDescriptionLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var statusImage: UIImageView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var dotImage: UIImageView!
    var userSeenTime = 0
    var lastMessageTime = 0
    let database = Firestore.firestore().collection("userMessageA")
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var request: Request?{
        didSet{
            self.updateUI()
        }
    }
    
    func blueDotSetup(){
        if userSeenTime < lastMessageTime {
            dotImage.isHidden = false
        }
        else{
            dotImage.isHidden = true
        }
    }
    func updateUI(){
        
        dotImage.image = UIImage(named: "blue-dot")
        
        database.document(self.request!.docID).addSnapshotListener { (DocumentSnapshot
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
        
        
     
        if request?.isProcessed == true{ //if user completes show a check
            statusImage.image = UIImage(named: "check")
            statusLabel.text = "Status: Completed"
        }
//        if request?.isProcessed == false{
//            statusImage.image = UIImage(named: "pending2")
//        }
//        else{
//            statusImage.image = UIImage(named: "check")
//        }
        dateLabel?.text = request?.date
        categoryLabel?.text =  request?.category
        requestDescriptionLabel?.text = request?.description
        //requestTitleLabel.adjustsFontSizeToFitWidth = true
        dateLabel.adjustsFontSizeToFitWidth = true
        
    }
}
