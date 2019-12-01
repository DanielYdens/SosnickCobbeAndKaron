//
//  PlayersTableViewCell.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 8/28/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit

class PlayersTableViewCell: UITableViewCell {
    

    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //hide or reset anything you want hereafter, for example
        profilePicImageView.image = nil //when scrolling down resets the image so it doesnt show the wrong image when scrolling fast
        
        
    }

}
