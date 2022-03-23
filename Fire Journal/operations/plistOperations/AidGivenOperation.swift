//
//  AidGivenOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/1/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AidGivenList {
    let displayOrder: Int
    let entryState = EntryState.new
    let theAidGivenGuid:String
    let theAidGiven:String
    let theAidGiveDate: Date
    
    init(order: Int, type: String, date:Date) {
        self.displayOrder = order
        self.theAidGiven = type
        self.theAidGiveDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theAidGivenGuid = "56."+guid
    }
}

class AidGivenLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var aidsGiven = [String]()
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
        
        //        MARK: -LOAD THE PLIST
        
        
        executing(true)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSAidGiven" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class AidGivenOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class AidGivenOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        executing(true)
        guard let path = Bundle.main.path(forResource: "AidGiven", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        aidsGiven = dict?["AidGiven"] as! Array<String>
        displayOrders = dict?["DisplayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let aid = aidsGiven[index]
                
                let list = AidGivenList.init(order: display, type: aid, date: Date())
                
                let aidGiven = NFIRSAidGiven.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSAidGiven", in: bkgrdContext)!, insertInto: bkgrdContext)
                aidGiven.displayOrder = Int64(list.displayOrder)
                aidGiven.entryState = list.entryState.rawValue
                aidGiven.aidGiven = list.theAidGiven
                aidGiven.aidGivenGuid = list.theAidGivenGuid
                aidGiven.aidGivenModDate = list.theAidGiveDate
                aidGiven.aidGivenBackup = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Aid Given Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTAidGivenLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("AidGiven Operation line 146 Fetch Error: \(error.localizedDescription)")
        }
    }
}
