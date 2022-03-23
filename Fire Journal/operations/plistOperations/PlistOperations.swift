//
//  PlistOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 9/25/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

enum EntryState:Int64 {
    case new, update, updated, failed
}

class GuidFormatter {
    var formatDate: Date
    init(date:Date) {
        self.formatDate = date
    }
    
    func formatGuid()->String {
        var uuidA: String = NSUUID().uuidString.lowercased()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: formatDate)
        uuidA = uuidA+dateFrom
        return uuidA
    }
}

class FormattedDate {
    var dateForFormat: Date
    init(date:Date) {
        self.dateForFormat = date
    }
    
    func formatTheDate()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,YYYY"
        let formattedDate = dateFormatter.string(from: dateForFormat)
        return formattedDate
    }
    
    func formatTheDateAndTime()-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,YYYY HH:mm"
        let formattedDate = dateFormatter.string(from: dateForFormat)
        return formattedDate
    }
}

class FullDateFormat {
    var dateForFullFormat: Date
    init(date:Date) {
        self.dateForFullFormat = date
    }
    
    func formatFullyTheDate()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MM/dd/YYYY HH:mm"
        let fullyFormattedDate = dateFormatter.string(from: dateForFullFormat)
        return fullyFormattedDate
    }
}

class MonthFormat {
    var dateForMonth:Date
    init(date:Date) {
        self.dateForMonth = date
    }
    
    func monthForDate()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let fullyFormattedDate = dateFormatter.string(from: dateForMonth)
        return fullyFormattedDate
    }
}

class DayFormat {
    var dateForDay:Date
    init(date:Date) {
        self.dateForDay = date
    }
    
    func dayForDate()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let fullyFormattedDate = dateFormatter.string(from: dateForDay)
        return fullyFormattedDate
    }
}

class YearFormat {
    var dateForYear:Date
    init(date:Date) {
        self.dateForYear = date
    }
    
    func yearForDate()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        let fullyFormattedDate = dateFormatter.string(from: dateForYear)
        return fullyFormattedDate
    }
}

class HourFormat {
    var dateForHour:Date
    init(date:Date) {
        self.dateForHour = date
    }
    
    func hourForDate()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let fullyFormattedDate = dateFormatter.string(from: dateForHour)
        return fullyFormattedDate
    }
}

class MinuteFormat {
    var dateForMinute:Date
    init(date:Date) {
        self.dateForMinute = date
    }
    
    func minuteForDate()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        let fullyFormattedDate = dateFormatter.string(from: dateForMinute)
        return fullyFormattedDate
    }
}



class FormatDateForSearch {
    var dateFormat:Date
    init(date:Date) {
        self.dateFormat = date
    }
    func formatDateForTheSearch()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let formattedDate = dateFormatter.string(from:dateFormat)
        return formattedDate
    }
}

class NFIRSIncidentTypeList {
    var displayOrder: Int
    let entryState = EntryState.new
    var incidentTypeGuid: String
    var incidentTypeName: String
    var incidentTypeNumber: String
    let incidentTypeNameModDate = Date()
    
    init(order: Int, type: String, number: String ) {
        self.displayOrder = order
        self.incidentTypeName = type
        self.incidentTypeNumber = number
        let guidDate = GuidFormatter.init(date:Date())
        let guid = guidDate.formatGuid()
        self.incidentTypeGuid = "54."+guid
    }
}

class NFIRSLocationList {
    var displayOrder: Int
    let entryState = EntryState.new
    var locationGuid: String
    var location: String
    let locationDate = Date()
    
    init(order: Int, type: String ) {
        self.displayOrder = order
        self.location = type
        let guidDate = GuidFormatter.init(date:Date())
        let guid = guidDate.formatGuid()
        self.locationGuid = "53."+guid
    }
}

class UserLocalIncidentTypeList {
    var displayOrder: Int
    let entryState = EntryState.new
    let incidentType: String
    let incidentTypeGuid: String
    let incidentTypeDate: Date
    
    init(order: Int, type: String, date: Date) {
        self.displayOrder = order
        self.incidentType = type
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.incidentTypeGuid = "52."+guid
        self.incidentTypeDate = date
    }
}

class NFIRSStreetPrefixList {
    var displayOrder: Int
    let entryState = EntryState.new
    let streetPrefix: String
    let streetPrefixAbbreviation: String
    let streetPrefixGuid: String
    let streetPrefixDate: Date
    
    init(order:Int, type: String, typeAbbreviation: String, date: Date) {
        self.displayOrder = order
        self.streetPrefix = type
        self.streetPrefixAbbreviation = typeAbbreviation
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.streetPrefixGuid = "51."+guid
        self.streetPrefixDate = date
        
    }
}

class NFIRSStreetTypeList {
    var displayOrder: Int
    let entryState = EntryState.new
    let streetType: String
    let streetTypeGuid: String
    let streetTypeDate: Date
    
    init(order: Int, type: String, date: Date) {
        self.displayOrder = order
        self.streetType = type
        self.streetTypeDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.streetTypeGuid = "50."+guid
    }
}

class NFIRSStreetTypeLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var streetTypes = [String]()
    var displayOrders = [Int]()
    var count: Int = 0
    var stop:Bool = false
    let nc = NotificationCenter.default
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        let nc = NotificationCenter.default
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        executing(true)
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSStreetType" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class NFIRSStreetTypeLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                do {
                    try bkgrdContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NFIRS Street Type Properties Operation"])
                    }
                } catch let error as NSError {
                    let nserror = error as NSError
                    let errorMessage = "class NFIRSStreetTypeLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class NFIRSStreetTypeLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                print(errorMessage)
            }
        } else {
            plowThroughThePlist()
        }
        
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        
    }
    
    func plowThroughThePlist() {
        guard let path = Bundle.main.path(forResource: "StreetTypes", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        streetTypes = dict?["streetType"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let street = streetTypes[index]
                let list = NFIRSStreetTypeList.init(order: display, type: street, date: Date())
                
                let streetType = NFIRSStreetType.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSStreetType", in: bkgrdContext)!, insertInto: bkgrdContext)
                streetType.displayOrder = Int64(list.displayOrder)
                streetType.entryState = list.entryState.rawValue
                streetType.streetType = list.streetType
                streetType.nfirsSTModDate = Date()
                streetType.nfirsSTBackedUp = false
                streetType.streetTypeGuid = list.streetTypeGuid
            }
            
            saveToCD()
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NFIRS Street Type Properties Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTNFIRSStreetTypeLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("PlistOperation line 357 Fetch Error: \(error.localizedDescription)")
        }
    }
        
}

class NFIRSStreetPrefixLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var streetPrefixes = [String]()
    var streetPrefixAbbreviations = [String]()
    var displayOrders = [Int]()
    var count: Int = 0
    var stop:Bool = false
    let nc = NotificationCenter.default
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        let nc = NotificationCenter.default
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        executing(true)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSStreetPrefix" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class NFIRSStreetPrefixLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                do {
                    try bkgrdContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NFIRS Street Prefix Properties Operation"])
                    }
                } catch let error as NSError {
                    let nserror = error as NSError
                    let errorMessage = "class NFIRSStreetPrefixLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class NFIRSStreetPrefixLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                print(errorMessage)
            }
        } else {
            plowThroughThePlist()
        }
        
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        
    }
    
    func plowThroughThePlist() {
        guard let path = Bundle.main.path(forResource: "StreetPrefix", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        streetPrefixes = dict?["streetPrefix"] as! Array<String>
        streetPrefixAbbreviations = dict?["streetPrefixAbbreviation"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let prefix = streetPrefixes[index]
                let prefixAbbreviation = streetPrefixAbbreviations[index]
                let display = value
                
                let list = NFIRSStreetPrefixList.init(order:display, type: prefix, typeAbbreviation: prefixAbbreviation, date: Date())
                
                let nfirsPrefix = NFIRSStreetPrefix.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSStreetPrefix", in: bkgrdContext)!, insertInto: bkgrdContext)
                nfirsPrefix.displayOrder = Int64(list.displayOrder)
                nfirsPrefix.entryState = list.entryState.rawValue
                nfirsPrefix.streetPrefixBackup = false
                nfirsPrefix.streetPrefix = list.streetPrefix
                nfirsPrefix.streetPrefixAbbreviation = list.streetPrefixAbbreviation
                nfirsPrefix.streetPrefixGuid = list.streetPrefixGuid
                nfirsPrefix.streetPrefixModDate = list.streetPrefixDate
            }
            
            saveToCD()
            
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NFIRS Street Prefix Properties Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTNFIRSStreetPrefixLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("PlistOperation line 482 Fetch Error: \(error.localizedDescription)")
        }
    }
}

class UserLocalIncidentTypeLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var localIncidentTypes = [String]()
    var displayOrders = [Int]()
    var count:Int = 0
    var stop:Bool = false
    let nc = NotificationCenter.default
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        let nc = NotificationCenter.default
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        executing(true)
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLocalIncidentType" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class UserLocalIncidentTypeLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            checkAgainstThePlist()
        } else {
            plowThroughThePlist()
        }
        
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        
    }
    
    func checkAgainstThePlist() {
        guard let path = Bundle.main.path(forResource: "LocalIncidents", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        localIncidentTypes = dict?["localIncidents"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLocalIncidentType" )
            for (index, value) in displayOrders.enumerated() {
                let localIncident:String = localIncidentTypes[index]
                let display:Int = value
                let list = UserLocalIncidentTypeList.init(order: display, type: localIncident, date: Date())
                let predicate = NSPredicate(format: "%K != %@", "localIncidentTypeName", localIncident)
                fetchRequest.predicate = predicate
                fetchRequest.fetchBatchSize = 1
                var count = 0
                do {
                    count = try context.count(for:fetchRequest)
                    if count == 0 {
                        let userLocalIncident = UserLocalIncidentType.init(entity: NSEntityDescription.entity(forEntityName: "UserLocalIncidentType", in: bkgrdContext)!, insertInto: bkgrdContext)
                        userLocalIncident.entryState = list.entryState.rawValue
                        userLocalIncident.localIncidentTypeBackUp = false
                        userLocalIncident.displayOrder = Int64(list.displayOrder)
                        userLocalIncident.localIncidentTypeModDate = list.incidentTypeDate
                        userLocalIncident.localIncidentTypeName = list.incidentType
                        userLocalIncident.localIncidentGuid = list.incidentTypeGuid
                        saveToCD()
                    }
                } catch let error as NSError {
                    let errorMessage = "class UserLocalIncidentTypeLoader: FJOperation saveToCD context was unable to save due to \(error.localizedDescription) \(error.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
            }
        }
    }
    
    func plowThroughThePlist() {
        guard let path = Bundle.main.path(forResource: "LocalIncidents", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        localIncidentTypes = dict?["localIncidents"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let localIncident:String = localIncidentTypes[index]
                let display:Int = value
                let list = UserLocalIncidentTypeList.init(order: display, type: localIncident, date: Date())
                let userLocalIncident = UserLocalIncidentType.init(entity: NSEntityDescription.entity(forEntityName: "UserLocalIncidentType", in: bkgrdContext)!, insertInto: bkgrdContext)
                userLocalIncident.entryState = list.entryState.rawValue
                userLocalIncident.localIncidentTypeBackUp = false
                userLocalIncident.displayOrder = Int64(list.displayOrder)
                userLocalIncident.localIncidentTypeModDate = list.incidentTypeDate
                userLocalIncident.localIncidentTypeName = list.incidentType
                userLocalIncident.localIncidentGuid = list.incidentTypeGuid
            }
            
            saveToCD()
            
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Plist Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTUserLocalIncidentTypeLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("PlistOperation line 634 Fetch Error: \(error.localizedDescription)")
        }
    }
}

class NFIRSLocationLoader: FJOperation {
    var nfirsLocations = [String]()
    var displayOrder = [Int]()
    var count:Int = 0
    var stop:Bool = false
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let nc = NotificationCenter.default
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        let nc = NotificationCenter.default
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        executing(true)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSLocation" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class NFIRSLocationLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                do{
                    try bkgrdContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NFIRS Location Operation"])
                    }
                } catch let error as NSError {
                    let nserror = error as NSError
                    let errorMessage = "class NFIRSLocationLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class NFIRSLocationLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                print(errorMessage)
            }
        } else {
            plowThroughThePlist()
        }
        
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        
        
    }
    
    func plowThroughThePlist() {
        guard let path = Bundle.main.path(forResource: "Location", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        nfirsLocations = dict?["location"] as! Array<String>
        displayOrder = dict?["displayOrder"] as! Array<Int>
        count = displayOrder.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrder.enumerated() {
                let location:String = nfirsLocations[index]
                let display:Int = value
                let list = NFIRSLocationList.init(order: display, type: location )
                let nfirsLocation = NFIRSLocation.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSLocation", in: bkgrdContext)!, insertInto: bkgrdContext)
                nfirsLocation.displayOrder = Int64(list.displayOrder)
                nfirsLocation.entryState = list.entryState.rawValue
                nfirsLocation.locationBackup = false
                nfirsLocation.locationModDate = list.locationDate
                nfirsLocation.location = list.location
                nfirsLocation.locationGuid = list.locationGuid
            }
            
            saveToCD()
            
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NFIRS Location Properties Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fJkPLISTNFIRSLocationLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("PlistOperation line 752 Fetch Error: \(error.localizedDescription)")
        }
    }
    
}
    


class NFIRSIncidentLoader: FJOperation {
    var nfirsStreetTypesString = [String]()
    var nfirsStreetTypeNumber = [String]()
    var displayOrder = [Int]()
    var count:Int = 0
    var stop:Bool = false
    let nc = NotificationCenter.default
    
    let context:NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        let nc = NotificationCenter.default
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        
        executing(true)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSIncidentType" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class NFIRSIncidentLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                do{
                    try bkgrdContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NFIRS Incident Type Operation"])
                    }
                } catch let error as NSError {
                    let nserror = error as NSError
                    let errorMessage = "class NFIRSIncidentLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
                plowThroughThePList()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class NFIRSIncidentLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                print(errorMessage)
            }
        } else {
            plowThroughThePList()
        }
        
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
    }
    
    func plowThroughThePList() {
        guard let path = Bundle.main.path(forResource: "NFIRSIncidentType", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        nfirsStreetTypesString = dict?["incidentTypeName"] as! Array<String>
        nfirsStreetTypeNumber = dict?["incidentTypeNumber"] as! Array<String>
        displayOrder = dict?["displayOrder"] as! Array<Int>
        count = displayOrder.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrder.enumerated() {
                let type = nfirsStreetTypesString[index]
                let number = nfirsStreetTypeNumber[index]
                let display:Int = value
                let list = NFIRSIncidentTypeList.init(order: display, type: type , number: number)
                let nfirsIncidentType = NFIRSIncidentType.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSIncidentType", in: bkgrdContext)!, insertInto: bkgrdContext)
                nfirsIncidentType.incidentTypeGuid = list.incidentTypeGuid
                nfirsIncidentType.entryState = list.entryState.rawValue
                nfirsIncidentType.displayOrder = Int64(list.displayOrder)
                nfirsIncidentType.incidentTypeNameBackup = false
                nfirsIncidentType.incidentTypeNameModDate = list.incidentTypeNameModDate
                nfirsIncidentType.incidentTypeNumber = list.incidentTypeNumber
                nfirsIncidentType.incidentTypeName = list.incidentTypeName
            }
            
            saveToCD()
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NFIRS Incident Type Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"no big deal here"])
            }
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                    object: nil,
                    userInfo: ["plist":PlistsToLoad.fjkPLISTNFIRSIncidentLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("PlistOperation line 875 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    
}
