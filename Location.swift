//
//  Location.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 9..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

//struct Location {
//    let title : String?
//    let newAddress : String?
//    let latitude : String?
//    let longitude : String?
//    
//    init(dictionary: [String:AnyObject]) {
//        title = dictionary[MapConstants.MapResponseKeys.Title] as? String
//        latitude = dictionary[MapConstants.MapResponseKeys.Latitude] as? String
//        longitude = dictionary[MapConstants.MapResponseKeys.Longitude] as? String
//        newAddress = dictionary[MapConstants.MapResponseKeys.NewAddress] as? String
//    }
//    
//    static func locationFromResults(_ results: [[String:AnyObject]]) -> [Location] {
//        var locations = [Location]()
//        
//        for result in results {
//            locations.append(Location(dictionary: result))
//        }
//        return locations
//    }
//    
//}
