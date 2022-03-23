//
//  UserFDIDOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/15/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserFDIDList {
    let entryState = EntryState.new
    var theFdidGuid: String
    var theFdidNumber: String
    var theFireDepartmentName: String
    var theHQCity: String
    var theHQState: String
    var theModDateDate:Date
    init(number:String,name:String,city:String,state:String,theDate:Date)
    {
        self.theFdidNumber = number
        self.theFireDepartmentName = name
        self.theHQCity = city
        self.theHQState = state
        self.theModDateDate = theDate
        
        let guidDate = GuidFormatter.init(date:theDate)
        let guid = guidDate.formatGuid()
        
        self.theFdidGuid = "76"+guid
    }
    
}

class UserFDIDLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var userFDIDs = [String]()
    var departmentName = [String]()
    var hqCities = [String]()
    var hqStates = [String]()
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
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        executing(true)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDID" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class UserFDIDOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                do {
                    try bkgrdContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"User FDID Operation"])
                    }
                } catch let error as NSError {
                    let nserror = error as NSError
                    let errorMessage = "class UserFDIDOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class UserFDIDOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        
        guard let path = Bundle.main.path(forResource: "FDID", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        userFDIDs = dict?["FDID"] as! Array<String>
        departmentName = dict?["FireDepartmentName"] as! Array<String>
        hqCities = dict?["HQCity"] as! Array<String>
        hqStates = dict?["HQState"] as! Array<String>
        count = userFDIDs.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        if dict != nil {
            for (index, value) in userFDIDs.enumerated() {
                let theFdid = value
                let theDepartment = departmentName[index]
                let theCity = hqCities[index]
                let theState = hqStates[index]
                
                let list = UserFDIDList.init(number: theFdid, name: theDepartment, city: theCity, state: theState, theDate: Date())
                
                let userFDID = UserFDID.init(entity:NSEntityDescription.entity(forEntityName: "UserFDID", in: bkgrdContext)!, insertInto: bkgrdContext)
                userFDID.entryState = list.entryState.rawValue
                userFDID.fdidNumber = list.theFdidNumber
                userFDID.fireDepartmentName = list.theFireDepartmentName
                userFDID.hqCity = list.theHQCity
                userFDID.hqState = list.theHQState
                userFDID.fdidGuid = list.theFdidGuid
                userFDID.fdidBackup = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"User FDID Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTUserFDIDLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("UserFDIDOperation line 153 Fetch Error: \(error.localizedDescription)")
        }
    }
}
