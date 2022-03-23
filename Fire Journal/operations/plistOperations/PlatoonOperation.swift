//
//  PlatoonOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/2/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PlatoonList {
    var displayOrder:Int
    let entryState = EntryState.new
    var thePlatoon:String
    var thePlatoonDate:Date
    var thePlatoonGuid:String
    init(display:Int,type:String,date:Date) {
        self.displayOrder = display
        self.thePlatoon = type
        self.thePlatoonDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.thePlatoonGuid = "67."+guid        
    }
}

class PlatoonLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var names = [String]()
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserPlatoon" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class PlatoonLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        guard let path = Bundle.main.path(forResource: "Platoon", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        names = dict?["platoon"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserPlatoon" )
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let name = names[index]
                let list = PlatoonList.init(display: display, type: name, date: Date())
                
                let predicate = NSPredicate(format: "%K != %@", "platoon", name)
                fetchRequest.predicate = predicate
                fetchRequest.fetchBatchSize = 1
                var count = 0
                do {
                    count = try context.count(for:fetchRequest)
                    if count == 0 {
                        let platoon = UserPlatoon.init(entity: NSEntityDescription.entity(forEntityName: "UserPlatoon", in: bkgrdContext)!, insertInto: bkgrdContext)
                        platoon.displayOrder = Int64(list.displayOrder)
                        platoon.entryState = list.entryState.rawValue
                        platoon.platoon = list.thePlatoon
                        platoon.platoonGuid = list.thePlatoonGuid
                        platoon.platoonModDate = list.thePlatoonDate
                        platoon.platoonBackUp = false
                        saveToCD()
                    }
                } catch let error as NSError {
                    let errorMessage = "class PlatoonOperation: FJOperation saveToCD context was unable to save due to \(error.localizedDescription) \(error.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
            }
        }
    }
    
    func plowThroughThePlist() {
        
        guard let path = Bundle.main.path(forResource: "Platoon", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        names = dict?["platoon"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let name = names[index]
                
                let list = PlatoonList.init(display: display, type: name, date: Date())
                
                let platoon = UserPlatoon.init(entity: NSEntityDescription.entity(forEntityName: "UserPlatoon", in: bkgrdContext)!, insertInto: bkgrdContext)
                platoon.displayOrder = Int64(list.displayOrder)
                platoon.entryState = list.entryState.rawValue
                platoon.platoon = list.thePlatoon
                platoon.platoonGuid = list.thePlatoonGuid
                platoon.platoonModDate = list.thePlatoonDate
                platoon.platoonBackUp = false
                
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Platoon Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTPlatoonLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("PlatoonOperation line 179 Fetch Error: \(error.localizedDescription)")
            
        }
    }
}
