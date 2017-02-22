//
//  OrderedListViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 15..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import Nuke


// MatchListResponseInfoObject :
class MatchListResponseInfoObject: Mappable {
    var massage : String = ""
    var status : String = ""
    var orderId = Int()
    var mainMenuId = Int()
    var storeId = Int()
    var storeName : String = ""
    var mainMenuName : String = ""
    var mainMenuImageURL : String = ""
    var mainMenuPrice = Int()
    var totalPrice = Int()
    var requirePeopleNum = Int()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        massage <- map["message"]
        status <- map["status"]
        orderId <- map["order_id"]
        storeId <- map["store_id"]
        mainMenuId <- map["main_menu_id"]
        storeName <- map["store_name"]
        mainMenuName <- map["main_menu_name"]
        mainMenuImageURL <- map["main_menu_image_url"]
        totalPrice <- map["total_price"]
        requirePeopleNum <- map["require_people_num"]
        mainMenuPrice <- map["main_menu_price"]
    }
}

class MatchListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    let MATCHLIST_URL = Constants.SERVER_URL+"/match"
    var matchListResponseInfoObject: [MatchListResponseInfoObject]?
    var orderInfos = [OrderInfo]()

    @IBOutlet weak var matchListTableView : UITableView!

    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.string(forKey: Constants.User.USER_ID) == nil {
            let signController : SignViewController
            signController = self.storyboard?.instantiateViewController(withIdentifier: "signView") as! SignViewController
            signController.callView = "modalView"
            present(signController, animated: true, completion: nil)
        } else {
            let parameters : Parameters = [
                Constants.Order.USER_ID : UserDefaults.standard.string(forKey: Constants.User.USER_ID)!
            ]
            
            Alamofire.request(MATCHLIST_URL, parameters: parameters, encoding: URLEncoding.default).responseArray(completionHandler: {
                (response: DataResponse<[MatchListResponseInfoObject]>) in
                if let matchListInfo = response.result.value {
                    self.matchListResponseInfoObject = matchListInfo
                    self.matchListTableView.reloadData()
                }
            })
        
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let matchListResponseInfoObject = self.matchListResponseInfoObject {
            for _ in 0..<matchListResponseInfoObject.count {
                    orderInfos.append(OrderInfo())
            }
            
            return matchListResponseInfoObject.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchListCell", for: indexPath) as! MatchListCell
        
        if let matchListInfo = self.matchListResponseInfoObject {
            cell.matchListStoreNameLabel.text = matchListInfo[indexPath.row].storeName
            cell.matchListMainMenuNameLabel.text = matchListInfo[indexPath.row].mainMenuName
            
            if matchListInfo[indexPath.row].status == "match" {
                cell.matchStatusImageView.image = UIImage(named: "matched")
            } else {
                cell.matchStatusImageView.image = UIImage(named: "matching")
            }
            
            cell.matchListImageView.layer.cornerRadius = cell.matchListImageView.frame.height/2
            cell.matchListImageView.layer.masksToBounds = true
            
            let imageURL = Constants.SERVER_URL+matchListInfo[indexPath.row].mainMenuImageURL
            let url = URL(string: imageURL)!
            
            Nuke.loadImage(with: url, into: cell.matchListImageView)
            orderInfos[indexPath.row].storeDic[Constants.Order.STORE_ID] = String(matchListInfo[indexPath.row].storeId)
            orderInfos[indexPath.row].storeDic[Constants.Order.STORE_NAME] = matchListInfo[indexPath.row].storeName
            orderInfos[indexPath.row].mainMenuDic[Constants.Order.MAIN_MANU_NAME] = matchListInfo[indexPath.row].mainMenuName
            orderInfos[indexPath.row].mainMenuDic[Constants.Order.MAIN_MENU_ID] = String(matchListInfo[indexPath.row].mainMenuId)
            orderInfos[indexPath.row].orderStatus = matchListInfo[indexPath.row].status
            orderInfos[indexPath.row].totalPrice = matchListInfo[indexPath.row].totalPrice
            orderInfos[indexPath.row].requirePeopleNum = matchListInfo[indexPath.row].requirePeopleNum
            orderInfos[indexPath.row].mainMenuDic[Constants.Order.MAIN_MANU_PRICE] = String(matchListInfo[indexPath.row].mainMenuPrice)
            orderInfos[indexPath.row].mainMenuDic[Constants.Order.MAIN_MANU_IMAGE_URL] =  matchListInfo[indexPath.row].mainMenuImageURL

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if orderInfos.count != 0 {
            let matchDetailViewController = storyboard?.instantiateViewController(withIdentifier: "matchDetailView") as! MatchDetailViewController
            if let matchListInfo = self.matchListResponseInfoObject {
                matchDetailViewController.orderId = matchListInfo[indexPath.row].orderId
            }
            matchDetailViewController.orderInfo = self.orderInfos[indexPath.row]
            self.navigationController?.pushViewController(matchDetailViewController, animated: true)
        }
    }
}
