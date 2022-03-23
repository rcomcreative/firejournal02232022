//
//  TheResource.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/30/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class TheResource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var entryState = EntryState.new
    var resource: String
    var resourceGuid: String = ""
    var resourceDate: Date = Date()
    var displayOrder: Int64 = 0
    let nc = NotificationCenter.default
    var thread:Thread!
    
    init(resource: String) {
        self.resource = resource
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        self.nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
    }
    
    func createGuid() {
        self.resourceDate = Date()
        let groupDate = GuidFormatter.init(date:resourceDate)
        let grGuid:String = groupDate.formatGuid()
        self.resourceGuid = "72."+grGuid
    }
    
    func getDisplayOrder() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources" )
        let predicate = NSPredicate(format: "%K != %@", "resource", resource)
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        let sectionSortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let fetchedForm = try context.fetch(fetchRequest) as! [UserResources]
            let resource = fetchedForm.last
            displayOrder = resource?.displayOrder ?? 0
        } catch let error as NSError  {
            print("there is an \(error)")
        }
    }
    
    func addNewResource() -> String {
        var userResource: UserResources!
        let userResourced: String = resource
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources" )
        let predicate = NSPredicate(format: "%K == %@", "resource", resource)
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        var count = 0
        do {
            count = try context.count(for:fetchRequest)
            if count == 0 {
                userResource = UserResources.init(entity: NSEntityDescription.entity(forEntityName: "UserResources", in: context)!, insertInto: context)
                userResource.displayOrder = Int64(displayOrder + 1)
                userResource.entryState = entryState.rawValue
                userResource.resourceCustom = true
                userResource.defaultResource = false
                userResource.resource = resource
                userResource.fdResource = true
                userResource.resourceModificationDate = resourceDate
                userResource.resourceGuid = resourceGuid
                userResource.resourceBackUp = false
                saveToCData()
            }
        } catch let error as NSError {
            let errorMessage = "class UserResourcesOperation: FJOperation saveToCD context was unable to save due to \(error.localizedDescription) \(error.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        return userResourced
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc func checkTheThread() {
           let testThread:Bool = thread.isMainThread
           print("here is testThread \(testThread) and \(Thread.current)")
       }
    
    func saveToCData() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"TheResource merge that"])
            }
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "TheResource saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    
}
