//
//  ExtraMenuViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 16..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit

class MenuDetailViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    let NAVIGATION_RIGHT_BUTTON_TITLE = "선택완료"
    var menuListDelegate : MenuListViewController?
    
    // extraMenuDic : 서버에서 받아온 추가메뉴 리스트 (extra_menu_id, extra_menu_name, extra_menu_price)
    var extraMenuList : [(Int, String, Int)] = []
    
    // storeInfo : 선택한 매장 정보를 저장한다. (store_id, store_Name)
    var storeInfo: (Int, String) = (0,"")

    // mainMenuDic : 선택한 메인메뉴 정보를 저장한다.
    var mainMenuDic : [String:String] = [:]
    
    
    // selectedExtraMenuDic : 선택된 추가메뉴를 저장해서 MenuList 화면으로 넘겨준다. (id: (count, price, name))
    var selectedExtraMenuDic = [Int:(Int,Int,String)]()
    
    var totalPrice : Int = 0
    

    // MARK: - Outlet

    @IBOutlet weak var extraMenuTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    
    // MARK: - App Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = mainMenuDic[Constants.Order.MAIN_MANU_NAME]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NAVIGATION_RIGHT_BUTTON_TITLE, style: .plain, target: self, action: #selector(selectMenusButtonPressed))
        self.tabBarController?.tabBar.isHidden = true
        self.totalPrice = self.totalPrice + Int(mainMenuDic[Constants.Order.MAIN_MANU_PRICE]!)!
        self.totalPriceLabel.text = String(totalPrice)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extraMenuList.count + 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuImageCell", for: indexPath) as! MenuImageCell
            cell.isUserInteractionEnabled = false
            tableView.rowHeight = 200
            return cell
            
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuDetailCell", for: indexPath) as! MenuDetailCell
            cell.isUserInteractionEnabled = false
            cell.menuNameLabel.text = mainMenuDic[Constants.Order.MAIN_MANU_NAME]
            cell.menuPriceLabel.text = mainMenuDic[Constants.Order.MAIN_MANU_PRICE]
            cell.menuPeopleNumLabel.text = mainMenuDic[Constants.Order.MAIN_MANU_PEOPLE_NUM]
            tableView.rowHeight = 100
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "extraMenuCell", for: indexPath) as! ExtraMenuCell
            
            let idx = indexPath.row - 2
            cell.extraMenuNameLabel.text = extraMenuList[idx].1
            cell.extraMenuPriceLabel.text = String(extraMenuList[idx].2)
            cell.checkImageView.isHidden = true
            tableView.rowHeight = 80
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) as? ExtraMenuCell {
            cell.checkImageView.isHidden = false
            cell.minusButton.isEnabled = false
            cell.plusButton.isEnabled = false
            if let extraMenuCount = Int(cell.extraMenuCountLabel.text!) {
                let idx = indexPath.row - 2
                self.selectedExtraMenuDic[extraMenuList[idx].0] = (extraMenuCount, extraMenuList[idx].2,extraMenuList[idx].1)
                self.totalPrice = self.totalPrice + extraMenuCount * extraMenuList[idx].2
                self.totalPriceLabel.text = String(totalPrice)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) as? ExtraMenuCell   {
            cell.checkImageView.isHidden = true
            cell.minusButton.isEnabled = true
            cell.plusButton.isEnabled = true
            let idx = indexPath.row - 2
            self.selectedExtraMenuDic.removeValue(forKey: extraMenuList[idx].0)
            if let extraMenuCount = Int(cell.extraMenuCountLabel.text!) {
                self.totalPrice = self.totalPrice - extraMenuCount * extraMenuList[idx].2
                self.totalPriceLabel.text = String(totalPrice)
            }
        }
    }
    
    // MARK: - Action
    
    func selectMenusButtonPressed() {
        let orderController : OrderViewController
        orderController = self.storyboard?.instantiateViewController(withIdentifier: "orderView") as! OrderViewController
        orderController.mainMenuDic = self.mainMenuDic
        orderController.tempExtraMenuDic = self.selectedExtraMenuDic
        orderController.storeInfo = self.storeInfo
        orderController.totalPrice = self.totalPrice
        orderController.delegate = self
        present(orderController, animated: true, completion: nil)
    }
}
