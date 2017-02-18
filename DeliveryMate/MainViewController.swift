//
//  MapViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 7..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class CategoriesInfoObject: Mappable {
    var categoryId : Int?
    var categoryName: String?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        categoryId <- map["id"]
        categoryName <- map["name"]
    }
}

class MainViewController : UIViewController {
    let CATEGORIES_URL = Constants.SERVER_URL+"/categories"
    var userDongCode : String?
    var userSimpleAddress : String?
    var tmpButton : UIButton?
    var categoriesInfoObject: [CategoriesInfoObject?] = []
    
    @IBOutlet weak var addressLabel: UILabel!

    // MARK: - App Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
//        if UserDefaults.standard.string(forKey: Constants.User.USER_ADDRESS) != "" {
//            userSimpleAddress = UserDefaults.standard.string(forKey: Constants.User.USER_ADDRESS)
//        }
//        
//        if UserDefaults.standard.string(forKey: Constants.User.USER_DONG_CODE) != "" {
//            userDongCode = UserDefaults.standard.string(forKey: Constants.User.USER_ADDRESS)
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false

        print("USER INFO SIMPLE ADDRESS \(UserDefaults.standard.string(forKey: Constants.User.USER_SIMPLE_ADDRESS))")
        print("USER INFO DONG CODE \(UserDefaults.standard.string(forKey: Constants.User.USER_DONG_CODE))")
        print("USER INFO ID \(UserDefaults.standard.string(forKey: Constants.User.USER_ID))")
        print("Constants.User.USER_NAME \(UserDefaults.standard.string(forKey: Constants.User.USER_NAME))")
        print("USER INFO ADDRESS \(UserDefaults.standard.string(forKey: Constants.User.USER_ADDRESS))")
        
        // 1. 사용자의 현재 지역명을 보여주고, UserDefault에 간단주소정보와 법정동코드를 저장한다.
        if let userSimpleAddress = self.userSimpleAddress, let userDongCode = self.userDongCode {
            self.addressLabel.text = userSimpleAddress
            UserDefaults.standard.set(userDongCode, forKey:Constants.User.USER_DONG_CODE)
            UserDefaults.standard.set(userSimpleAddress, forKey:Constants.User.USER_SIMPLE_ADDRESS)
        }

        // 2. 서버에 카테고리 정보를 요청한다.
        Alamofire.request(CATEGORIES_URL).responseArray(completionHandler: {
            (response: DataResponse<[CategoriesInfoObject]>) in
            if let categoriesInfo = response.result.value {
                self.categoriesInfoObject = categoriesInfo
                for category in self.categoriesInfoObject {
                    //self.tmpButton = self.view.viewWithTag((category?.categoryId)!) as? UIButton
                    //self.tmpButton?.setTitle(category?.categoryName, for: .normal)
                }
            }
        })
    }
    
    // MARK: - Action

    @IBAction func categoryButtonPressed(_ sender: Any) {
        let categoryButton = sender as! UIButton
        let storesListViewController : StoresListViewController
        storesListViewController = self.storyboard?.instantiateViewController(withIdentifier: "storesView") as! StoresListViewController

        if let userDongCode = self.userDongCode {
            storesListViewController.dongCode = userDongCode
            storesListViewController.categoryId = categoryButton.tag
            self.navigationController?.pushViewController(storesListViewController, animated: true)
        } else {
            let alert = UIAlertController(title: "", message: "현재 지역을 설정해주세요", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    
    @IBAction func pinButtonPressed(_ sender: Any) {
        let controller : MapSearchViewController
        controller = self.storyboard?.instantiateViewController(withIdentifier: "mapSearchView") as! MapSearchViewController
        controller.delegate = self
        present(controller, animated: true, completion: nil)
        
    }
}
