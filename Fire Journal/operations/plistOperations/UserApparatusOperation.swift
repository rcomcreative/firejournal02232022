//
//  UserApparatusOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/2/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserApparatusList {
    var displayOrder:Int
    let entryState = EntryState.new
    let defaultApparatus:Bool = false
    var theApparatus:String
    var theApparatusDate:Date
    var theApparatusGuid:String
    init(display:Int,type:String,date:Date) {
        self.displayOrder = display
        self.theApparatus = type
        self.theApparatusDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theApparatusGuid = "77."+guid
    }
}

class UserApparatusLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var apparatuses = [String]()
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserApparatusType" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class UserApparatusLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        
        guard let path = Bundle.main.path(forResource: "UserApparatusType", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        apparatuses = dict?["apparatus"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserApparatusType" )
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let apparatus = apparatuses[index]
                
                let list = UserApparatusList.init(display: display, type: apparatus, date: Date())
                
                let predicate = NSPredicate(format: "%K != %@", "apparatus", apparatus)
                fetchRequest.predicate = predicate
                fetchRequest.fetchBatchSize = 1
                var count = 0
                do {
                    count = try context.count(for:fetchRequest)
                    if count == 0 {
                        let theApparatus = UserApparatusType.init(entity:NSEntityDescription.entity(forEntityName: "UserApparatusType", in: bkgrdContext)!, insertInto: bkgrdContext)
                        theApparatus.displayOrder = Int64(list.displayOrder)
                        theApparatus.entryState = list.entryState.rawValue
                        theApparatus.defaultApparatus = list.defaultApparatus
                        theApparatus.apparatus = list.theApparatus
                        theApparatus.apparatusGuid = list.theApparatusGuid
                        theApparatus.apparatusModDate = list.theApparatusDate
                        theApparatus.apparatusBackUp = false
                        saveToCD()
                    }
                } catch let error as NSError {
                    let errorMessage = "class UserApparatusOperation: FJOperation saveToCD context was unable to save due to \(error.localizedDescription) \(error.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
            }
        }
    }
    
    func plowThroughThePlist() {
        
        guard let path = Bundle.main.path(forResource: "UserApparatusType", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        apparatuses = dict?["apparatus"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let apparatus = apparatuses[index]
                
                let list = UserApparatusList.init(display: display, type: apparatus, date: Date())
                
                let theApparatus = UserApparatusType.init(entity:NSEntityDescription.entity(forEntityName: "UserApparatusType", in: bkgrdContext)!, insertInto: bkgrdContext)
                theApparatus.displayOrder = Int64(list.displayOrder)
                theApparatus.entryState = list.entryState.rawValue
                theApparatus.defaultApparatus = list.defaultApparatus
                theApparatus.apparatus = list.theApparatus
                theApparatus.apparatusGuid = list.theApparatusGuid
                theApparatus.apparatusModDate = list.theApparatusDate
                theApparatus.apparatusBackUp = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"User Apparatus Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTUserApparatusLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("UserApparatusOperation line 178 Fetch Error: \(error.localizedDescription)")
        }
    }
}
