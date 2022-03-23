//
//  NFIRSIncidentTypeProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/16/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class NFIRSIncidentTypeProvider: NSObject, NSFetchedResultsControllerDelegate {
    
    private var fetchedResultsController: NSFetchedResultsController<NFIRSIncidentType>? = nil
    var _fetchedResultsController: NSFetchedResultsController<NFIRSIncidentType> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    deinit {
        print("IncidentProvider is being deinitialized")
    }
    
    var fetchedObjects: [NFIRSIncidentType] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    private(set) var persistentContainer: NSPersistentContainer
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getAllNFIRSIncidentType(_ context: NSManagedObjectContext) -> [NFIRSIncidentType]? {
        var theNFIRSIncidentTypes = [NFIRSIncidentType]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSIncidentType" )
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentTypeName", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [NFIRSIncidentType]
            if !fetched.isEmpty {
                for incidentType in fetched {
                    theNFIRSIncidentTypes.append(incidentType)
                }
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return theNFIRSIncidentTypes
    }
    
}
