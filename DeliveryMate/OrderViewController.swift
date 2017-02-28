//
//  OrderViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 16..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper


// OrderResponseInfoObject : 서버에 주문 요청 후 응답받을 객체를 정의한다.
class OrderResponseInfoObject: Mappable {
    var currentPeopleNum = Int()
    var massage : String = ""
    var status : String = ""
    required init?(map: Map) {}
    func mapping(map: Map) {
        massage <- map["message"]
        status <- map["status"]
        currentPeopleNum <- map["current_people_num"]
    }
}

class OrderViewController  : UIViewController, UITableViewDelegate, UITableViewDataSource {
    let ORDER_URL = Constants.SERVER_URL+"/order"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var delegate : MenuDetailViewController?
    
    var tempExtraMenuDic = [Int:(Int,Int,String)]()
    var extraDicCount : Int = 0
    
    // MARK: - Outlet
    
    @IBOutlet weak var orderCancelButton : UIButton!
    @IBOutlet weak var orderRegisterButton : UIButton!
    @IBOutlet weak var orderTableView : UITableView!

    
    // MARK: - App life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let extraMenuDic = appDelegate.currentOrder.extraMenuDic {
            tempExtraMenuDic = extraMenuDic
            extraDicCount = extraMenuDic.count
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extraDicCount + 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1. 주문서 제목 셀을 정의한다.
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderTitleCell", for: indexPath) as! OrderTitleCell
            cell.isUserInteractionEnabled = false
            tableView.rowHeight = 229
            return cell
        }
        // 2. 매장 정보 셀을 정의한다.
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listStoreCell", for: indexPath) as! StoreCell
            cell.isUserInteractionEnabled = false
            cell.storeTitleLabel.text = appDelegate.currentOrder.storeDic[Constants.Order.STORE_NAME]!
            tableView.rowHeight = 40
            return cell
        }
        // 3. 메인 메뉴 정보 셀을 정의한다.
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listMainMenuCell", for: indexPath) as! MainMenuCell
            cell.isUserInteractionEnabled = false
            cell.mainMenuNameLabel.text = appDelegate.currentOrder.mainMenuDic[Constants.Order.MAIN_MANU_NAME]!
            cell.mainMenuPriceLabel.text = appDelegate.currentOrder.mainMenuDic[Constants.Order.MAIN_MANU_PRICE]!
            tableView.rowHeight = 40
            return cell
        }
        // 4. 총 금액 정보 셀을 정의한다.
        else if indexPath.row == (extraDicCount + 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listTotalPriceCell", for: indexPath) as! TotalPriceCell
            cell.isUserInteractionEnabled = false
            cell.totalPriceLabel.text = String(appDelegate.currentOrder.totalPrice)
            tableView.rowHeight = 40
            return cell
        }
        // 5. 요구인원 정보 셀을 정의한다.
        else if indexPath.row == (extraDicCount + 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderPeopleNumCell", for: indexPath) as! OrderPeopleNumCell
            cell.isUserInteractionEnabled = false
            
            
           
            
            let peopleNumString = NSMutableAttributedString(string: "동일메뉴 주문인원이 \(appDelegate.currentOrder.mainMenuDic[Constants.Order.MAIN_MANU_PEOPLE_NUM]!) 명일 경우 거래가 성사됩니다.")
            
            peopleNumString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.91, green:0.53, blue:0.62, alpha:1.0), range: NSMakeRange(11, 1))
            
            cell.orderPeopleNumLabel.attributedText = peopleNumString
            tableView.rowHeight = 40
            return cell
        }
        // 6. 추가메뉴 정보 셀을 정의한다.
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listExtraMenuCell", for: indexPath) as! ListExtraMenuCell
            cell.isUserInteractionEnabled = false
            if let extraMenu = tempExtraMenuDic.popFirst() {
                cell.extraMenuNameLabel.text = extraMenu.value.2
                cell.extraMenuPriceLabel.text = String(extraMenu.value.1)
                cell.extraMenuCountLabel.text = String(extraMenu.value.0)
            }

            tableView.rowHeight = 30
            return cell
        }
    }
    
    // MARK: - Action

    @IBAction func orderCancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func orderRegisterButtonPressed(_ sender: Any) {
        if UserDefaults.standard.string(forKey: Constants.User.USER_ID) == nil {
            let signController : SignViewController
            signController = self.storyboard?.instantiateViewController(withIdentifier: "signView") as! SignViewController
            signController.callView = "modalView"
            present(signController, animated: true, completion: nil)
        } else {

            var parameters : Parameters = [:]
            
            let userId : String = UserDefaults.standard.string(forKey: Constants.User.USER_ID)!
            parameters[Constants.Order.USER_ID] = userId
            parameters[Constants.Order.STORE_ID] = appDelegate.currentOrder.storeDic[Constants.Order.STORE_ID]!
            parameters[Constants.Order.MAIN_MENU_ID] = appDelegate.currentOrder.mainMenuDic[Constants.Order.MAIN_MENU_ID]!
            parameters[Constants.Order.TOTAL_PRICE] = appDelegate.currentOrder.totalPrice
            
            if let extraMenuDic = appDelegate.currentOrder.extraMenuDic {
                var extraMenuReqParam = [Parameters]()
                for (id,(count, _, _)) in extraMenuDic {
                    extraMenuReqParam.append([Constants.Order.MENU_ID:id, Constants.Order.MENU_COUNT:count])
                }

                parameters[Constants.Order.EXTRA_MENU] = extraMenuReqParam
            }
            //parameters[Constants.Order.EXPIRE_TIME]
            let date = NSDate()
            let calendar = NSCalendar.current
            let hour = calendar.component(.hour, from: date as Date)
            let minutes = calendar.component(.minute, from: date as Date)
            print("\(hour), \(minutes)")
            print(parameters)
            
            let indicator = IndicatorHelper.init(view: self.view)
            indicator.start()
            Alamofire.request(self.ORDER_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseObject(completionHandler: {
                (response: DataResponse<OrderResponseInfoObject>) in
                dump(response)
                if let orderResponseInfoObject = response.result.value {
                    indicator.stop()
                    self.appDelegate.currentOrder.orderStatus = orderResponseInfoObject.status
                    self.appDelegate.currentOrder.currentPeopleNum = orderResponseInfoObject.currentPeopleNum
                    
                    if orderResponseInfoObject.massage == "success" && orderResponseInfoObject.status == "match"  {
                        let alert = UIAlertController(title: "매칭완료", message: "매칭이 완료되었습니다", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "확인", style: .default, handler: { action in
                            // match 상태를 확인하는 뷰로 이동한다.
                            self.performSegue(withIdentifier: "matchDetailSegue", sender: self )})

                        alert.addAction(ok)
                        self.present(alert, animated: false, completion: nil)
                        
                    } else if orderResponseInfoObject.massage == "fail" {
                        let alert = UIAlertController(title: "등록실패", message: "주문등록에 실패하였습니다", preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                        alert.addAction(cancel)
                        self.present(alert, animated: false, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "주문등록", message: "등록이 완료되었습니다", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "확인", style: .default, handler: { action in
                            // match 상태를 확인하는 뷰로 이동한다.
                            self.performSegue(withIdentifier: "matchDetailSegue", sender: self )
                        })
                        
                        alert.addAction(ok)
                        self.present(alert, animated: false, completion: nil)
                    }
                    
                   
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! MatchDetailViewController
        controller.orderViewDelegate = self
    }
    
    func goToMainView() {
        self.dismiss(animated: true, completion: {
            if let naviController = self.delegate?.navigationController {
                naviController.popToRootViewController(animated: false)
            }
        })
    }
}
