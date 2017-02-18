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

// MenuInfoObject : 서버에서 받아온 메뉴 리스트 맵핑에 필요한 객체를 선언한다.
class MenuInfoObject : Mappable {
    var menuId = Int()
    var menuName = String()
    var menuType = String()
    var requirePeopleNum = Int()
    var price = Int()
    var mainCount = Int()
    var extraCount = Int()
    var imageURL = String()
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        menuId <- map["id"]
        menuName <- map["name"]
        menuType <- map["type"]
        requirePeopleNum <- map["require_people_num"]
        price <- map["price"]
        mainCount <- map["main_count"]
        extraCount <- map["extra_count"]
        imageURL <- map["image_url"]
    }
}

class MenuListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    let MENUURL = Constants.SERVER_URL+"/menu"
    let EXTRA_MENU_TYPE : String = "extra"
    
    // storeInfo : 선택한 매장 정보를 저장한다. (store_id, store_Name)
    var storeInfo: (Int, String) = (0, "")
    var menuInfoObject: [MenuInfoObject]?

    var menuDetailViewController = MenuDetailViewController()

    enum selectState { case notSelect, selecting }

    
    @IBOutlet weak var mainMenuTableView: UITableView!
    
    
    // MARK: - App Life Cycle
    
    override func viewDidLoad() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = storeInfo.1
        self.tabBarController?.tabBar.isHidden = true
        selectConfigureUI(.notSelect)
        
        let parameters : Parameters = [
            "store_id" : storeInfo.0
        ]
        
        Alamofire.request(MENUURL, parameters: parameters, encoding: URLEncoding.default).responseArray(completionHandler: {
            (response: DataResponse<[MenuInfoObject]>) in
            self.menuDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "extraMenuView") as! MenuDetailViewController
            
            self.menuDetailViewController.storeInfo = self.storeInfo
            if let menuInfo = response.result.value {
                self.menuInfoObject = menuInfo
                for menu in menuInfo {
                    if menu.menuType == self.EXTRA_MENU_TYPE {
                        self.menuDetailViewController.extraMenuList.append((menu.menuId, menu.menuName, menu.price))
                    }
                }
            }
            self.mainMenuTableView.rowHeight = 120
            self.mainMenuTableView.reloadData()
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let menuFirstInfo = menuInfoObject  {
            return menuFirstInfo[0].mainCount
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuCell
        
        if let menuInfo = self.menuInfoObject {
            cell.menuListNameLabel.text = menuInfo[indexPath.row].menuName
            cell.menuListPriceLabel.text = String(menuInfo[indexPath.row].price)
            cell.menuListPeopleNumLabel.text = String(menuInfo[indexPath.row].requirePeopleNum)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menuInfo = self.menuInfoObject {
            menuDetailViewController.mainMenuDic[Constants.Order.MAIN_MENU_ID] = String(menuInfo[indexPath.row].menuId)
            menuDetailViewController.mainMenuDic[Constants.Order.MAIN_MANU_NAME] = menuInfo[indexPath.row].menuName
            menuDetailViewController.mainMenuDic[Constants.Order.MAIN_MANU_PRICE] = String(menuInfo[indexPath.row].price)
            menuDetailViewController.mainMenuDic[Constants.Order.MAIN_MANU_PEOPLE_NUM] = String(menuInfo[indexPath.row].requirePeopleNum)
        }
        
        self.navigationController?.pushViewController(menuDetailViewController, animated: true)
    }
    
    // MARK: UI Functions
    func selectConfigureUI(_ selectState: selectState) {
        
    }
}
