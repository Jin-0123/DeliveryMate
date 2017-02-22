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

// CategoriesResponseInfo : 서버에서 받아온 매장 리스트 맵핑에 필요한 객체를 선언한다.
class CategoriesResponseInfo: Mappable {
    var categoryId : Int?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        categoryId <- map["id"]
    }
}

class MainViewController : UIViewController {
    let CATEGORIES_URL = Constants.SERVER_URL+"/categories"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var categoriesResponseInfo: [CategoriesResponseInfo?] = []

    var userDongCode : String?
    var userSimpleAddress : String?
    var tmpButton : UIButton?
    
    @IBOutlet weak var addressLabel: UILabel!

    // MARK: - App Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
                
        appDelegate.currentOrder.clear()
        
        
        // 1. 사용자의 현재 지역명을 보여주고, UserDefault에 간단주소정보와 법정동코드를 저장한다.
        if let userSimpleAddress = self.userSimpleAddress, let userDongCode = self.userDongCode {
            self.addressLabel.text = userSimpleAddress
            UserDefaults.standard.set(userDongCode, forKey:Constants.User.USER_DONG_CODE)
            UserDefaults.standard.set(userSimpleAddress, forKey:Constants.User.USER_SIMPLE_ADDRESS)
        }

        // 2. 서버에 카테고리 정보를 요청한다.
        Alamofire.request(CATEGORIES_URL).responseArray(completionHandler: {
            (response: DataResponse<[CategoriesResponseInfo]>) in
            if let categoriesInfo = response.result.value {
                self.categoriesResponseInfo = categoriesInfo
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
