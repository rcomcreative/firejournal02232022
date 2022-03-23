import UIKit
import Foundation

let timeString = "\(2019)/\(01)/\(30) \(16):\(32):\(57712552)"
let dateFormatter = DateFormatter()
dateFormatter.locale = Locale(identifier: "en_US_POSIX")
dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:AAAAAAAA"
let date = dateFormatter.date(from: timeString)

let milesToPoint = ["point1":120.0,"point2":50.0,"point3":70.0]
let kmToPoint = milesToPoint.map { name,miles in miles * 1.6093 }
print(kmToPoint)

let xaxis = ["monday", "tuesday", "wednesday", "thursday", "friday"]

let yaxis = [1, 2, 3, 4, 5]

var newArr = [(String, Int)]()

for i in 0..<xaxis.count {
        newArr.append((xaxis[i], yaxis[i]))
}
print(newArr)

func hasSigned() -> Bool {
    if _signedDate == nil {
        return false
    }
    return true
}

var _signedDate:Date? = nil
var signedDate:Date {
    get {
        return _signedDate ?? Date() // or some valid date
    }
    set (newDate) {
        _signedDate = newDate
    }
}

hasSigned()
signedDate = Date()
hasSigned()


var dayComp = DateComponents(day: -1)
let dateTry = Calendar.current.date(byAdding: dayComp, to: Date())

let calendar = Calendar.current
let dayComp2 = DateComponents(day: 0)
let dateComponent = calendar.dateComponents([.hour], from: dayComp, to: dayComp2)
let shiftAllotment = DateComponents(hour: 8)
let shift = calendar.dateComponents([.hour], from: shiftAllotment, to: dateComponent)

//Format to 2 decimal


//get time between startShift and EndShift
let startShift = DateComponents(day: 0, hour: 8, minute: 14 )
let endShift = DateComponents(day: 0, hour: 17, minute: 30)
let shiftComponent = calendar.dateComponents( [.second] , from: startShift , to: endShift )
let timeSpend = shiftComponent.second
let hours = ( Double( timeSpend! ) / 60 ) / 60
let timeSpent = ( hours * 100 ).rounded() / 100

let theShift = shift.hour
if theShift! > 0 {
    print("you need to start a new shift")
} else {
    print("you still have time on your shift so start your new file")
}

//if dateComponent > shiftAllotment {
//    print("you need to start a new shift")
//}

//guard let duration = dateComponent.minute else { return }

if UIDevice.current.userInterfaceIdiom == .pad {
    
}

