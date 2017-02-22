//
//  Order.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 16..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//


class OrderInfo : NSObject {
    // storeDic : 선택한 매장 정보를 저장한다. (store_id, store_Name)
    var storeDic : [String:String] = [:]
    
    // mainMenuDic : 선택한 메인메뉴 정보를 저장한다.
    var mainMenuDic : [String:String] = [:]
    
    // selectedExtraMenuDic : 선택된 추가메뉴를 저장해서 MenuList 화면으로 넘겨준다. (id: (count, price, name))
    var extraMenuDic : [Int:(Int,Int,String)]?
    var totalPrice : Int = 0
    
    var orderStatus : String?
    var currentPeopleNum : Int?
    var requirePeopleNum : Int?
    
    public func clear() {
        storeDic  = [:]
        mainMenuDic = [:]
        
        extraMenuDic = nil
        totalPrice = 0
        
        orderStatus = nil
        currentPeopleNum = nil
        requirePeopleNum = nil
    }
}
