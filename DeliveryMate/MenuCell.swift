//
//  menuCell.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 16..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import Foundation

class MenuCell : UITableViewCell {
    @IBOutlet weak var menuListImageView : UIImageView!
    @IBOutlet weak var menuListNameLabel : UILabel!
    @IBOutlet weak var menuListPriceLabel : UILabel!
    @IBOutlet weak var menuListPeopleNumLabel : UILabel!
}

class MenuImageCell : UITableViewCell {
    @IBOutlet weak var menuImageView : UIImageView!

}

class MenuDetailCell : UITableViewCell {
    @IBOutlet weak var menuNameLabel : UILabel!
    @IBOutlet weak var menuPriceLabel : UILabel!
    @IBOutlet weak var menuPeopleNumLabel : UILabel!
}

class ExtraMenuCell : UITableViewCell {
    @IBOutlet weak var extraMenuNameLabel : UILabel!
    @IBOutlet weak var extraMenuPriceLabel : UILabel!
    @IBOutlet weak var extraMenuCountLabel : UILabel!
    @IBOutlet weak var checkBoxImageView : UIImageView!
    @IBOutlet weak var plusButton : UIButton!
    @IBOutlet weak var minusButton : UIButton!
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        if let extraMenuCount = Int(extraMenuCountLabel.text!) {
            if extraMenuCount > 9 {
                plusButton.isEnabled = false
                minusButton.isEnabled = true
            } else {
                plusButton.isEnabled = true
                minusButton.isEnabled = true

                extraMenuCountLabel.text = String(extraMenuCount+1)
            }
        }
    }
    
    @IBAction func minusButtonPressed(_ sender: Any) {
        if let extraMenuCount = Int(extraMenuCountLabel.text!) {
            if extraMenuCount < 2 {
                minusButton.isEnabled = false
                plusButton.isEnabled = true
            } else {
                minusButton.isEnabled = true
                plusButton.isEnabled = true

                extraMenuCountLabel.text = String(extraMenuCount-1)
            }
        }
    }
    

}
