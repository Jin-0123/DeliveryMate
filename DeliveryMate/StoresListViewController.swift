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
    var imageURL : String?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        storeId <- map["id"]
        storeName <- map["name"]
        imageURL <- map["image_url"]
    }
}

class StoresListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    let NAVIGATION_TITLE : String = "매장선택"
    let STORES_URL = Constants.SERVER_URL+"/stores"
    
    var categoryId : Int = 0
    var dongCode : String = ""
    var storesInfoObject: [StoresInfoObject] = []
    
    @IBOutlet weak var storesTableView: UITableView!

    // MARK: - App Life Cycle

    override func viewDidLoad() {
        // 1. 네비게이션 타이틀을 설정한다.
        self.navigationItem.title = NAVIGATION_TITLE
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 1. 서버에 매장 정보 요청시 보낼 파라미터 설정한다.
        let parameters : Parameters = [
            "category_id" : categoryId,
            "dong_code" : dongCode
        ]
        
        // 2. 서버에 매장정보를 요청한다.
        Alamofire.request(STORES_URL, parameters: parameters, encoding: URLEncoding.default).responseArray(completionHandler: {
            (response: DataResponse<[StoresInfoObject]>) in
            // 2-1. 응답 데이터를 매장 객체에 저장한다.
            if let storesInfo = response.result.value {
                self.storesInfoObject = storesInfo
            }
            // 2-2. 테이블 뷰를 다시 로드한다.
            self.storesTableView.reloadData()
        })
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storesInfoObject.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = storesInfoObject[indexPath.row].storeName
        return cell
    }
    
    // didSelectRowAt : 셀이 선택되면, 선택된 매장 정보를 보여주는 화면을 띄운다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuListViewController : MenuListViewController
        menuListViewController = self.storyboard?.instantiateViewController(withIdentifier: "menuList") as! MenuListViewController
        
        if let storeId =  storesInfoObject[indexPath.row].storeId {
            menuListViewController.storeId = storeId
            self.navigationController?.pushViewController(menuListViewController, animated: true)
        }
    }
}
