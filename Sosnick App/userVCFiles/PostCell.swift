//
//  PostCell.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 8/24/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit

class PostCell: UICollectionViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //hide or reset anything you want hereafter, for example
        postImageView.image = nil
        
        
    }
    
}
