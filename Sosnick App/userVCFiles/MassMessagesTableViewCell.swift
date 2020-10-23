//
//  MassMessagesTableViewCell.swift
//  Apex Baseball
//
//  Created by Daniel Ydens on 10/7/20.
//  Copyright © 2020 Daniel Ydens. All rights reserved.
//

import UIKit

class MassMessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
