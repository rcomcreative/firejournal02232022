//
//  TodaysIncidentsForDashboard.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/17/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class TodaysIncidentsForDashboard: NSObject, NSFetchedResultsControllerDelegate {
    
    //    MARK: -PROPERTIES-
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var month: String = ""
    var day: String = ""
    var year: String = ""
    var monthNumber: Int = 1
    var monthDate = Date()
    let fireImage = UIImage(named: "100515IconSet_092016_fireboard")
    let emsImage = UIImage(named: "100515IconSet_092016_emsboard")
    let rescueImage = UIImage(named: "100515IconSet_092016_rescueboard")
    let userDefaults = UserDefaults.standard

    var fjUserTime: UserTime!
    let calendar = Calendar.current
    var firstDate: Date!
    var lastDate: Date!
    var fjUserTimeCD: UserTime

    var userTimeDate: Date
    var months: YearOfMonths!
    var monthInt: Int!
    var fireInt: Int!
    var emsInt: Int!
    var rescueInt: Int!
    var yearCInt: Int!
    var monthCInt: Int!
    var alarmTime: String = ""
    var arrivalTime: String = ""
    var controlledTime: String = ""
    var lastUnitTime: String = ""
    var theIncidentDate: String = ""
    var streetNum: String = ""
    var streetName: String = ""
    var streetAddress: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    var resources: String = ""
    var theResources = [IncidentResources]()
    var incidentUserResources = [IncidentUserResource]()
    
    private var fetchedResultsController: NSFetchedResultsController<Incident>? = nil
    var _fetchedResultsController: NSFetchedResultsController<Incident> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    deinit {
        print("TodaysIncidentsForDashboard is being deinitialized")
    }
    
    var fetchedObjects: [Incident] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    init(userTime: UserTime ) {
        self.fjUserTimeCD = userTime
        if self.fjUserTimeCD.userStartShiftTime == nil {
            self.userTimeDate = Date()
        } else {
            self.userTimeDate = self.fjUserTimeCD.userStartShiftTime!
        }
        months = YearOfMonths.init(theYear: 2020, lastYear: 2019)
        super.init()
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: nil)
    }
    
    func getTheDaysIncidents() ->[Incident] {
        let componentMonth = calendar.dateComponents([.month], from: userTimeDate )
        let m: Int = componentMonth.month!
        monthCInt = componentMonth.month!
        let componentYear = calendar.dateComponents([.year], from: userTimeDate)
        let y: Int = componentYear.year!
        yearCInt = componentYear.year!
        let componentDate = calendar.dateComponents([.day], from: userTimeDate)
        let d: Int = componentDate.day!
        month = m < 10 ? "0\(m)" : String(m)
        day = d < 10 ? "0\(d)" : String(d)
        year = String(y)
        let firstDay = "\(year)-\(month)-\(day)T0:0:00+0000"
        let lastDay = "\(year)-\(month)-\(day)T11:59:00+0000"
        let dateFormatter = ISO8601DateFormatter()
        firstDate = dateFormatter.date(from: firstDay)
        lastDate = dateFormatter.date(from: lastDay)
        let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()

        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","incidentDateSearch","")
        var predicate1 = NSPredicate.init()
        predicate1 = NSPredicate(format: "%K >= %@", "incidentCreationDate", firstDate as CVarArg)

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
    
    func getTheLastIncidentDate()->TodaysIncidentCount {
        var incidentCount: TodaysIncidentCount!
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
            print("TodaysIncidentsForDashboard line 92 Fetch Error: \(error.localizedDescription)")
        }
        if !fetchedObjects.isEmpty {
            let incident  = fetchedObjects.last
            userTimeDate = (incident?.incidentCreationDate)!
            incidentCount = buildTodaysIncidentCount()
        } else {
            incidentCount = TodaysIncidentCount.init(fire: "0", ems: "0", rescue: "0", count: "0", year: "0", month: "0")
        }
        return incidentCount
    }
    
    func buildTodaysIncidentCount()->TodaysIncidentCount {
        _ = getTheDaysIncidents()
        var incidentCount: TodaysIncidentCount!
        if fetchedObjects.isEmpty {
            incidentCount = TodaysIncidentCount.init(fire: "0", ems: "0", rescue: "0", count: "0", year: "0", month: "0")
            
        } else {
            months.totalIncidents = fetchedObjects
            months.totalFireIncidents = fetchedObjects.filter { $0.situationIncidentImage == "Fire" }
            months.totalEMSIncidents  = fetchedObjects.filter { $0.situationIncidentImage == "EMS" }
            months.totalRescueIncidents = fetchedObjects.filter { $0.situationIncidentImage == "Rescue" }
            monthInt = months.totalIncidents.count
            fireInt = months.totalFireIncidents.count
            emsInt = months.totalEMSIncidents.count
            rescueInt = months.totalRescueIncidents.count
            let fire = String(fireInt)
            let ems = String(emsInt)
            let rescue = String(rescueInt)
            let monthCount = String(monthInt)
            let year = String(yearCInt)
            let month = String(monthCInt)
            incidentCount = TodaysIncidentCount.init(fire: fire, ems: ems, rescue: rescue, count: monthCount, year: year, month: month)
        }
        return incidentCount
    }
    
    func buildTodaysIncidents() -> [TodayIncident] {
        var todaysIncidents = [TodayIncident]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        if fetchedObjects.isEmpty {
        } else {
            for incident in fetchedObjects {
                var todaysIncident = TodayIncident.init(number: incident.incidentNumber ?? "")
                todaysIncident.objectID = incident.objectID
                let imageName = incident.situationIncidentImage ?? "Fire"
                if imageName == "Fire" {
                    todaysIncident.incidentImage = fireImage
                    todaysIncident.situationIncidentImage = imageName
                } else if imageName == "EMS" {
                    todaysIncident.incidentImage = emsImage
                    todaysIncident.situationIncidentImage = imageName
                } else if imageName == "Rescue" {
                    todaysIncident.incidentImage = rescueImage
                    todaysIncident.situationIncidentImage = imageName
                }
                let times = incident.incidentTimerDetails
                let alarmDate = times?.incidentAlarmDateTime
                if alarmDate != nil {
                    alarmTime = dateFormatter.string(from: alarmDate! )
                    alarmTime = "\(alarmTime) Alarm"
                }
                todaysIncident.alarmTime = alarmTime
                let arrivalDate = times?.incidentArrivalDateTime
                if arrivalDate != nil {
                    arrivalTime = dateFormatter.string(from: arrivalDate!)
                    arrivalTime = "\(arrivalTime) Arrive"
                }
                todaysIncident.arrivalTime = arrivalTime
                let controlledDate = times?.incidentControlDateTime
                if controlledDate != nil {
                    controlledTime = dateFormatter.string(from: controlledDate!)
                    controlledTime = "\(controlledTime) Controlled"
                }
                todaysIncident.controlledTime = controlledTime
                let lastUnitDate = times?.incidentLastUnitDateTime
                if lastUnitDate != nil {
                    lastUnitTime = dateFormatter.string(from: lastUnitDate!)
                    lastUnitTime = "\(lastUnitTime) Last Unit Standing"
                }
                todaysIncident.lastUnitTime = lastUnitTime
//                dateFormatter.dateFormat = "E, MM/dd/YYYY"
                dateFormatter.dateFormat = "MM/dd/YYYY"
                let incidentDate = incident.incidentCreationDate
                if incidentDate != nil {
                    theIncidentDate = dateFormatter.string(from: incidentDate!)
                }
                todaysIncident.theIncidentDate = theIncidentDate
                let incidentAddress = incident.incidentAddressDetails
                if incidentAddress?.streetNumber != "" {
                    let num = incidentAddress?.streetNumber
                    streetAddress = num!
                    if incidentAddress?.streetHighway != "" {
                        let street = incidentAddress?.streetHighway
                        streetAddress = "\(streetAddress) \(street!)"
                    }
                }
                todaysIncident.streetAddress = streetAddress
                if incidentAddress?.city != "" {
                    let incidentCity = incidentAddress?.city
                    city = incidentCity!
                }
                todaysIncident.incidentCity = city
                if incidentAddress?.incidentState != "" {
                    let iState = incidentAddress?.incidentState
                    state = iState!
                }
                todaysIncident.incidentState = state
                if incidentAddress?.zip != "" {
                    let iZip = incidentAddress?.zip
                    zip = iZip!
                }
                todaysIncident.incidentZip = zip
                if city != "" {
                    todaysIncident.cityStateZip = "\(city), \(state) \(zip)"
                }
                if todaysIncident.streetAddress != "" {
                    if todaysIncident.cityStateZip != "" {
                        let street = todaysIncident.streetAddress!
                        let city = todaysIncident.cityStateZip
                        todaysIncident.incidentAnnotationAddress = "\(street) \(city)"
                    }
                }
                
//                MARK: -LOCATION-
                /// incidentLocation unarchived from secureCoding
                if incident.incidentLocationSC != nil {
                    if let location = incident.incidentLocationSC {
                        guard let  archivedData = location as? Data else { return todaysIncidents }
                        do {
                            guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return todaysIncidents }
                            let location:CLLocation = unarchivedLocation
                            todaysIncident.incidentLocation = location
                        } catch {
                            print("boy there was an error here")
                        }
                    }
                }
                
                var resourcesA = [String]()
                let guid = incident.fjpIncGuidForReference ?? ""
                if guid != "" {
                fetchTheResources(guid: guid)
                if theResources.count != 0 {
                    for resources in theResources {
                        var iur = IncidentUserResource.init(imageName: resources.incidentResource ?? "")
                        iur.customOrNot = resources.resourceCustom
                        iur.type = resources.resourceType
                        iur.assetName = "RedSelectedCHECKED"
                        iur.incidentGuid = resources.incidentReference ?? ""
                        incidentUserResources.append(iur)
                        resourcesA.append(iur.imageName)
                    }
                }
                
                resourcesA = resourcesA.filter { $0 != "" }
                resourcesA = Array(NSOrderedSet(array: resourcesA)) as! [String]
                let resource:String = resourcesA.joined(separator: ", ")
                resources = resource
                }
                todaysIncident.incidentResources = resources
                todaysIncidents.append(todaysIncident)
            }
        }
        return todaysIncidents
    }
    
    func fetchTheResources(guid:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "IncidentResources" )
        let predicate = NSPredicate(format: "%K == %@", "incidentReference", guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentResource", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        do {
            theResources = try context.fetch(fetchRequest) as! [IncidentResources]
        } catch let error as NSError {
            print("IncidentTVC line 1132 Fetch Error: \(error.localizedDescription)")
        }
    }
}
