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
    
    let delegate = UIViewController()
    var userDongCode : String?
    var userSimpleAddress : String?
    var tmpButton : UIButton?
    //self.view.viewWithTag(tmpTag) as? UIButton
    @IBOutlet weak var addressLabel: UILabel!

    var categoriesInfoObject: [CategoriesInfoObject?] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let userSimpleAddress = self.userSimpleAddress, let userDongCode = self.userDongCode {
            self.addressLabel.text = userSimpleAddress+" "+userDongCode
        }
        
        Alamofire.request("http://ec2-52-79-190-145.ap-northeast-2.compute.amazonaws.com:3000/categories").responseArray(completionHandler: {
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

    @IBAction func categoryButtonPressed(_ sender: Any) {
        let categoryButton = sender as! UIButton
        let storesListViewController : StoresListViewController
        storesListViewController = self.storyboard?.instantiateViewController(withIdentifier: "storesList") as! StoresListViewController

        if let userDongCode = self.userDongCode {
            storesListViewController.dongCode = userDongCode
            storesListViewController.categoryId = categoryButton.tag
            self.navigationController?.pushViewController(storesListViewController, animated: true)
        }
        
        
    }
    
    
    @IBAction func pinButtonPressed(_ sender: Any) {
        let controller : MapSearchViewController
        controller = self.storyboard?.instantiateViewController(withIdentifier: "mapSearch") as! MapSearchViewController
        controller.delegate = self
        present(controller, animated: true, completion: nil)
        
    }
}
