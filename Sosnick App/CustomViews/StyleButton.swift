//
//  StyleButton.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 7/22/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit

class StyleButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton(){
        //backgroundColor = UIColor(displayP3Red: 57/255, green: 135/255, blue: 198/255, alpha: 1)
        backgroundColor = UIColor(displayP3Red: 6/255, green: 91/255, blue: 99/255, alpha: 1)
        layer.cornerRadius = frame.size.height/2
        setTitleColor(.white, for: .normal)
        
    }
    

}
