//
//  RankOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/2/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RankList {
    var displayOrder:Int
    let entryState = EntryState.new
    var theRank:String
    var theRankGuid:String
    var theRankDate:Date
    init(display:Int,type:String,date:Date) {
        self.displayOrder = display
        self.theRank = type
        self.theRankDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theRankGuid = "70."+guid
    }
}

class RankLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var ranks = [String]()
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserRank" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class RankLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        guard let path = Bundle.main.path(forResource: "Rank", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        ranks = dict?["rank"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserRank" )
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let rank = ranks[index]
                
                let list = RankList.init(display: display, type: rank, date: Date())
                
                let predicate = NSPredicate(format: "%K != %@", "rank", rank)
                fetchRequest.predicate = predicate
                fetchRequest.fetchBatchSize = 1
                var count = 0
                do {
                    count = try context.count(for:fetchRequest)
                    if count == 0 {
                        let userRank = UserRank.init(entity: NSEntityDescription.entity(forEntityName: "UserRank", in: bkgrdContext)!, insertInto: bkgrdContext)
                        userRank.displayOrder = Int64(list.displayOrder)
                        userRank.entryState = list.entryState.rawValue
                        userRank.rank = list.theRank
                        userRank.rankGuid = list.theRankGuid
                        userRank.rankModDate = list.theRankDate
                        userRank.rankBackUp = false
                        saveToCD()
                    }
                } catch let error as NSError {
                    let errorMessage = "class RankOperation: FJOperation saveToCD context was unable to save due to \(error.localizedDescription) \(error.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
            }
        }
    }
    
    func plowThroughThePlist() {
        
        guard let path = Bundle.main.path(forResource: "Rank", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        ranks = dict?["rank"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let rank = ranks[index]
                
                let list = RankList.init(display: display, type: rank, date: Date())
                
                let userRank = UserRank.init(entity: NSEntityDescription.entity(forEntityName: "UserRank", in: bkgrdContext)!, insertInto: bkgrdContext)
                userRank.displayOrder = Int64(list.displayOrder)
                userRank.entryState = list.entryState.rawValue
                userRank.rank = list.theRank
                userRank.rankGuid = list.theRankGuid
                userRank.rankModDate = list.theRankDate
                userRank.rankBackUp = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Rank Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTRankLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("RankOperation line 174 Fetch Error: \(error.localizedDescription)")
        }
    }
}
