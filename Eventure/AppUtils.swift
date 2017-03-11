//
//  AppUtils.swift
//  Eventure
//
//  Created by Mukhamed Issa on 1/3/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import Foundation
import Firebase
import Crashlytics

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
    
    static func dateFromString(stringDate: String) -> Date {
        return getDateFormatter().date(from: stringDate)!
    }
    
    static func stringFromDate(date: Date) -> String {
        return getDateFormatter().string(from: date)
    }
    
    static func getDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        return formatter
    }
    
    static func isDateInCurrentWeek(date: Date) -> Bool {
        return (Date().startOfWeek...Date().endOfWeek).contains(date)
    }
    
    static func testCrash() {
        Crashlytics.sharedInstance().crash()
    }
    
}

extension Date {
    var startOfWeek: Date {
        let date = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        let dslTimeOffset = NSTimeZone.local.daylightSavingTimeOffset(for: date)
        return date.addingTimeInterval(dslTimeOffset)
    }
    
    var endOfWeek: Date {
        return Calendar.current.date(byAdding: .second, value: 604799, to: self.startOfWeek)!
    }
}
