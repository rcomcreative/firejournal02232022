//
//  UserTagsOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/2/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserTagsList {
    var displayOrder:Int
    let entryState = EntryState.new
    var theTag:String
    var theTagGuid:String
    var theTagDate:Date
    init(display:Int,tag:String,date:Date) {
        self.displayOrder = display
        self.theTag = tag
        self.theTagDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theTagGuid = "74."+guid
    }
}

class UserTagsLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var tags = [String]()
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserTags" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class UserTagsLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        
        guard let path = Bundle.main.path(forResource: "Tags", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        tags = dict?["journalTag"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserTags" )
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let aTag = tags[index]
                
                let list = UserTagsList.init(display: display, tag: aTag, date: Date())
                
                let predicate = NSPredicate(format: "%K != %@", "userTag", aTag)
                fetchRequest.predicate = predicate
                fetchRequest.fetchBatchSize = 1
                var count = 0
                do {
                    count = try context.count(for:fetchRequest)
                    if count == 0 {
                        let tag = UserTags.init(entity:NSEntityDescription.entity(forEntityName: "UserTags", in: bkgrdContext)!, insertInto: bkgrdContext)
                        tag.displayOrder = Int64(list.displayOrder)
                        tag.entryState = list.entryState.rawValue
                        tag.userTag = list.theTag
                        tag.userTagModDate = list.theTagDate
                        tag.userTagGuid = list.theTagGuid
                        tag.userTagBackup = false
                        saveToCD()
                    }
                } catch let error as NSError {
                    let errorMessage = "class UserTagsOperation: FJOperation saveToCD context was unable to save due to \(error.localizedDescription) \(error.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
            }
        }
    }
    
    func plowThroughThePlist() {
        
        guard let path = Bundle.main.path(forResource: "Tags", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        tags = dict?["journalTag"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let aTag = tags[index]
                
                let list = UserTagsList.init(display: display, tag: aTag, date: Date())
                
                let tag = UserTags.init(entity:NSEntityDescription.entity(forEntityName: "UserTags", in: bkgrdContext)!, insertInto: bkgrdContext)
                tag.displayOrder = Int64(list.displayOrder)
                tag.entryState = list.entryState.rawValue
                tag.userTag = list.theTag
                tag.userTagModDate = list.theTagDate
                tag.userTagGuid = list.theTagGuid
                tag.userTagBackup = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"User Tags Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTUserTagsLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("UserTagsOperation line 176 Fetch Error: \(error.localizedDescription)")
        }
    }
}
