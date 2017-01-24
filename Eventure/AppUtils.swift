//
//  AppUtils.swift
//  Eventure
//
//  Created by Mukhamed Issa on 1/3/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import Foundation
import Firebase

class AppUtils {
    
    static func isLoggedIn() -> Bool {
        return FIRAuth.auth()?.currentUser != nil
    }
    
    static func getCurrentUser() -> FIRUser {
        return (FIRAuth.auth()?.currentUser)!
    }
    
    static func colorFromHex(rgbValue: UInt32, alpha:Double = 1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}
