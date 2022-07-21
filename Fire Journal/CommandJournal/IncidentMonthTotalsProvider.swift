//
//  IncidentMonthTotalsProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/1/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class IncidentMonthTotalsProvider: NSObject, NSFetchedResultsControllerDelegate {
    
    let calendar = Calendar.current
    var primaryYear: Int!
    var primaryMonth: Int!
    var months: YearOfMonths!
    var years = [Int]()
    var yearsOfMonths = [ Int : [(Int,[Int])] ]()
    
    
    
    
    private(set) var persistentContainer: NSPersistentContainer
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    deinit {
        print("IncidentMonthTotalsProvider is being deinitialized")
    }
    
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
    
    func getPrimaryYear() {
        let componentYear = calendar.dateComponents([.year], from: Date())
        primaryYear = componentYear.year!
    }
    
    func getPrimaryMonth() -> Int {
        var monthString: String
        var m = 0
        let componentMonth = calendar.dateComponents([.month], from: Date())
        m = componentMonth.month!
        if m < 10 {
            monthString = "0\(m)"
            primaryMonth = Int(monthString)!
        } else {
            monthString = String(m)
            primaryMonth = Int(monthString)!
        }
        return primaryMonth
    }
    
    func buidTheIncidentTotals(context: NSManagedObjectContext) -> [ Int : [(Int,[Int])] ] {
        _ = getPrimaryMonth()
        getPrimaryYear()
        let yearsConverted = getConvertedYears(context: context)
        for year in yearsConverted {
            let yearInt: Int = year.first as! Int
            let thisYear = calendar.dateComponents([.year], from: Date())
            let theYear = thisYear.year ?? 0
            months = YearOfMonths.init(theYear: theYear, lastYear: 2019)
            months.years = years
            let incidents = fetchAllDatesInYear(context: context, year: year)
            months.totalIncidents = incidents
            months.totalFireIncidents = incidents.filter { $0.situationIncidentImage == "Fire" }
            months.totalEMSIncidents = incidents.filter { $0.situationIncidentImage == "EMS" }
            months.totalRescueIncidents = incidents.filter { $0.situationIncidentImage == "Rescue" }
            for incident in incidents {
                if let creationDate = incident.incidentCreationDate  {
                    let componentMonth = calendar.dateComponents([.month], from: creationDate )
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
            let yearCounts = months.buildTheYear()
            yearsOfMonths[yearInt] = yearCounts
        }
        return yearsOfMonths
    }
    
        /// create array of years with start date 01-01 to end date 12-31
        /// - Parameter context: context
        /// - Returns: returns array[y, firstdate, lastdate]
    func getConvertedYears(context: NSManagedObjectContext) -> [[Any]] {
        years = getYearArray(context: context)
        var yearConverted = [[Any]]()
        var firstDate: Date?
        var lastDate: Date?
        for y in years {
            let firstDay = "\(y)-01-01T0:0:00+0000"
            let lastDay = "\(y)-12-31T0:0:00+0000"
            let dateFormatter = ISO8601DateFormatter()
            firstDate = dateFormatter.date(from:firstDay)!
            lastDate = dateFormatter.date(from:lastDay)
            let array = [y, firstDate!, lastDate!] as [Any]
            yearConverted.append(array)
        }
        return yearConverted
    }
    
        /// build an array of years
        /// - Parameter context:
        /// - Returns: return a sorted array of years as [Int]
    func getYearArray(context: NSManagedObjectContext) ->[Int] {
        var yearA = [Int]()
        fetchAllDates(context: context)
        if !fetchedObjects.isEmpty {
            for incident: Incident in fetchedObjects {
            
                if incident.incidentCreationDate != nil {
                        let componentYear = calendar.dateComponents([.year], from: incident.incidentCreationDate ?? Date())
                        let year = componentYear.year!
                        yearA.append(year)
                }
            }
            yearA = (Array(Set(yearA)))
            yearA.sort()
        }
        return yearA
    }
    
    func getTheYearBuilt(years: [Int], yearsOfMonths: [ Int : [(Int,[Int])] ] ) -> [EachMonthsTotal] {
        var totals = [EachMonthsTotal]()
        for year in years {
            for (key, value) in yearsOfMonths {
                if key == year {
                        for (month, count ) in value {
                            let monthTotal = EachMonthsTotal.init(theYear: year, theMonth: month, theFire: count[1], theEMS:count[2], theRescue: count[3])
                            totals.append(monthTotal)
                        }
                    }
                }
            }
        return totals
    }
    
    func getPrimaryMonthCounts(yearsOfMonths: [ Int : [(Int,[Int])] ]) -> [(Int,Int)] {
        var totals = [(Int,Int)]()
        for (key, value) in yearsOfMonths {
                if key == primaryYear {
                    let a = value
                     for (month, count ) in a {
                        if month == primaryMonth {
                            if !count.isEmpty {
                                totals = [(0,count[1]),(1,count[2]),(2,count[3])]
                            }
                        }
                    }
                }
        }
        return totals
    }
    
    
        /// get all the incidents for single year
        /// - Parameters:
        ///   - context: context
        ///   - year: array [ y, firstDate, lastDate]
        /// - Returns: search Incident for all incidents in year less than last date and greater than firstdate
    func fetchAllDatesInYear(context: NSManagedObjectContext, year: [Any]) -> [Incident] {
        
        var incidentsA = [Incident]()
        
        let yearInt: Int = year.first as! Int
        let fDate: NSDate = year[1] as! NSDate
        let lDate: NSDate = year.last! as! NSDate
        
        let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()
               var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","incidentDateSearch","")
        var predicate1 = NSPredicate.init()
        predicate1 = NSPredicate(format: "%K >= %@ && %K <= %@", "incidentCreationDate", fDate ,"incidentCreationDate",lDate)
         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate1])
        fetchRequest.predicate = predicateCan
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("CrewModalDataTVC line 178 Fetch Error: \(error.localizedDescription)")
        }
        if !fetchedObjects.isEmpty {
            incidentsA = fetchedObjects
        }
        return incidentsA
    }
    
    /// fetch all incidents with date
    func fetchAllDates(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()
        var dateComponents = DateComponents()
        dateComponents.year = 2010
        let userCalendar = Calendar(identifier: .gregorian)
        if let theDate = userCalendar.date(from: dateComponents) {
            
            var predicate1 = NSPredicate.init()
            predicate1 = NSPredicate(format: "%K >= %@", "incidentCreationDate", theDate as CVarArg)
                //               var predicate = NSPredicate.init()
                //               predicate = NSPredicate(format: "%K != %@","incidentDateSearch","")
            
            fetchRequest.predicate = predicate1
        }
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
                   print("FetchAllDates Fetch Error: \(error.localizedDescription)")
               }
    }
    
}
