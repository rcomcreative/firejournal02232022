//
//  IncidentTotal.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/1/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class IncidentTotal: NSObject, NSFetchedResultsControllerDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var theDate: Date
    
    private var fetchedResultsController: NSFetchedResultsController<Incident>? = nil
    var _fetchedResultsController: NSFetchedResultsController<Incident> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    var fetchedObjects: [Incident] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    init(theDate: Date) {
        self.theDate = theDate
        super.init()
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: nil)
    }
    
    deinit {
        print("IncidentTotal is being deinitialized")
    }
    
    func getIncidentCount() -> Int {
        let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("IncidentTotal line 51 Fetch Error: \(error.localizedDescription)")
        }
        var count: Int = 0
        count = fetchedObjects.count
        return count
    }
}
