//
//  EventBuilder.swift
//  Eventure
//
//  Created by Mukhamed Issa on 1/14/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import Foundation

class EventBuilder {
    
    var id: String?
    var eventName: String?
    var eventDescription: String?
    var photoId: String?
    var timestamp: String?
    var addedByUser: String?
    var rating: Float?
    var location: Dictionary<String, Float>?
    var address: String?
    
    typealias BuilderClosure = (EventBuilder) -> ()
    
    init(buildClosure: BuilderClosure) {
        buildClosure(self)
    }
}
