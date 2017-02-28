//
//  ExtraMenuViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 16..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit
import Nuke

class MenuDetailViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    let NAVIGATION_RIGHT_BUTTON_TITLE = "선택완료"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var menuListDelegate : MenuListViewController?
    
    // extraMenuDic : 서버에서 받아온 추가메뉴 리스트 (extra_menu_id, extra_menu_name, extra_menu_price)
    var extraMenuList : [(Int, String, Int)] = []
    
    // tempExtraMenuDic : 사용자의 선택, 해제에 따라 추가메뉴를 저장한다. (id: (count, price, name))
    var tempExtraMenuDic = [Int:(Int, Int, String)]()
    var totalPrice : Int = 0

    
    

    // MARK: - Outlet

    @IBOutlet weak var extraMenuTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    
    // MARK: - App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {

        self.navigationItem.title = appDelegate.currentOrder.mainMenuDic[Constants.Order.MAIN_MANU_NAME]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NAVIGATION_RIGHT_BUTTON_TITLE, style: .plain, target: self, action: #selector(selectMenusButtonPressed))
        self.tabBarController?.tabBar.isHidden = true
        
        if self.totalPrice == 0 {
            self.totalPrice = self.totalPrice + Int(appDelegate.currentOrder.mainMenuDic[Constants.Order.MAIN_MANU_PRICE]!)!
        }
        
        self.totalPriceLabel.text = String(self.totalPrice)
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuDetailCell", for: indexPath) as! MenuDetailCell
            cell.isUserInteractionEnabled = false
            cell.menuNameLabel.text = appDelegate.currentOrder.mainMenuDic[Constants.Order.MAIN_MANU_NAME]
            cell.menuPriceLabel.text = appDelegate.currentOrder.mainMenuDic[Constants.Order.MAIN_MANU_PRICE]
            cell.menuPeopleNumLabel.text = appDelegate.currentOrder.mainMenuDic[Constants.Order.MAIN_MANU_PEOPLE_NUM]
            tableView.rowHeight = 100
            return cell
            
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuImageCell", for: indexPath) as! MenuImageCell
            cell.isUserInteractionEnabled = false
            if let imageURL = appDelegate.currentOrder.mainMenuDic[Constants.Order.MAIN_MANU_IMAGE_URL] {
                let imageURL = Constants.SERVER_URL+imageURL
                let url = URL(string: imageURL)!
                Nuke.loadImage(with: url, into: cell.menuImageView)
            }
            tableView.rowHeight = 200
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "extraMenuCell", for: indexPath) as! ExtraMenuCell
            
            let idx = indexPath.row - 2
            cell.extraMenuNameLabel.text = extraMenuList[idx].1
            cell.extraMenuPriceLabel.text = String(extraMenuList[idx].2)
            tableView.rowHeight = 44
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) as? ExtraMenuCell {
                cell.minusButton.isEnabled = false
                cell.plusButton.isEnabled = false
                cell.checkBoxImageView.image = UIImage(named: "checked-box")

            
                if let extraMenuCount = Int(cell.extraMenuCountLabel.text!) {
                    let idx = indexPath.row - 2

                    self.tempExtraMenuDic[extraMenuList[idx].0] = (extraMenuCount, extraMenuList[idx].2,extraMenuList[idx].1)
                    self.totalPrice =  self.totalPrice + extraMenuCount * extraMenuList[idx].2
                    self.totalPriceLabel.text = String(self.totalPrice)
                }
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) as? ExtraMenuCell   {

                cell.minusButton.isEnabled = true
                cell.plusButton.isEnabled = true
                cell.checkBoxImageView.image = UIImage(named: "check-box")

                let idx = indexPath.row - 2
            
                if let extraMenuCount = Int(cell.extraMenuCountLabel.text!) {
                    self.totalPrice = self.totalPrice - extraMenuCount * extraMenuList[idx].2
                    self.totalPriceLabel.text = String(self.totalPrice)
                }
                tempExtraMenuDic.removeValue(forKey: extraMenuList[idx].0)            
        }
    }
    
    // MARK: - Action
    
    func selectMenusButtonPressed() {
        let orderController : OrderViewController
        orderController = self.storyboard?.instantiateViewController(withIdentifier: "orderView") as! OrderViewController
        appDelegate.currentOrder.extraMenuDic = self.tempExtraMenuDic
        appDelegate.currentOrder.totalPrice = self.totalPrice
        orderController.delegate = self
        present(orderController, animated: true, completion: nil)
    }
}
