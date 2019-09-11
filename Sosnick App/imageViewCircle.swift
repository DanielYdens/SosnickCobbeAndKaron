//
//  imageViewCircle.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 8/20/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func roundedImage() {
        self.layer.cornerRadius = (self.frame.size.width ) / 2;
        self.clipsToBounds = true
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.white.cgColor
    }
}
