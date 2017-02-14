//
//  GeoPoint2Address.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 10..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

struct Pnt2AddrConstants {
    
    struct DaumMap {
        static let APIScheme = "https"
        static let APIHost = "apis.daum.net"
        static let APIPath = "/local/geo/coord2addr"
    }
    
    struct MapParameterKeys {
        static let APIKey = "apikey"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Output = "output"
    }
    
    struct MapParameterValues {
        static let APIKey = "5720085b0e5e9164353f4c6d944bae37"
        static let Output = "json"
    }
    
    struct MapResponseKeys {
        static let Do = "name1"
        static let Gu = "name2"
        static let Dong = "name3"
        static let DongCode = "code3"
    }
    
    struct MapResponseValues {
        static let OKStatus = "ok"
    }
}
