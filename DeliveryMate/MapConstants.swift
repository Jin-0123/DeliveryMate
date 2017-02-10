//
//  MapConstants.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 7..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

struct MapConstants {
    
    struct DaumMap {
        
        static let APIScheme = "https"
        static let APIHost = "apis.daum.net"
        static let APIPath = "/local/v1/search/keyword.json"
    }
    
    struct MapParameterKeys {
        static let APIKey = "apikey"
        static let Query = "query"
    }
    
    struct MapParameterValues {
        static let APIKey = "5720085b0e5e9164353f4c6d944bae37"
    }
    
    struct MapResponseKeys {
            static let Channel = "channel"
            static let Item = "item"
            static let Title = "title"
            static let Latitude = "latitude"
            static let Longitude = "longitude"
            static let NewAddress = "newAddress"
            static let Address = "address"
    }
    
    struct MapResponseValues {
        static let OKStatus = "ok"
    }
}
