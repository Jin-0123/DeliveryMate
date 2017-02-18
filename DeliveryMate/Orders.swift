//
//  Order.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 16..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//


class Orders {
    var user_id : String?
    var store_id : Int?
    var main_menu_id : Int?
    var extra_menu : [[Int:Int]]?
    var expire_time : Date?
    
    init(user_id: String, store_id: Int, main_menu_id: Int, extra_menu :[[Int:Int]]) {
        self.user_id = user_id
        self.store_id = store_id
        self.main_menu_id = main_menu_id
        self.extra_menu = extra_menu
    }
}
