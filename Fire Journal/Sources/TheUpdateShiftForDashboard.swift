//
//  TheUpdateShiftForDashboard.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/27/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TheUpdateShiftForDashboard: NSObject, NSFetchedResultsControllerDelegate {
    
    //    MARK: -PROPERTIES-
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var updateShiftData: UpdateShiftDashbaordData!
    var todaysDate: Date
    var resources = [UserFDResources]()
    var fetchedResources = [UserFDResources]()
    
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
    
    init(thisDay: Date) {
        self.todaysDate = thisDay
    }
    
    func buildShiftForDashboard() -> UpdateShiftDashbaordData {
        updateShiftData = UpdateShiftDashbaordData.init(theDate: todaysDate)
        _ = getTheShift()
        if fetchedObjects.isEmpty {} else {
            fetchTheResources()
            let shift = fetchedObjects.last
            if fetchedResources.isEmpty {} else {
                updateShiftData.resources = fetchedResources
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd,YYYY"
            let shiftDate = dateFormatter.string(from: shift?.userUpdateShiftTime ?? todaysDate)
            dateFormatter.dateFormat = "HH:mm"
            let shiftTime = dateFormatter.string(from: shift?.userUpdateShiftTime ?? todaysDate)
            updateShiftData.shiftStatusName = "Update Shift"
            updateShiftData.shiftUpdateDate = shiftDate
            updateShiftData.shiftUpdateTime = "\(shiftTime) HRs"
            updateShiftData.shiftPlatoonName = shift?.updateShiftPlatoon
            updateShiftData.shiftFireStationNumber = shift?.updateShiftFireStation
        }
        return updateShiftData
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
            print("TheUpdateShiftForDashboard line 83 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
    private func fetchTheResources() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources")
        let sectionSortDescriptor = NSSortDescriptor(key: "fdResource", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        do {
            fetchedResources = try context.fetch(fetchRequest) as! [UserFDResources]
            if fetchedResources.count == 0 {
                
            } else {
                resources = fetchedResources
            }
        }  catch {
            let nserror = error as NSError
            let errorMessage = "SettingsUserFDResourcesTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
}
