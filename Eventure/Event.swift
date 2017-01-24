//
//  Event.swift
//  Eventure
//
//  Created by Mukhamed Issa on 12/26/16.
//  Copyright © 2016 Mukhamed Issa. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Event: NSObject {
    
    var id: String
    var eventName: String
    var eventDescription: String
    var photoId: String?
    var timestamp: String
    var addedByUser: String
    var rating: Float
    var location: Dictionary<String, Float>
    var address: String
    
    let ref: FIRDatabaseReference?
    
    init?(builder: EventBuilder) {
        if let id = builder.id, let eventName = builder.eventName, let eventDescription = builder.eventDescription,
            let photoId = builder.photoId, let timestamp = builder.timestamp, let rating = builder.rating,
            let location = builder.location, let addedByUser = builder.addedByUser, let address = builder.address {
            
            self.id = id
            self.eventName = eventName
            self.eventDescription = eventDescription
            self.photoId = photoId
            self.timestamp = timestamp
            self.rating = rating
            self.location = location
            self.addedByUser = addedByUser
            self.address = address
            
            self.ref = nil
        } else {
            return nil
        }
    }
    
    init(snapshot: FIRDataSnapshot) {
        id = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        eventName = snapshotValue["eventName"] as! String
        eventDescription = snapshotValue["eventDescription"] as! String
        photoId = snapshotValue["photoId"] as? String
        timestamp = snapshotValue["timestamp"] as! String
        addedByUser = snapshotValue["addedByUser"] as! String
        rating = snapshotValue["rating"] as! Float
        location = snapshotValue["location"] as! Dictionary<String, Float>
        address = snapshotValue["address"] as! String
        
        
        ref = snapshot.ref
    }
    
}
