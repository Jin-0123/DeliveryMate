//
//  OrderTitleCell.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 17..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import Foundation

class OrderTitleCell : UITableViewCell {
}

class StoreCell : UITableViewCell {
    @IBOutlet weak var storeTitleLabel : UILabel!
}

class MainMenuCell : UITableViewCell {
    @IBOutlet weak var mainMenuNameLabel : UILabel!
    @IBOutlet weak var mainMenuPriceLabel : UILabel!
}

class ListExtraMenuCell : UITableViewCell {
    @IBOutlet weak var extraMenuNameLabel : UILabel!
    @IBOutlet weak var extraMenuPriceLabel : UILabel!
    
    @IBOutlet weak var extraMenuCountLabel : UILabel!
    
}

class TotalPriceCell : UITableViewCell
{
    @IBOutlet weak var totalPriceLabel : UILabel!
}

class OrderPeopleNumCell : UITableViewCell {
 @IBOutlet weak var orderPeopleNumLabel : UILabel!
}
