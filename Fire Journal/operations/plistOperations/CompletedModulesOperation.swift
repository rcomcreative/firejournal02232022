//
//  CompletedModulesOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/1/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CompletedModulesList {
    var displayOrder:Int
    let entryState = EntryState.new
    var theCompletedModule:String
    var theCompletedModuleGuid:String
    var theCompletedModuleDate:Date
    
    init(order:Int,type:String,date:Date) {
        self.displayOrder = order
        self.theCompletedModule = type
        self.theCompletedModuleDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theCompletedModuleGuid = "59."+guid
    }
}

class CompletedModulesLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var modules = [String]()
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSCompletedModules" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class CompletedModulesOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                do {
                    try bkgrdContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Complete Modules Operation"])
                    }
                } catch let error as NSError {
                    let nserror = error as NSError
                    let errorMessage = "class CompletedModulesOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class CompletedModulesOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        
        guard let path = Bundle.main.path(forResource: "CompletedModules", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        modules = dict?["completedModules"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let module = modules[index]
                let list = CompletedModulesList.init(order: display, type: module, date: Date())
                
                let completeMod = NFIRSCompletedModules.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSCompletedModules", in: bkgrdContext)!, insertInto: bkgrdContext)
                completeMod.displayOrder = Int64(list.displayOrder)
                completeMod.entryState = list.entryState.rawValue
                completeMod.completedModules = list.theCompletedModule
                completeMod.completedModulesModDate = list.theCompletedModuleDate
                completeMod.completedModulesGuid = list.theCompletedModuleGuid
                completeMod.completedModulesBackup = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Completed Modules Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTCompletedModulesLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("ComnpleteModulesOperation line 140 Fetch Error: \(error.localizedDescription)")
        }
    }
}
