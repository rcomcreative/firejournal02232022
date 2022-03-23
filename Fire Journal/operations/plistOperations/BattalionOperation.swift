//
//  BattalionOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/1/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//


import Foundation
import UIKit
import CoreData

class BattalionList {
    let displayOrder: Int
    let entryState = EntryState.new
    let theBattalionGuid:String
    let theBattalion:String
    let theBattalionDate: Date
    
    init(order: Int, type: String, date:Date) {
        self.displayOrder = order
        self.theBattalion = type
        self.theBattalionDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theBattalionGuid = "57."+guid
    }
}

class BattalionLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var battalions = [String]()
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserBattalion" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class BattalionOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class BattalionOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        guard let path = Bundle.main.path(forResource: "Battalions", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        battalions = dict?["Battalions"] as! Array<String>
        displayOrders = dict?["DisplayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        executing(true)
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let battalion = battalions[index]
                let list = BattalionList.init(order: display, type: battalion, date: Date())
                
                let bat = UserBattalion.init(entity: NSEntityDescription.entity(forEntityName: "UserBattalion", in: bkgrdContext)!, insertInto: bkgrdContext)
                bat.displayOrder = Int64(list.displayOrder)
                bat.entryState = list.entryState.rawValue
                bat.battalion = list.theBattalion
                bat.battalionBackUp = false
                bat.battalionGuid = list.theBattalionGuid
                bat.battalionModDate = list.theBattalionDate
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Battion Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTBattalionLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("BattalionOperation line 143 Fetch Error: \(error.localizedDescription)")
        }
    }
}
