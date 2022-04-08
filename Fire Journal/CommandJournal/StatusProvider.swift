//
//  StatusProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/29/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class StatusProvider: NSObject, NSFetchedResultsControllerDelegate {
    
    
    private var fetchedResultsController: NSFetchedResultsController<Status>? = nil
    var _fetchedResultsController: NSFetchedResultsController<Status> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    deinit {
        print("IncidentProvider is being deinitialized")
    }
    
    var fetchedObjects: [Status] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    private(set) var persistentContainer: NSPersistentContainer
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getTheStatus(context: NSManagedObjectContext) -> [Status]? {
        
        let fetchRequest: NSFetchRequest<Status> = Status.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "guidString", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("UserTimeProvider line 61 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
    
}
