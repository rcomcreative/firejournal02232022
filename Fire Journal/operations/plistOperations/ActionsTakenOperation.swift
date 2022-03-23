//
//  ActionsTakenOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/1/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ActionsTakenList {
    var displayOrder: Int
    let entryState = EntryState.new
    var theActionTakenGuid: String
    var theActionTaken: String
    var theActionTakenModDate: Date
    
    init(order: Int, type: String, date: Date) {
        self.displayOrder = order
        self.theActionTaken = type
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theActionTakenGuid = "55."+guid
        self.theActionTakenModDate = date
    }
    
}

class ActionTakenLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var actionsTaken = [String]()
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSActionsTaken" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class ActionsTakenOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class ActionsTakenOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        guard let path = Bundle.main.path(forResource: "ActionsTaken", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        actionsTaken = dict?["ActionsTaken"] as! Array<String>
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
                let action = actionsTaken[index]
                let list = ActionsTakenList.init(order: display, type: action, date: Date())
                
                let actionTaken = NFIRSActionsTaken.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSActionsTaken", in: bkgrdContext)!, insertInto: bkgrdContext)
                actionTaken.displayOrder = Int64(list.displayOrder)
                actionTaken.actionTakenGuid = list.theActionTakenGuid
                actionTaken.actionTaken = list.theActionTaken
                actionTaken.actionTakenModDate = list.theActionTakenModDate
                actionTaken.actionTakenBackup = false
                actionTaken.entryState = list.entryState.rawValue
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Actions Taken Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTActionTakenLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("ActionsTakenOperation line 146 Fetch Error: \(error.localizedDescription)")
        }
    }
}
