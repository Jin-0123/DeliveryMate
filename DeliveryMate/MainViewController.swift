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
    
    let delegate = UIViewController()
    var userDongCode : String?
    var userSimpleAddress : String?
    var tmpButton : UIButton?
    var categoriesInfoObject: [CategoriesInfoObject?] = []
    
    @IBOutlet weak var addressLabel: UILabel!

    // MARK: - App Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 1. 사용자의 현재 지역명을 보여준다.
        if let userSimpleAddress = self.userSimpleAddress {
            self.addressLabel.text = userSimpleAddress
        }
        
        // 2. 서버에 카테고리 정보를 요청한다.
        Alamofire.request(CATEGORIES_URL).responseArray(completionHandler: {
            (response: DataResponse<[CategoriesInfoObject]>) in
            if let categoriesInfo = response.result.value {
                self.categoriesInfoObject = categoriesInfo
                for category in self.categoriesInfoObject {
                    self.tmpButton = self.view.viewWithTag((category?.categoryId)!) as? UIButton
                    self.tmpButton?.setTitle(category?.categoryName, for: .normal)
                }
            }
        })
    }
    
    // MARK: - Action

    @IBAction func categoryButtonPressed(_ sender: Any) {
        let categoryButton = sender as! UIButton
        let storesListViewController : StoresListViewController
        storesListViewController = self.storyboard?.instantiateViewController(withIdentifier: "storesList") as! StoresListViewController

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
        controller = self.storyboard?.instantiateViewController(withIdentifier: "mapSearch") as! MapSearchViewController
        controller.delegate = self
        present(controller, animated: true, completion: nil)
        
    }
}
