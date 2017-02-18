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


// OrderResponseInfoObject : 주문 요청 후 응답받을 객체를 정의한다.
class OrderResponseInfoObject: Mappable {
    var currentPeopleNum = Int()
    var requirePeopleNum = Int()
    var massage : String = ""
    var status : String = ""
    required init?(map: Map) {}
    func mapping(map: Map) {
        massage <- map["message"]
        status <- map["status"]
        currentPeopleNum <- map["current_people_num"]
        requirePeopleNum <- map["require_people_num"]

    }
}

class OrderViewController  : UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    let ORDER_URL = Constants.SERVER_URL+"/order"
    let pickerDataSoruce : [Int:String] = [0:"15분", 1:"30분", 2:"1시간", 3:"1시간 30분", 4:"2시간"]
    
    var delegate : MenuDetailViewController?
    
    // storeInfo : 선택한 매장 정보를 저장한다. (store_id, store_Name)
    var storeInfo: (Int, String) = (0,"")
    
    // mainMenuDic : 선택한 메인메뉴 정보를 저장한다.
    var mainMenuDic : [String:String] = [:]
    
    // selectedExtraMenuDic : 선택된 추가메뉴를 저장해서 MenuList 화면으로 넘겨준다. [id: (count, price, name)]
    var tempExtraMenuDic = [Int:(Int,Int,String)]()
    var extraMenuDic : [Int:(Int,Int,String)]?
    
    // totalPrice :
    var totalPrice : Int = 0
    
    // MARK: - Outlet
    
    @IBOutlet weak var orderCancelButton : UIButton!
    @IBOutlet weak var orderRegisterButton : UIButton!
    @IBOutlet weak var orderTableView : UITableView!

    
    // MARK: - App life cycle

    override func viewWillAppear(_ animated: Bool) {
        print(storeInfo)
        print(mainMenuDic)
        print(tempExtraMenuDic)
        extraMenuDic = self.tempExtraMenuDic
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let extraMenuDic = extraMenuDic {
            return extraMenuDic.count + 7
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1. 주문서 제목 셀을 정의한다.
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderTitleCell", for: indexPath) as! OrderTitleCell
            cell.isUserInteractionEnabled = false
            tableView.rowHeight = 40
            return cell
        }
        // 2. 매장 정보 셀을 정의한다.
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderStoreCell", for: indexPath) as! OrderStoreCell
            cell.isUserInteractionEnabled = false
            cell.orderStoreTitleLabel.text = self.storeInfo.1
            tableView.rowHeight = 40
            return cell
        }
        // 3. 메인 메뉴 정보 셀을 정의한다.
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderMainMenuCell", for: indexPath) as! OrderMainMenuCell
            cell.isUserInteractionEnabled = false
            cell.orderMainMenuNameLabel.text = self.mainMenuDic[Constants.Order.MAIN_MANU_NAME]
            cell.orderMainMenuPriceLabel.text = self.mainMenuDic[Constants.Order.MAIN_MANU_PRICE]
            tableView.rowHeight = 40
            return cell
        }
        // 4. 총 금액 정보 셀을 정의한다.
        else if indexPath.row == (extraMenuDic!.count  + 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderTotalPriceCell", for: indexPath) as! OrderTotalPriceCell
            cell.isUserInteractionEnabled = false
            cell.orderTotalPriceLabel.text = String(self.totalPrice)
            tableView.rowHeight = 40
            return cell
        }// 5. 요구인원 정보 셀을 정의한다.
        else if indexPath.row == (extraMenuDic!.count + 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderPeopleNumCell", for: indexPath) as! OrderPeopleNumCell
            cell.isUserInteractionEnabled = false
            cell.orderPeopleNumLabel.text = mainMenuDic[Constants.Order.MAIN_MANU_PEOPLE_NUM]
            tableView.rowHeight = 40
            return cell
        }
        // 6. 최대 대기 시간 정보 셀을 정의한다.
        else if indexPath.row == (extraMenuDic!.count + 5) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderLimitTimeCell", for: indexPath) as! OrderLimitTimeCell
            cell.isUserInteractionEnabled = false
            tableView.rowHeight = 40
            return cell
        }
        // 7. 최대 대기시간 Picker 셀을 정의한다.
        else if indexPath.row == (extraMenuDic!.count + 6) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderTimePickerCell", for: indexPath) as! OrderTimePickerCell
            
            tableView.rowHeight = 200
            return cell
        }
        // 8. 추가메뉴 정보 셀을 정의한다.
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderExtraMenuCell", for: indexPath) as! OrderExtraMenuCell
            cell.isUserInteractionEnabled = false
            if let extraMenu = tempExtraMenuDic.popFirst() {
                cell.orderExtraMenuNameLabel.text = extraMenu.value.2
                cell.orderExtraMenuPriceLabel.text = String(extraMenu.value.1)
                cell.orderExtraMenuCountLabel.text = String(extraMenu.value.0)
            }

            tableView.rowHeight = 40
            return cell
        }
    }
    
    // MARK: - Picker view data source

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSoruce.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSoruce[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let cell = orderTableView.cellForRow(at: IndexPath.init(row: (self.extraMenuDic!.count + 5), section: 0)) as? OrderLimitTimeCell {
            cell.orderLimitTimeLabel.text = pickerDataSoruce[row]
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
            signController.callView = "orderView"
            present(signController, animated: true, completion: nil)
        } else {

            var parameters : Parameters = [:]
            
            let userId : String = UserDefaults.standard.string(forKey: Constants.User.USER_ID)!
            parameters[Constants.Order.USER_ID] = userId
            parameters[Constants.Order.STORE_ID] = storeInfo.0
            parameters[Constants.Order.MAIN_MENU_ID] = mainMenuDic[Constants.Order.MAIN_MENU_ID]
            
            if let extraMenuDic = self.extraMenuDic {
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
            
            Alamofire.request(self.ORDER_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseObject(completionHandler: {
                (response: DataResponse<OrderResponseInfoObject>) in
                dump(response)
                if let orderResponseInfoObject = response.result.value {
                    if orderResponseInfoObject.massage == "success" && orderResponseInfoObject.status == "match"  {
                        let alert = UIAlertController(title: "매칭완료", message: "매칭이 완료되었습니다", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "결제하기", style: .default, handler: { action in
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
                naviController.popToRootViewController(animated: true)
            }
        })
    }
}
