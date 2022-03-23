//
//  UserStatesOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/2/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserStateList {
    var displayOrder:Int
    let entryState = EntryState.new
    var theState:String
    var theStateAbbreviation:String
    var theStateDate:Date
    var theStateGuid:String
    init(display:Int,type:String,abbreviation:String,date:Date) {
        self.displayOrder = display
        self.theState = type
        self.theStateAbbreviation = abbreviation
        self.theStateDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theStateGuid = "73."+guid
    }
}

class UserStateLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var states = [String]()
    var abbreviations = [String]()
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserTheStates" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class UserStateOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                do {
                    try bkgrdContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"User States Operation"])
                    }
                } catch let error as NSError {
                    let nserror = error as NSError
                    let errorMessage = "class UserStateOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class UserStateOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        
        guard let path = Bundle.main.path(forResource: "States", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        states = dict?["stateName"] as! Array<String>
        abbreviations = dict?["stateAbbreviation"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let aState = states[index]
                let anAbbreviation = abbreviations[index]
                
                let list = UserStateList.init(display: display, type: aState, abbreviation: anAbbreviation, date: Date())
                
                let theState = UserTheStates.init(entity: NSEntityDescription.entity(forEntityName: "UserTheStates", in: bkgrdContext)!, insertInto: bkgrdContext)
                theState.displayOrder = Int64(list.displayOrder)
                theState.entryState = list.entryState.rawValue
                theState.stateName = list.theState
                theState.stateAbbreviation = list.theStateAbbreviation
                theState.stateModDate = list.theStateDate
                theState.stateGuid = list.theStateGuid
                theState.stateBackUp = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"User States Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTUserStateLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("UserStatesOperation line 145 Fetch Error: \(error.localizedDescription)")
        }
    }
}


