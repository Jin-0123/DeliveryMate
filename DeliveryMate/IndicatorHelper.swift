//
//  indicatorHelper.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 22..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import Foundation
import UIKit

class IndicatorHelper {
    var indicator: UIActivityIndicatorView!
    var view : UIView
    init(view: UIView){
        self.view = view
        self.indicator = UIActivityIndicatorView()
        self.indicator.frame = CGRect(x:0.0, y:0.0, width:40.0, height:40.0)
        self.indicator.backgroundColor = UIColor.darkGray
        self.indicator.center = view.center
        self.indicator.hidesWhenStopped = true
        self.indicator.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.white
        view.addSubview(self.indicator)
    }
    
    func start(){
        self.indicator.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    func stop(){
        self.indicator.stopAnimating()
        self.indicator.removeFromSuperview()
        self.view.isUserInteractionEnabled = true
    }
    
}
