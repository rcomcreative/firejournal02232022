//
//  TagsReloadOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 10/27/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class TagsReloadOperation: FJOperation {

    //    MARK: -PROPERTIES-
    var context: NSManagedObjectContext!
    var bkgrdContext:NSManagedObjectContext!
    var userTags: UserTags!
    var userTagsA = [UserTags]()
    var tagsA = [String]()
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
    var builtFromTagsPlist: BuiltFromTagsPlist!
    
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
        
        guard let path = Bundle.main.path(forResource: "Tags", ofType:"plist") else {
            DispatchQueue.main.async {
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
            return
        }
        
        let dict = NSDictionary(contentsOfFile:path)
        tagsA = dict?["journalTag"] as! Array<String>
        displayA = dict?["displayOrder"] as! Array<Int>
        count = displayA.count
        
        if dict != nil {
            for (index, value) in displayA.enumerated() {
                let display = value
                let aTag = tagsA[index]
                
                let list = UserTagsList.init(display: display, tag: aTag, date: Date())
                
                let theTag = Tag(context: bkgrdContext)
                theTag.name = list.theTag
                theTag.guid = UUID()
                
//                let tag = UserTags.init(entity:NSEntityDescription.entity(forEntityName: "UserTags", in: bkgrdContext)!, insertInto: bkgrdContext)
//                tag.displayOrder = Int64(list.displayOrder)
//                tag.entryState = list.entryState.rawValue
//                tag.userTag = list.theTag
//                tag.userTagModDate = list.theTagDate
//                tag.userTagGuid = list.theTagGuid
//                tag.userTagBackup = false
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"TagsReloadOperation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                print("TagsReloadOperation Finished")
                nc.post(name:Notification.Name(rawValue:FJkReloadUserTagsFinished),
                        object: nil,
                        userInfo: nil )
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("TagsReloadOperation line 128 Fetch Error: \(error.localizedDescription)")
        }
    }
}
