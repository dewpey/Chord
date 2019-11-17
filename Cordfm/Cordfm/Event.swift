//
//  Event.swift
//  Cordfm
//
//  Created by Drew Patel on 11/17/19.
//  Copyright © 2019 Drew Patel. All rights reserved.
//

import Foundation
import SwiftyJSON

class Event{
    
    var artistId : Int!
    var artistName: String!
    var eventUrl : String!
    var id : Int!
    var imageUrl : String!
    var lineup : [Int]!
    var rsvpCount : Int!
    var rsvpUrl : String!
    var startsAt : String!
    var ticketAvailable : Bool!
    var ticketUrl : String!
    var title : String!
    var venueId : Int!
    var date: Date!
    
    init(json: JSON!, embeddables: JSON!){
        if json.isEmpty{
            return
        }
        artistId = json["artist_id"].intValue
        eventUrl = json["event_url"].stringValue
        id = json["id"].intValue
        imageUrl = json["image_url"].stringValue
        lineup = [Int]()
        let lineupArray = json["lineup"].arrayValue
        for lineupJson in lineupArray{
            lineup.append(lineupJson.intValue)
        }
        rsvpCount = json["rsvp_count"].intValue
        rsvpUrl = json["rsvp_url"].stringValue
        startsAt = json["starts_at"].stringValue
        ticketAvailable = json["ticket_available"].boolValue
        ticketUrl = json["ticket_url"].stringValue
        title = json["title"].stringValue
        venueId = json["venue_id"].intValue
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        date = dateFormatter.date(from: json["starts_at"].stringValue)
        
        let artists = embeddables["artists"]
        for artist in artists.arrayValue {
            if(artist["id"].intValue == artistId ){
                artistName = artist["name"].stringValue
            }
        }
    }
    
    func getDateString() -> String {
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "MM/dd hh:mma"

        let myString = formatter.string(from: date)
        return myString
    }
    
}

