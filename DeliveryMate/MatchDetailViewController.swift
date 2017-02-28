//
//  MatchDetailViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 17..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import Nuke

// MatchDetailResponseInfoObject :
class MatchDetailResponseInfoObject: Mappable {
    var massage : String = ""
    var status : String = ""
    var currentPeopleNum = Int()
    var extraMenu = [ExtraMenuInfo]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        massage <- map["message"]
        status <- map["status"]
        currentPeopleNum <- map["current_people_num"]
        extraMenu <- map["extra_menu"]
    }
}

class ExtraMenuInfo : Mappable {
    var extraMenuName : String = ""
    var extraMenuCount = Int()
    var extraMenuPrice = Int()
    var extraMenuId = Int()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        extraMenuName <- map["extra_menu_name"]
        extraMenuCount <- map["extra_menu_count"]
        extraMenuPrice <- map["extra_menu_price"]
        extraMenuId <- map["extra_id"]
    }
}


class MatchDetailViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let MATCHDETAIL_URL = Constants.SERVER_URL+"/match/extra"

    var orderViewDelegate : OrderViewController?
    var meunDetailDelegate : MenuDetailViewController?
    var orderInfo = OrderInfo()
    var orderId = Int()
    var extraMenuCount = Int()
    
    @IBOutlet weak var matchDetailTableView : UITableView!
    @IBOutlet weak var closeButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {

        if appDelegate.currentOrder.currentPeopleNum != nil {
            self.orderInfo = appDelegate.currentOrder
            if let count = orderInfo.extraMenuDic?.count {
                self.extraMenuCount = count
            }
            self.closeButton.isHidden = false
            
        } else {
            self.closeButton.isHidden = true

            let parameters : Parameters = [
                Constants.Order.ORDER_ID : orderId,
                Constants.Order.MAIN_MENU_ID : orderInfo.mainMenuDic[Constants.Order.MAIN_MENU_ID]!,
                Constants.Order.STORE_ID : orderInfo.storeDic[Constants.Order.STORE_ID]!
            ]
            
            Alamofire.request(MATCHDETAIL_URL, parameters: parameters, encoding: URLEncoding.default).responseObject(completionHandler: {
                (response: DataResponse<MatchDetailResponseInfoObject>) in
                
                
                if let matchDetailInfo = response.result.value {
                    self.orderInfo.currentPeopleNum = matchDetailInfo.currentPeopleNum
                    print(matchDetailInfo.currentPeopleNum)
                    
                    if matchDetailInfo.extraMenu.count != 0 {
                        self.orderInfo.extraMenuDic = [Int:(Int, Int, String)]()
                        
                        for extra in matchDetailInfo.extraMenu {
                            self.orderInfo.extraMenuDic?[extra.extraMenuId] = (extra.extraMenuCount, extra.extraMenuPrice, extra.extraMenuName)
                        }
                    }
                }
                
                if let count = self.orderInfo.extraMenuDic?.count {
                    self.extraMenuCount = count
                }
                
                self.matchDetailTableView.reloadData()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extraMenuCount + 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1. 주문한 매장정보를 보여준다.
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "matchStoreCell", for: indexPath) as! MatchStoreCell
            cell.isUserInteractionEnabled = false
            cell.storeNameLabel.text = orderInfo.storeDic[Constants.Order.STORE_NAME]
            tableView.rowHeight = 40
            return cell
        }
        // 2. 주문 상태를 보여준다.
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "matchStatusCell", for: indexPath) as! MatchStatusCell
            cell.isUserInteractionEnabled = false
            
            cell.mainMenuImageView.circleImageView()
            
            if let imageURL = orderInfo.mainMenuDic[Constants.Order.MAIN_MANU_IMAGE_URL] {
                let imageURL = Constants.SERVER_URL+imageURL
                let url = URL(string: imageURL)!
                Nuke.loadImage(with: url, into: cell.mainMenuImageView)
            }
           
            if orderInfo.orderStatus == "match" {
                cell.matchStatusLabel.text = "매칭완료"
            } else {
                cell.matchStatusLabel.text = "매칭중"
            }
            
            
            tableView.rowHeight = 200
            return cell
        }
        //3. 메인 메뉴 정보를 보여준다.
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listMainMenuCell", for: indexPath) as! MainMenuCell
            cell.isUserInteractionEnabled = false
            cell.mainMenuNameLabel.text = orderInfo.mainMenuDic[Constants.Order.MAIN_MANU_NAME]!
            cell.mainMenuPriceLabel.text = orderInfo.mainMenuDic[Constants.Order.MAIN_MANU_PRICE]!
            tableView.rowHeight = 40
            return cell
        }
        // 4. 총 금액정보를 보여준다.
        else if indexPath.row == (extraMenuCount + 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listTotalPriceCell", for: indexPath) as! TotalPriceCell
            cell.isUserInteractionEnabled = false
            cell.totalPriceLabel.text = String(orderInfo.totalPrice)
            tableView.rowHeight = 40
            return cell
        }
            
        // 5. 주문상태 텍스트를 보여준다.
        else if indexPath.row == (extraMenuCount + 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "matchStatusTextCell", for: indexPath) as! MatchStatusTextCell
            cell.isUserInteractionEnabled = false
            if orderInfo.orderStatus == "waiting" {
                if let curNum = orderInfo.currentPeopleNum, let reqNum = orderInfo.requirePeopleNum {
                    let currentPeopleNumString = NSMutableAttributedString(string: "현재 동일메뉴 등록인원은 \(curNum) 명 입니다.")
                    currentPeopleNumString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.91, green:0.53, blue:0.62, alpha:1.0), range: NSMakeRange(14, 1))
                    cell.currentPeopleNumLabel.attributedText = currentPeopleNumString
                    
                    let requirePeopleNumString = NSMutableAttributedString(string: "동일메뉴 주문인원이 \(reqNum) 명일 경우, 매칭이 완료됩니다.")
                    requirePeopleNumString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.91, green:0.53, blue:0.62, alpha:1.0), range: NSMakeRange(11, 1))
                    cell.requirePeopleNumLabel.attributedText = requirePeopleNumString
                }
                tableView.rowHeight = 50
            } else {
                cell.isHidden = true
                //tableView.rowHeight = 0
            }
            return cell
        }
        // 6. 추가메뉴 정보 셀을 정의한다.
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listExtraMenuCell", for: indexPath) as! ListExtraMenuCell
            cell.isUserInteractionEnabled = false
            if let extraMenu = orderInfo.extraMenuDic?.popFirst() {
                cell.extraMenuNameLabel.text = extraMenu.value.2
                cell.extraMenuPriceLabel.text = String(extraMenu.value.1)
                cell.extraMenuCountLabel.text = String(extraMenu.value.0)
            }
            
            tableView.rowHeight = 30
            return cell
        }
    }
    
    
    // MARK :- Action

    @IBAction func closeButtonPressed(_ sender: Any) {
        // 닫기버튼을 누르면, 주문상태창, 주문서창을 닫고, 메인메뉴 화면으로 이동한다.
        self.dismiss(animated: false, completion: {
            if let orderController = self.orderViewDelegate {
                orderController.goToMainView()
            }
        })
    }
}
