//
//  NFIRSActionTakenProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/12/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class NFIRSActionTakenProvider: NSObject {
    
    let nc = NotificationCenter.default
    
    private(set) var persistentContainer: NSPersistentContainer
    var buildFromActionsTaken: BuildFromActionsTaken!
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getAllActionsTaken(context: NSManagedObjectContext) -> [NFIRSActionsTaken]? {
        var actionsTaken = [NFIRSActionsTaken]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSActionsTaken" )
        let sectionSortDescriptor = NSSortDescriptor(key: "actionTaken", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [NFIRSActionsTaken]
            if !fetched.isEmpty {
                for action in fetched {
                    actionsTaken.append(action)
                }
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        return actionsTaken
    }
    
    func buildNFIRSActionTaken(theGuidDate: Date, backgroundContext: NSManagedObjectContext ) -> [NFIRSActionsTaken] {
        var actionsTaken = [NFIRSActionsTaken]()
        buildFromActionsTaken = BuildFromActionsTaken.init()
        let actionsTakenA = buildFromActionsTaken.actionsTaken
        for action in actionsTakenA {
            let guidDate = GuidFormatter.init(date: theGuidDate)
            let guid = guidDate.formatGuid()
            let theGuid = "55."+guid
            if let anAction = action.actionTaken {
                let nfirsAction = NFIRSActionsTaken(context: backgroundContext)
                nfirsAction.actionTakenGuid = theGuid
                nfirsAction.actionTaken = anAction.actionTaken
                actionsTaken.append(nfirsAction)
            }
        }
        do {
            try backgroundContext.save()
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "ActionsTaken saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        backgroundContext.reset()
        return actionsTaken
    }
    
}
