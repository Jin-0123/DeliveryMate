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
import Nuke

// MenuInfoObject : 서버에서 받아온 메뉴 리스트 맵핑에 필요한 객체를 선언한다.
class MenuResponseInfo : Mappable {
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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var menuResponseInfo: [MenuResponseInfo]?

    var mainMenuCount : Int = 0
    var menuDetailViewController = MenuDetailViewController()

    
    @IBOutlet weak var mainMenuTableView: UITableView!
    
    
    // MARK: - App Life Cycle
    

    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = appDelegate.currentOrder.storeDic[Constants.Order.STORE_NAME]
        
        var parameters : Parameters = [:]
        if let storeID = appDelegate.currentOrder.storeDic[Constants.Order.STORE_ID] {
            parameters["store_id"] = storeID
        }
            
        
        Alamofire.request(MENUURL, parameters: parameters, encoding: URLEncoding.default).responseArray(completionHandler: {
            (response: DataResponse<[MenuResponseInfo]>) in
            self.menuDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "extraMenuView") as! MenuDetailViewController

            if let menuInfo = response.result.value {
                self.menuResponseInfo = menuInfo
                for menu in menuInfo {
                    self.mainMenuCount = menu.mainCount
                    if menu.menuType == self.EXTRA_MENU_TYPE {
                        // 추가메뉴리스트를 받아서 다음화면에 넘겨준다.
                        self.menuDetailViewController.extraMenuList.append((menu.menuId, menu.menuName, menu.price))
                    }
                }
            }
            self.mainMenuTableView.reloadData()
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mainMenuCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuCell
        
        if let menuInfo = self.menuResponseInfo {
            cell.menuListNameLabel.text = menuInfo[indexPath.row].menuName
            cell.menuListPriceLabel.text = String(menuInfo[indexPath.row].price)
            cell.menuListPeopleNumLabel.text = String(menuInfo[indexPath.row].requirePeopleNum)
            
            cell.menuListImageView.circleImageView()
            let imageURL = Constants.SERVER_URL+menuInfo[indexPath.row].imageURL
            let url = URL(string: imageURL)!
            Nuke.loadImage(with: url, into: cell.menuListImageView)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menuInfo = self.menuResponseInfo {
            appDelegate.currentOrder.mainMenuDic =
                [Constants.Order.MAIN_MENU_ID:String(menuInfo[indexPath.row].menuId),
                 Constants.Order.MAIN_MANU_NAME : menuInfo[indexPath.row].menuName,
                 Constants.Order.MAIN_MANU_PRICE : String(menuInfo[indexPath.row].price),
                 Constants.Order.MAIN_MANU_PEOPLE_NUM : String(menuInfo[indexPath.row].requirePeopleNum),
                 Constants.Order.MAIN_MANU_IMAGE_URL : menuInfo[indexPath.row].imageURL]
            appDelegate.currentOrder.requirePeopleNum = menuInfo[indexPath.row].requirePeopleNum
        }
        self.navigationController?.pushViewController(menuDetailViewController, animated: true)
    }
}
