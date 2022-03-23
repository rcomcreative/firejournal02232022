//
//  FireDistrictsOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/1/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FireDistrictsList {
    var displayOrder:Int
    let entryState = EntryState.new
    var theFireDistrict:String
    var theFireDistrictGuid:String
    var theFireDistricDate:Date
    
    init(order:Int,type:String,date:Date){
        self.displayOrder = order
        self.theFireDistrict = type
        self.theFireDistricDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theFireDistrictGuid = "62."+guid
    }
}

class FireDistrictsLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var fireDistricts = [String]()
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFireDistrict" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class FireDistrictOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                do {
                    try bkgrdContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Fire Districts Operation"])
                    }
                } catch let error as NSError {
                    let nserror = error as NSError
                    let errorMessage = "class FireDistrictOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class FireDistrictOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        
        guard let path = Bundle.main.path(forResource: "FireDistrict", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        fireDistricts = dict?["FireDistricts"] as! Array<String>
        displayOrders = dict?["DisplayOrder"] as! Array<Int>
        count = displayOrders.count
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let district = fireDistricts[index]
                
                let list = FireDistrictsList.init(order: display, type: district, date: Date())
                
                let fireDistrict = UserFireDistrict.init(entity: NSEntityDescription.entity(forEntityName: "UserFireDistrict", in: bkgrdContext)!, insertInto: bkgrdContext)
                
                fireDistrict.displayOrder = Int64(list.displayOrder)
                fireDistrict.entryState = list.entryState.rawValue
                fireDistrict.fireDistrict = list.theFireDistrict
                fireDistrict.fireDistrictGuid = list.theFireDistrictGuid
                fireDistrict.fireDistrictModDate = list.theFireDistricDate
                fireDistrict.fireDistrictBackUp = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Fire Districts Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTFireDistrictsLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("FireDistrictsOperation line 143 Fetch Error: \(error.localizedDescription)")
        }
    }
}
