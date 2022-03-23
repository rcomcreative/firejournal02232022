//
//  EndShiftForDashboard.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/27/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EndShiftForDashboard: NSObject, NSFetchedResultsControllerDelegate {
    
    
    //    MARK: -PROPERTIES-
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var endShiftData: TodayEndShiftData!
    var todaysDate: Date
    var fetchedIncidents = [Incident]()
    
    private var fetchedResultsController: NSFetchedResultsController<UserTime>? = nil
    private var _fetchedResultsController: NSFetchedResultsController<UserTime> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    private var fetchedObjects: [UserTime] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    init(theDate: Date) {
        self.todaysDate = theDate
    }
    
    func buildTheEndShift() -> TodayEndShiftData {
        var endShiftData = TodayEndShiftData.init(theDate: todaysDate)
        _ = getTheShift()
        if fetchedObjects.isEmpty {
            endShiftData.shiftIncidentCout = "0 Incidents"
            endShiftData.shiftStatusName = "End Shift"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd,YYYY"
            let shiftDate = dateFormatter.string(from: todaysDate)
            dateFormatter.dateFormat = "HH:mm"
            let shiftTime = dateFormatter.string(from: todaysDate)
            endShiftData.shiftEndDate = shiftDate
            endShiftData.shiftEndTime = "\(shiftTime) HRs"
        } else {
            let shift = fetchedObjects.last
            let incidentCount = fetchTheIncident()
            endShiftData.shiftIncidentCout = incidentCount
            endShiftData.shiftStatusName = "End Shift"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd,YYYY"
            let shiftDate = dateFormatter.string(from: shift?.userEndShiftTime ?? todaysDate)
            dateFormatter.dateFormat = "HH:mm"
            let shiftTime = dateFormatter.string(from: shift?.userEndShiftTime ?? todaysDate)
            endShiftData.shiftEndDate = shiftDate
            endShiftData.shiftEndTime = "\(shiftTime) HRs"
        }
        return endShiftData
    }
    
    private func getTheShift() ->[UserTime] {
        let fetchRequest: NSFetchRequest<UserTime> = UserTime.fetchRequest()
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","userTimeGuid","")
//        var predicate1 = NSPredicate.init()
//        predicate1 = NSPredicate(format: "%K >= %@", "userStartShiftTime", todaysDate as CVarArg)

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "userStartShiftTime", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("EndShiftForDashboard line 88 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
    private func fetchTheIncident() -> String {
        var countString = ""
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident")
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","incidentDateSearch","")
        var predicate1 = NSPredicate.init()
        predicate1 = NSPredicate(format: "%K >= %@", "incidentCreationDate", todaysDate as CVarArg)

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate1])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            fetchedIncidents = try context.fetch(fetchRequest) as! [Incident]
            if fetchedIncidents.isEmpty {
                countString = "0 Incidents"
            } else {
                let count = fetchedIncidents.count
                if count == 1 {
                    countString = "1 Incident"
                } else {
                    countString = "\(count) Incidents"
                }
            }
        }  catch {
            let nserror = error as NSError
            let errorMessage = "SettingsUserFDResourcesTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        return countString
    }
    
    
}
