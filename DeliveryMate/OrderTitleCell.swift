//
//  OrderTitleCell.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 17..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import Foundation

class OrderTitleCell : UITableViewCell {
    @IBOutlet weak var orderTitleLabel : UILabel!
}

class OrderStoreCell : UITableViewCell {
    @IBOutlet weak var orderStoreTitleLabel : UILabel!
}

class OrderMainMenuCell : UITableViewCell {
    @IBOutlet weak var orderMainMenuNameLabel : UILabel!
    @IBOutlet weak var orderMainMenuPriceLabel : UILabel!
}

class OrderExtraMenuCell : UITableViewCell {
    @IBOutlet weak var orderExtraMenuNameLabel : UILabel!
    @IBOutlet weak var orderExtraMenuPriceLabel : UILabel!
    
    @IBOutlet weak var orderExtraMenuCountLabel : UILabel!
    
}

class OrderTotalPriceCell : UITableViewCell
{
    @IBOutlet weak var orderTotalPriceLabel : UILabel!
}

class OrderLimitTimeCell : UITableViewCell{
    @IBOutlet weak var orderLimitTimeLabel : UILabel!
    
}

class OrderTimePickerCell : UITableViewCell {
    @IBOutlet weak var orderTimePicker : UIPickerView!
}

class OrderPeopleNumCell : UITableViewCell {
 @IBOutlet weak var orderPeopleNumLabel : UILabel!
}
