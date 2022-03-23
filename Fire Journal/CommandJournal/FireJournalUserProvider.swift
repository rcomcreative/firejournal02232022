//
//  FireJournalUserProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/9/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class FireJournalUserProvider: NSObject, NSFetchedResultsControllerDelegate {
    
    
    private(set) var persistentContainer: NSPersistentContainer
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    private var fetchedResultsController: NSFetchedResultsController<FireJournalUser>? = nil
    var _fetchedResultsController: NSFetchedResultsController<FireJournalUser> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    deinit {
        print("IncidentProvider is being deinitialized")
    }
    
    var fetchedObjects: [FireJournalUser] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func getTheUser(_ context: NSManagedObjectContext) -> [FireJournalUser]? {
        let fetchRequest: NSFetchRequest<FireJournalUser> = FireJournalUser.fetchRequest()

        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "userGuid", "")
        

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("FireJournalUserProvider line 59 Fetch Error: \(error.localizedDescription)")
        }

        return fetchedObjects
    }
    
    
}
