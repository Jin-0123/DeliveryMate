//
//  MatchDetailViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 17..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit

class MatchDetailViewController : UIViewController {
    var orderViewDelegate : OrderViewController?
    var meunDetailDelegate : MenuDetailViewController?
    @IBAction func closeButtonPressed(_ sender: Any) {
        // 닫기버튼을 누르면, 주문상태창, 주문서창을 닫고, 메인메뉴 화면으로 이동한다.
        self.dismiss(animated: true, completion: {
            if let orderController = self.orderViewDelegate {
                orderController.goToMainView()
            }
        })
    }

}
