//
//  TagProvider.swift
//  TagProvider
//
//  Created by DuRand Jones on 8/2/21.
//

import UIKit
import CoreData
import CloudKit

class TagProvider: NSObject {
    
    let nc = NotificationCenter.default
    
    private(set) var persistentContainer: NSPersistentContainer
    var builtFromTagsPlist: BuiltFromTagsPlist!
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getAllTags(context: NSManagedObjectContext) -> [Tag] {
        var theTags = [Tag]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag" )
        let sectionSortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [Tag]
            if !fetched.isEmpty {
                for tag in fetched {
                    theTags.append(tag)
                }
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        return theTags
    }
    
    func buildTheTags(bkgrndContext: NSManagedObjectContext) -> [Tag] {
        var theTags = [Tag]()
        builtFromTagsPlist = BuiltFromTagsPlist.init()
        let tags = builtFromTagsPlist.tags
        for tag in tags {
            let theTag = Tag(context: bkgrndContext)
            theTag.name = tag.tag.tag
            theTag.guid = UUID()
            theTags.append(theTag)
        }
        do {
            try bkgrndContext.save()
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "IncidentEdit saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        bkgrndContext.reset()
        return theTags
    }
    
}
