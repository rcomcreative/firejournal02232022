//
//  UserAssignmentsOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/2/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserAssignmentsList {
    var displayOrder:Int
    let entryState = EntryState.new
    let defaultAssignment:Bool = false
    var theAssignment:String
    var theAssignmentDate:Date
    var theAssignmentGuid:String
    init(display:Int,type:String,date:Date) {
        self.displayOrder = display
        self.theAssignment = type
        self.theAssignmentDate = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theAssignmentGuid = "76."+guid
    }
}

class UserAssignementLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var assignments = [String]()
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAssignments" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class UserAssignmentsLoader: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
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
        
        guard let path = Bundle.main.path(forResource: "UserAssignments", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        assignments = dict?["assignment"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAssignments" )
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let assignment = assignments[index]
                
                let list = UserAssignmentsList.init(display: display, type: assignment, date: Date())
                
                let predicate = NSPredicate(format: "%K != %@", "assignment", assignment)
                fetchRequest.predicate = predicate
                fetchRequest.fetchBatchSize = 1
                var count = 0
                do {
                    count = try context.count(for:fetchRequest)
                    if count == 0 {
                        let userAssignment = UserAssignments.init(entity:NSEntityDescription.entity(forEntityName: "UserAssignments", in: bkgrdContext)!, insertInto: bkgrdContext)
                        userAssignment.displayOrder = Int64(list.displayOrder)
                        userAssignment.entryState = list.entryState.rawValue
                        userAssignment.assignment = list.theAssignment
                        userAssignment.assignmentGuid = list.theAssignmentGuid
                        userAssignment.assignmentModerationDate = list.theAssignmentDate
                        userAssignment.defaultAssignment = list.defaultAssignment
                        userAssignment.assignmentBackUp = false
                        saveToCD()
                    }
                } catch let error as NSError {
                    let errorMessage = "class UserAssignmentsOperation: FJOperation saveToCD context was unable to save due to \(error.localizedDescription) \(error.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
            }
        }
    }
    
    func plowThroughThePlist() {
        
        guard let path = Bundle.main.path(forResource: "UserAssignments", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        assignments = dict?["assignment"] as! Array<String>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let assignment = assignments[index]
                
                let list = UserAssignmentsList.init(display: display, type: assignment, date: Date())
                
                let userAssignment = UserAssignments.init(entity:NSEntityDescription.entity(forEntityName: "UserAssignments", in: bkgrdContext)!, insertInto: bkgrdContext)
                userAssignment.displayOrder = Int64(list.displayOrder)
                userAssignment.entryState = list.entryState.rawValue
                userAssignment.assignment = list.theAssignment
                userAssignment.assignmentGuid = list.theAssignmentGuid
                userAssignment.assignmentModerationDate = list.theAssignmentDate
                userAssignment.defaultAssignment = list.defaultAssignment
                userAssignment.assignmentBackUp = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"User Assignment Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTUserAssignementLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("UserAssignmentsOperation line 179 Fetch Error: \(error.localizedDescription)")
        }
    }
}
