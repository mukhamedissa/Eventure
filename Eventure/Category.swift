//
//  Category.swift
//  Eventure
//
//  Created by Mukhamed Issa on 12/26/16.
//  Copyright © 2016 Mukhamed Issa. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var userId: String
    var username: String
    var email: String
    var name: String
    var surname: String
    
    init(userId: String, username: String, email: String, name: String, surname: String) {
        self.userId = userId
        self.username = username
        self.email = email
        self.name = name
        self.surname = surname
    }
    
    convenience override init() {
        self.init(userId: "", username: "", email: "", name: "", surname: "")
    }

}
