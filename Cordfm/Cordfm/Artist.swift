//
//  Artist.swift
//  Cordfm
//
//  Created by Drew Patel on 11/17/19.
//  Copyright © 2019 Drew Patel. All rights reserved.
//

import Foundation
import SwiftyJSON

class Artist {
    
    var artistUrl : String!
    var id : Int!
    var imageUrl : String!
    var name : String!
    var onTour : Bool!
    var trackUrl : String!
    var trackerCount : Int!

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(json: JSON!){
        if json.isEmpty{
            return
        }
        artistUrl = json["artist_url"].stringValue
        id = json["id"].intValue
        imageUrl = json["image_url"].stringValue
        name = json["name"].stringValue
        onTour = json["on_tour"].boolValue
        trackUrl = json["track_url"].stringValue
        trackerCount = json["tracker_count"].intValue
    }
}
