//
//  RequiredModulesOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/2/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RequiredModulesList {
    var displayOrder:Int
    let entryState = EntryState.new
    var theRequiredModule:String
    var theRequiredModuleGuid:String
    var theRequiredModuleDate:Date
    init(display:Int,type:String,date:Date) {
        self.displayOrder = display
        self.theRequiredModule = type
        self.theRequiredModuleDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theRequiredModuleGuid = "71."+guid
    }
}

class RequiredModulesLoader: FJOperation {
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSRequiredModules" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class RequiredModulesOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                do {
                    try bkgrdContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Required Modules Operation"])
                    }
                } catch let error as NSError {
                    let nserror = error as NSError
                    let errorMessage = "class RequiredModulesOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class RequiredModulesOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        
        guard let path = Bundle.main.path(forResource: "RequiredModules", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        modules = dict?["requiredModules"] as! Array<String>
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
                
                let list = RequiredModulesList.init(display: display, type: module, date: Date())
                
                let requiredModule = NFIRSRequiredModules.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSRequiredModules", in: bkgrdContext)!, insertInto: bkgrdContext)
                requiredModule.displayOrder = Int64(list.displayOrder)
                requiredModule.entryState = list.entryState.rawValue
                requiredModule.requiredModules = list.theRequiredModule
                requiredModule.requiredModulesModDate = list.theRequiredModuleDate
                requiredModule.requiredModulesGuid = list.theRequiredModuleGuid
                requiredModule.requiredModulesBackup = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Required Modules Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTRequiredModulesLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("RequiredModulesOperation line 139 Fetch Error: \(error.localizedDescription)")
        }
    }
}
