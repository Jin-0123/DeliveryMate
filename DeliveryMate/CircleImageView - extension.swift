//
//  CircleImageView - extension.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 21..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import Foundation

extension UIImageView {
    func circleImageView() {
        self.layer.cornerRadius = self.frame.height/2
        self.layer.masksToBounds = true
    }
}
