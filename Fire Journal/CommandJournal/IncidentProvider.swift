//
//  IncidentProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/22/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//
import UIKit
import CoreData

class IncidentProvider: NSObject, NSFetchedResultsControllerDelegate {
    
    var fjUserTime: UserTime!
    let calendar = Calendar.current
    
    var month: String = ""
    var day: String = ""
    var year: String = ""
    var hour: String = ""
    var minute: String = ""
    
    var firstDate: Date!
    
    var yearCInt: Int!
    var monthCInt: Int!
    
    private var fetchedResultsController: NSFetchedResultsController<Incident>? = nil
    var _fetchedResultsController: NSFetchedResultsController<Incident> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    deinit {
        print("IncidentProvider is being deinitialized")
    }
    
    var fetchedObjects: [Incident] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    private(set) var persistentContainer: NSPersistentContainer
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getTodaysIncidents(context: NSManagedObjectContext, userTime: UserTime ) -> [Incident]? {
        var theIncidents = [Incident]()
        if let startDate = userTime.userStartShiftTime {
            _ = buildTheDay(startDate)
            _ = getTheDaysIncidents(firstDate, context: context)
            theIncidents = fetchedObjects
        } else {
            return nil
        }
        return theIncidents
    }
    
    
        /// Build the start of the shift date from UserTime.userStartShifttime
        /// - Parameter theNewShiftDate: date
        /// - Returns: date to find all incidents dates greater than date returned
    private func buildTheDay(_ theNewShiftDate: Date ) -> Date {
        let componentMonth = calendar.dateComponents([.month], from: theNewShiftDate )
        let m: Int = componentMonth.month!
        monthCInt = componentMonth.month!
        let componentYear = calendar.dateComponents([.year], from: theNewShiftDate)
        let y: Int = componentYear.year!
        yearCInt = componentYear.year!
        let componentDate = calendar.dateComponents([.day], from: theNewShiftDate)
        let d: Int = componentDate.day!
        month = m < 10 ? "0\(m)" : String(m)
        day = d < 10 ? "0\(d)" : String(d)
        year = String(y)
        let componentHour = calendar.dateComponents([.hour], from: theNewShiftDate)
        let h: Int = componentHour.hour!
        hour = String(h)
        let componentMinute = calendar.dateComponents([.minute], from: theNewShiftDate)
        let min: Int = componentMinute.minute!
        minute = String(min)
        let firstDay = "\(year)-\(month)-\(day)T\(hour):\(minute):00+0000"
        let dateFormatter = ISO8601DateFormatter()
        firstDate = dateFormatter.date(from: firstDay)
        return firstDate
    }
    
    
        /// fetch all incidents that were entered for shift after userStartShiftTime
        /// - Parameters:
        ///   - theDate: userTime.userStartShiftTime
        ///   - context: backgroundContext
        /// - Returns: returns a list of incidents
    func getTheDaysIncidents(_ theDate: Date, context: NSManagedObjectContext) -> [Incident]? {
        let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()

        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","incidentDateSearch","")
        var predicate1 = NSPredicate.init()
        predicate1 = NSPredicate(format: "%K >= %@", "incidentCreationDate", theDate as CVarArg)

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate1])
        fetchRequest.predicate = predicateCan
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
            print("TodaysIncidentsForDashboard line 92 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
    
}
