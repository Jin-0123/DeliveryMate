//
//  MatchStoreCell.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 20..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import Foundation

class MatchStoreCell : UITableViewCell {
    @IBOutlet weak var storeNameLabel : UILabel!

}

class MatchStatusCell : UITableViewCell {
    @IBOutlet weak var
    matchStatusLabel: UILabel!
    @IBOutlet weak var mainMenuImageView : UIImageView!
}

class MatchStatusTextCell : UITableViewCell {
    @IBOutlet weak var
    currentPeopleNumLabel: UILabel!
    @IBOutlet weak var
    requirePeopleNumLabel: UILabel!
}
