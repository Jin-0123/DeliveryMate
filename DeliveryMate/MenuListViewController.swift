//
//  MenuListViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 14..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class MenuInfoObject : Mappable {
    var menuId : Int?
    var menuName: String?
    var menuType : String?
    var requirePeopleNum : Int?
    var price : Int?
    var mainCount : Int = 0
    var extraCount : Int = 0
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        menuId <- map["id"]
        menuName <- map["name"]
        menuType <- map["type"]
        requirePeopleNum <- map["require_people_num"]
        price <- map["price"]
        mainCount <- map["main_count"]
        extraCount <- map["extra_count"]
    }
}

class MenuListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var storeId : Int = 0
    var menuInfoObject: [MenuInfoObject]?
    

    
    @IBOutlet weak var mainMenuTableView: UITableView!
     @IBOutlet weak var extraMenuTableView: UITableView!
    
    override func viewDidLoad() {
        self.navigationItem.title = "메뉴선택"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "주문하기"
            , style: .plain, target: self, action: #selector(orderButtonPressed))
        navigationItem.rightBarButtonItem?.isEnabled = false
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        let parameters : Parameters = [
            "store_id" : storeId
        ]
        
        Alamofire.request("http://ec2-52-79-190-145.ap-northeast-2.compute.amazonaws.com:3000/menu", parameters: parameters, encoding: URLEncoding.default).responseArray(completionHandler: {
            (response: DataResponse<[MenuInfoObject]>) in
            if let menuInfo = response.result.value {
                self.menuInfoObject = menuInfo
            }
            self.mainMenuTableView.reloadData()
            self.extraMenuTableView.reloadData()
        })
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let menuFirstInfo = menuInfoObject  {
            if tableView == mainMenuTableView {
                return menuFirstInfo[0].mainCount
            }
            
            if tableView == extraMenuTableView {
                return menuFirstInfo[0].extraCount
            }
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as UITableViewCell
        
        if let menuInfo = self.menuInfoObject {
            if tableView == mainMenuTableView {
                cell.detailTextLabel?.text = "메인메뉴"
                cell.textLabel?.text = menuInfo[indexPath.row].menuName
            }
            
            let extraMenuIdx = indexPath.row + menuInfo[0].mainCount
            if tableView == extraMenuTableView && extraMenuIdx < menuInfo.count {
                cell.detailTextLabel?.text = "추가메뉴"
                cell.textLabel?.text = menuInfo[indexPath.row+menuInfo[0].mainCount].menuName
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.accessoryType = .checkmark
        }
        
        if tableView == mainMenuTableView {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.accessoryType = .none
        }
        
        if tableView == mainMenuTableView {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func orderButtonPressed() {
        var orderList : [String : Any] = [:]
        var extraMenuList = [[String: Any]]()
        var orderMenuIdx : [IndexPath] = []
        
        if let mainMenuRow = self.mainMenuTableView.indexPathsForSelectedRows,
            let extraMenuRow = self.extraMenuTableView.indexPathsForSelectedRows {
            orderMenuIdx += mainMenuRow
            orderMenuIdx += extraMenuRow
            
            orderList["user_id"] = 3
            orderList["store_id"] = self.storeId
            if let menuInfo = self.menuInfoObject {
                orderList["main_menu_id"] = menuInfo[0].menuId
                for var i in 1 ..< orderMenuIdx.count {
                    extraMenuList.append(["menu_id" : menuInfo[i].menuId!, "menu_count" : 1])
                }
                orderList["extra_menu"] = extraMenuList
            }
            print(orderList)
        }
        
        
    }
}
