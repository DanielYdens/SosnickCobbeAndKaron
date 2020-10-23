//
//  ScreenshotTableViewCell.swift
//  Apex Baseball
//
//  Created by Daniel Ydens on 9/27/20.
//  Copyright © 2020 Daniel Ydens. All rights reserved.
//

import UIKit

class ScreenshotTableViewCell: UITableViewCell {

    @IBOutlet weak var screenshotImageView: UIImageView!
    
    var userMessagesViewController : UserMessagesViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        screenshotImageView.isUserInteractionEnabled = true
        screenshotImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        screenshotImageView.layer.cornerRadius = 16
        screenshotImageView.contentMode = .scaleAspectFill
        screenshotImageView.backgroundColor = UIColor.lightGray
        screenshotImageView.clipsToBounds = true
        
        // Initialization code
    }
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        print("tapped")
        if let imageView = tapGesture.view as? UIImageView {
            self.userMessagesViewController?.performZoomInForImageView(startingImageView: imageView)
        }
        
    }
    
    override func prepareForReuse() {
        self.screenshotImageView?.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
