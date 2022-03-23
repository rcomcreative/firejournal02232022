//
//  DateExtension.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/22/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

extension Date {
    
    func timeStamp()->String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        return dateFormatter.string(from: date)
    }
    
    func add(hours: Int) ->Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: Date())!
    }
    
    func month(date:Date) -> [Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let monthNumber: Int = Int(dateFormatter.string(from: date))!
        dateFormatter.dateFormat = "MMMM"
        let dateFrom = dateFormatter.string(from: date)
        return [dateFrom,monthNumber]
    }
    
    func stringDate(date:Date)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE MMM dd,YYYY HH:mm:ss"
        let stringDate = dateFormatter.string(from: date)
        return stringDate
    }
    
    func stringTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let stringDate = dateFormatter.string(from: date)
        return stringDate
    }
    
    func forwardMonth(month: Date) ->[ Any ] {
        let m = Calendar.current.date(byAdding: .month, value: 1, to: month)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let dateFrom = dateFormatter.string(from: m!)
        dateFormatter.dateFormat = "MM"
        let monthNumber: Int = Int(dateFormatter.string(from: m!))!
        return [dateFrom, monthNumber, m as Any]
    }
    
    func backwardMonth(month: Date) ->[ Any ]  {
        let m = Calendar.current.date(byAdding: .month, value: -1, to: month)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let dateFrom = dateFormatter.string(from: m!)
        dateFormatter.dateFormat = "MM"
        let monthNumber: Int = Int(dateFormatter.string(from: m!))!
        return [dateFrom, monthNumber, m as Any]
    }

}
