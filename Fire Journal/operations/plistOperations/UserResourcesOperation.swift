//
//  UserResourcesOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/2/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserResourcesList {
    var displayOrder:Int
    let entryState = EntryState.new
    let defaultResource:Bool = false
    let theResource:String
    let theResourceDate:Date
    let theResourceGuid:String
    init(display:Int,type:String,date:Date) {
        self.displayOrder = display
        self.theResource = type
        self.theResourceDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theResourceGuid = "72."+guid
    }
}

class UserResourcesLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var resources = [String]()
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
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        executing(true)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class UserResourcesLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        
        guard let path = Bundle.main.path(forResource: "Resources", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        resources = dict?["resource"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources" )
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let resource = resources[index]
                
                let list = UserResourcesList.init(display: display, type: resource, date: Date())
                
                let predicate = NSPredicate(format: "%K != %@", "resource", resource)
                fetchRequest.predicate = predicate
                fetchRequest.fetchBatchSize = 1
                var count = 0
                do {
                    count = try context.count(for:fetchRequest)
                    if count == 0 {
                        let userResource = UserResources.init(entity: NSEntityDescription.entity(forEntityName: "UserResources", in: bkgrdContext)!, insertInto: bkgrdContext)
                        userResource.displayOrder = Int64(list.displayOrder)
                        userResource.entryState = list.entryState.rawValue
                        userResource.defaultResource = list.defaultResource
                        userResource.resource = list.theResource
                        userResource.resourceModificationDate = list.theResourceDate
                        userResource.resourceGuid = list.theResourceGuid
                        userResource.resourceCustom = false
                        userResource.resourceBackUp = false
                        saveToCD()
                    }
                } catch let error as NSError {
                    let errorMessage = "class UserResourcesOperation: FJOperation saveToCD context was unable to save due to \(error.localizedDescription) \(error.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
            }
        }
    }
    
    func plowThroughThePlist() {
        
        guard let path = Bundle.main.path(forResource: "Resources", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        resources = dict?["resource"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let resource = resources[index]
                
                let list = UserResourcesList.init(display: display, type: resource, date: Date())
                
                let userResource = UserResources.init(entity: NSEntityDescription.entity(forEntityName: "UserResources", in: bkgrdContext)!, insertInto: bkgrdContext)
                userResource.displayOrder = Int64(list.displayOrder)
                userResource.entryState = list.entryState.rawValue
                userResource.defaultResource = list.defaultResource
                userResource.resource = list.theResource
                userResource.resourceModificationDate = list.theResourceDate
                userResource.resourceGuid = list.theResourceGuid
                userResource.resourceBackUp = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"User Resources Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTUserResourcesLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("UserResourcesOperation line 176 Fetch Error: \(error.localizedDescription)")
        }
    }
}

