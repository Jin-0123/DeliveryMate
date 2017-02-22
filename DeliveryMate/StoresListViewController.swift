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
import Nuke

// StoresResponseInfo : 서버에서 받아온 매장 리스트 맵핑에 필요한 객체를 선언한다.
class StoresResponseInfo: Mappable {
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
    let NAVIGATION_TITLE: String = "매장선택"
    let STORES_URL = Constants.SERVER_URL+"/stores"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var storesResponseInfo: [StoresResponseInfo] = []

    var categoryId: Int = 0
    var dongCode: String = ""
    
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
            (response: DataResponse<[StoresResponseInfo]>) in
            // 2-1. 응답 데이터를 매장 객체에 저장한다.
            if let storesInfo = response.result.value {
                self.storesResponseInfo = storesInfo
            }
            // 2-2. 테이블 뷰를 다시 로드한다.
            self.storesTableView.reloadData()
        })
    }
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storesResponseInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as! StoreListCell
        cell.storeNameLabel.text = storesResponseInfo[indexPath.row].storeName
        cell.storeImageView.circleImageView()
        
        let imageURL = Constants.SERVER_URL+storesResponseInfo[indexPath.row].imageURL!
        let url = URL(string: imageURL)!
        Nuke.loadImage(with: url, into: cell.storeImageView)
        
        return cell
    }
    
    // didSelectRowAt : 셀이 선택되면, 선택된 매장 정보를 보여주는 화면을 띄운다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuListViewController : MenuListViewController
        menuListViewController = self.storyboard?.instantiateViewController(withIdentifier: "menuView") as! MenuListViewController
        
        if let storeId = storesResponseInfo[indexPath.row].storeId, let storeName = storesResponseInfo[indexPath.row].storeName
        {
            appDelegate.currentOrder.storeDic[Constants.Order.STORE_ID] = String(storeId)
            appDelegate.currentOrder.storeDic[Constants.Order.STORE_NAME] = storeName
            self.navigationController?.pushViewController(menuListViewController, animated: true)
        }
    }
}
