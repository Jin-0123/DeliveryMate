//
//  StoresListViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 14..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class StoresInfoObject : Mappable {
    var storeId : Int?
    var storeName: String?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        storeId <- map["id"]
        storeName <- map["name"]
    }
}

class StoresListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var categoryId : Int = 0
    var dongCode : String = ""
    var storesInfoObject: [StoresInfoObject] = []
    
    @IBOutlet weak var storesTableView: UITableView!

    override func viewDidLoad() {
        self.navigationItem.title = "매장선택"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let parameters : Parameters = [
            "category_id" : categoryId,
            "dong_code" : dongCode
        ]
        
        Alamofire.request("http://ec2-52-79-190-145.ap-northeast-2.compute.amazonaws.com:3000/stores", parameters: parameters, encoding: URLEncoding.default).responseArray(completionHandler: {
            (response: DataResponse<[StoresInfoObject]>) in
            if let storesInfo = response.result.value {
                self.storesInfoObject = storesInfo
            }
            self.storesTableView.reloadData()
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storesInfoObject.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = storesInfoObject[indexPath.row].storeName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        let menuListViewController : MenuListViewController
        menuListViewController = self.storyboard?.instantiateViewController(withIdentifier: "menuList") as! MenuListViewController
        
        if let storeId =  storesInfoObject[indexPath.row].storeId {
            menuListViewController.storeId = storeId
            self.navigationController?.pushViewController(menuListViewController, animated: true)
        }
    }
}
