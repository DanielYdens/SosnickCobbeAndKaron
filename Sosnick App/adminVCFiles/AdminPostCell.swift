//
//  AdminPostCell.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 9/2/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit


protocol AdminPostCellDelegate: AnyObject {
    func optionButtonTapped(cell: AdminPostCell)
}
class AdminPostCell: UICollectionViewCell {
    

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
        
    @IBOutlet weak var optionButton: UIButton!
    
    weak var delegate: AdminPostCellDelegate?
    
    @IBAction func optionButtonTapped(sender: AnyObject) {
        //4. call delegate method
        //check delegate is not nil with `?`
        delegate?.optionButtonTapped(cell: self)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        //hide or reset anything you want hereafter, for example
        postImageView.image = nil
        
        
    }
    
    
    
}
