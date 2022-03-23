//
//  StringToDateFormat.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/31/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

class RecordIDToDate {
    
    let stringDate:String
    var year:String = ""
    var month:String = ""
    var day: String = ""
    var hours: String = ""
    var minutes:String = ""
    var seconds:String = ""
    var date:Date?
    var substring:String = ""
//    YYYYDDDMMHHmmAAAAAAAA
//    201900701162359008748
    
    init(stringDate:String) {
        self.stringDate = stringDate
    }
    
    func convertStringToDate() -> Date {
        substring = stringDate
        let yearBound = substring.index(substring.endIndex, offsetBy: -17)
        let shaveDate = substring.index(substring.endIndex, offsetBy: -16)
        let dayBound = substring.index(substring.endIndex,offsetBy: -14)
        let monthBound = substring.index(substring.endIndex, offsetBy: -12)
        let hourBound = substring.index(substring.endIndex, offsetBy: -10)
        let minuteBound = substring.index(substring.endIndex, offsetBy: -8)
        let secondsBound = substring.index(substring.endIndex, offsetBy: 0)
        
        year = String(substring[..<yearBound])
        day = String(substring[shaveDate..<dayBound])
        month = String(substring[dayBound..<monthBound])
        hours = String(substring[monthBound..<hourBound])
        minutes = String(substring[hourBound..<minuteBound])
        seconds = String(substring[minuteBound..<secondsBound])
        
        let timeString = "\(year)/\(month)/\(day) \(hours):\(minutes):\(seconds)"
//        let timeString = "\(year)/\(month)/\(day)"
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:AAAAAAAA"
        date = dateFormatter.date(from: timeString)
        
        
        
        return date ?? Date()
    }
    
    
}
