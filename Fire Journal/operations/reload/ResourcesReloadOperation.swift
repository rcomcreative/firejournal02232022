//
//  ResourcesReloadOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 10/28/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class ResourcesReloadOperation: FJOperation {
    
    //    MARK: -PROPERTIES-
    var context: NSManagedObjectContext!
    var bkgrdContext:NSManagedObjectContext!
    var userResources: UserResources!
    var resourcesA = [String]()
    var displayA = [Int]()
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let dateFormatter = DateFormatter()
    var fetched:Array<Any>!
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    override func main() {
        print("in ResourcesReloadOperation")
        guard isCancelled == false else {
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        executing(true)
        
        guard let path = Bundle.main.path(forResource: "Resources", ofType:"plist") else {
            DispatchQueue.main.async {
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
            return
        }
        
        let dict = NSDictionary(contentsOfFile:path)
        resourcesA = dict?["resource"] as! Array<String>
        displayA = dict?["displayOrder"] as! Array<Int>
        count = displayA.count
        
        if dict != nil {
            for (index, value) in displayA.enumerated() {
                let display = value
                let resource = resourcesA[index]
                
                let list = UserResourcesList.init(display: display, type: resource, date: Date())
                
                let userResource = UserResources.init(entity: NSEntityDescription.entity(forEntityName: "UserResources", in: bkgrdContext)!, insertInto: bkgrdContext)
                userResource.displayOrder = Int64(list.displayOrder)
                userResource.entryState = list.entryState.rawValue
                userResource.defaultResource = list.defaultResource
                userResource.resource = list.theResource
                userResource.resourceModificationDate = list.theResourceDate
                userResource.resourceGuid = list.theResourceGuid
                userResource.resourceCustom = false
                userResource.resourceBackUp = false
            }
            
            saveToCDAndPost()
        }
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
    }
    
    func saveToCDAndPost() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"ResourcesReloadOperation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                print("ResourcesReloadOperation Finished")
                nc.post(name:Notification.Name(rawValue:FJkReloadUserResourcesFinished),
                        object: nil,
                        userInfo: nil )
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("ResourcesReloadOperation line 128 Fetch Error: \(error.localizedDescription)")
        }
    }
}
