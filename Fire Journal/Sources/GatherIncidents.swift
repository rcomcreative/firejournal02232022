//
//  GatherIncidents.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/10/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class GetTheIncidents: NSObject, NSFetchedResultsControllerDelegate {
    
    var year: Int
    let calendar = Calendar.current
    var months: YearOfMonths!
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var thread:Thread!
    
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
    
    init(theYear: Int, context: NSManagedObjectContext ) {
        self.year = theYear
        self.context = context
        super.init()
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        months = YearOfMonths.init(theYear: 2020, lastYear: 2019)
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    func getTheIncidents() -> YearOfMonths {
        let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","incidentDateSearch","")
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: bkgrdContext, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("GatherTheIncidents line 68 Fetch Error: \(error.localizedDescription)")
        }

        months.totalIncidents = fetchedObjects
        months.totalFireIncidents = fetchedObjects.filter { $0.situationIncidentImage == "Fire" }
        months.totalEMSIncidents  = fetchedObjects.filter { $0.situationIncidentImage == "EMS" }
        months.totalRescueIncidents = fetchedObjects.filter { $0.situationIncidentImage == "Rescue" }
        var yearS = [Int]()
        for incident: Incident in fetchedObjects {
            let componentYear = calendar.dateComponents([.year], from: incident.incidentCreationDate ?? Date())
            let year: Int = componentYear.year!
            yearS.append(year)
        }
        yearS = Array(Set(yearS))
        yearS.sort()
        months.years = yearS
        for incident: Incident in fetchedObjects {
            
            let componentYear = calendar.dateComponents([.year], from: incident.incidentCreationDate ?? Date())
            let year: Int = componentYear.year!
            for y in yearS {
                if y == year {
                    
                }
            }
            if incident.incidentCreationDate != nil {
                let componentMonth = calendar.dateComponents([.month], from: incident.incidentCreationDate ?? Date())
                let month = componentMonth.month
                switch month {
                case 1:
                    months.january.append(incident)
                case 2:
                    months.february.append(incident)
                case 3:
                    months.march.append(incident)
                case 4:
                    months.april.append(incident)
                case 5:
                    months.may.append(incident)
                case 6:
                    months.june.append(incident)
                case 7:
                    months.july.append(incident)
                case 8:
                    months.august.append(incident)
                case 9:
                    months.september.append(incident)
                case 10:
                    months.october.append(incident)
                case 11:
                    months.november.append(incident)
                case 12:
                    months.december.append(incident)
                default: break
                }
                
            }
        }
        let count = months.yearsOfIncidents.count
        _  = months.yearsOfIncidents
        _ = months.yearCounts
        print(count)
        return months
    }
    
    
}
