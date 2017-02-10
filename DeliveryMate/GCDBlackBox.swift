//
//  GCDBlackBox.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 9..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

