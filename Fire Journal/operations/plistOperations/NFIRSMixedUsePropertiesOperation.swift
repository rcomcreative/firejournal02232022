//
//  NFIRSMixedUsePropertiesOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/2/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NFIRSMixedUsePropertiesList {
    var displayOrder:Int
    let entryState = EntryState.new
    var theNFIRSMixedUseProperties:String
    var theNFIRSMixedUsePropertiesDate:Date
    var theNFIRSMixedUsePropertiesGuid:String
    init(order:Int,type:String,date:Date){
        self.displayOrder = order
        self.theNFIRSMixedUseProperties = type
        self.theNFIRSMixedUsePropertiesDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theNFIRSMixedUsePropertiesGuid = "64."+guid
    }
}

class NFIRSMixedUsePropertiesLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var properties = [String]()
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSMixedUseProperties" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class NFIRSMixedUsePropertiesOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                do {
                    try bkgrdContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NFIRS Mixed User Properties Operation"])
                    }
                } catch let error as NSError {
                    let nserror = error as NSError
                    let errorMessage = "class NFIRSMixedUsePropertiesOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class NFIRSMixedUsePropertiesOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        
        guard let path = Bundle.main.path(forResource: "MixedUseProperty", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        properties = dict?["mixedUseProperty"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let property = properties[index]
                
                let list = NFIRSMixedUsePropertiesList.init(order: display, type: property, date: Date())
                
                let mixedUse = NFIRSMixedUseProperties.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSMixedUseProperties", in: bkgrdContext)!, insertInto: bkgrdContext)
                mixedUse.displayOrder = Int64(list.displayOrder)
                mixedUse.entryState = list.entryState.rawValue
                mixedUse.mixedUseProperty = list.theNFIRSMixedUseProperties
                mixedUse.mixedUsePropertyModDate = list.theNFIRSMixedUsePropertiesDate
                mixedUse.mixedUsePropertyGuid = list.theNFIRSMixedUsePropertiesGuid
                mixedUse.mixedUsePropertyBackup = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NFIRS Mixed User Properties Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTNFIRSMixedUsePropertiesLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("NFIRSMixedUseOperation line 140 Fetch Error: \(error.localizedDescription)")
        }
    }
}
