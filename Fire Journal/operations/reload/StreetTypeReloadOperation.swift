//
//  StreetTypeReloadOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 10/28/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class StreetTypeReloadOperation: FJOperation {
    
    //    MARK: -PROPERTIES-
    var context: NSManagedObjectContext!
    var bkgrdContext:NSManagedObjectContext!
    var streetTypeA = [String]()
    var displayA = [Int]()
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    var objectID: NSManagedObjectID!
    var tObjectID: NSManagedObjectID!
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
        
        guard let path = Bundle.main.path(forResource: "StreetTypes", ofType:"plist") else {
            DispatchQueue.main.async {
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
            return
        }
        
        let dict = NSDictionary(contentsOfFile:path)
        streetTypeA = dict?["streetType"] as! Array<String>
        displayA = dict?["displayOrder"] as! Array<Int>
        count = displayA.count
        
        if dict != nil {
            for (index, value) in displayA.enumerated() {
                let display = value
                let street = streetTypeA[index]
                
                let list = NFIRSStreetTypeList.init(order: display, type: street, date: Date())
                
                let streetType = NFIRSStreetType.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSStreetType", in: bkgrdContext)!, insertInto: bkgrdContext)
                streetType.displayOrder = Int64(list.displayOrder)
                streetType.entryState = list.entryState.rawValue
                streetType.streetType = list.streetType
                streetType.nfirsSTModDate = Date()
                streetType.nfirsSTBackedUp = false
                streetType.streetTypeGuid = list.streetTypeGuid
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"StreetTypeReloadOperation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                print("StreetTypeReloadOperation Finished")
                nc.post(name:Notification.Name(rawValue:FJkReloadStreetTypeFinished),
                        object: nil,
                        userInfo: nil )
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("StreetTypeReloadOperation line 128 Fetch Error: \(error.localizedDescription)")
        }
    }
}
