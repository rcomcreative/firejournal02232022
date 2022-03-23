//
//  IncidentMonthTotalsForDashboard.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/18/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class IncidentMonthTotalsForDashboard: NSObject, NSFetchedResultsControllerDelegate {

    //    MARK: -PROPERTIES-
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var year: Int
    let calendar = Calendar.current
    var months: YearOfMonths!
    var years = [Int]()
    var yearsOfMonths = [ Int : [(Int,[Int])] ]()
    var primaryYear: Int!
    var primaryMonth: Int!
    
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
    
    init(theYear: Int) {
        self.year = theYear
        super.init()
        self.getPrimaryYear()
        _ = self.getPrimaryMonth()
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
    
    func getPrimaryMonthCounts() -> [(Int,Int)] {
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
    
    func getTheYearBuilt() -> [EachMonthsTotal] {
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


//        print("And here is totals \(totals)")

        return totals
    }
    
    func getTheYearArray() -> [Int] {
        var yearA = [Int]()
        let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()
               var predicate = NSPredicate.init()
               predicate = NSPredicate(format: "%K != %@","incidentDateSearch","")
               
               fetchRequest.predicate = predicate
               fetchRequest.fetchBatchSize = 20
               
               let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
               let sortDescriptors = [sectionSortDescriptor]
               fetchRequest.sortDescriptors = sortDescriptors
               
               let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "Master")
               aFetchedResultsController.delegate = self
               fetchedResultsController = aFetchedResultsController
               do {
                   try fetchedResultsController?.performFetch()
               } catch let error as NSError {
                   print("CrewModalDataTVC line 178 Fetch Error: \(error.localizedDescription)")
               }
        for incident: Incident in fetchedObjects {
        
            if incident.incidentCreationDate != nil {
                    let componentYear = calendar.dateComponents([.year], from: incident.incidentCreationDate ?? Date())
                    let year = componentYear.year!
                    yearA.append(year)
            }
        }
        years = (Array(Set(yearA)))
        years.sort()
        return years
    }
    
    func getTheIncidents() ->[ Int : [(Int,[Int])] ] {// [Incident] {
        _ = getTheYearArray()
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
        
        for year in yearConverted {
            months = YearOfMonths.init(theYear: 2020, lastYear: 2019)
            months.years = years
            let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()
            var predicate = NSPredicate.init()
            predicate = NSPredicate(format: "%K != %@","incidentDateSearch","")
            var predicate1 = NSPredicate.init()
            let yearInt: Int = year.first as! Int
            let fDate: NSDate = year[1] as! NSDate
            let lDate: NSDate = year.last! as! NSDate
            predicate1 = NSPredicate(format: "%K >= %@ && %K <= %@", "incidentCreationDate", fDate ,"incidentCreationDate",lDate)
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
                print("CrewModalDataTVC line 178 Fetch Error: \(error.localizedDescription)")
            }

            months.totalIncidents = fetchedObjects
            months.totalFireIncidents = fetchedObjects.filter { $0.situationIncidentImage == "Fire" }
            months.totalEMSIncidents  = fetchedObjects.filter { $0.situationIncidentImage == "EMS" }
            months.totalRescueIncidents = fetchedObjects.filter { $0.situationIncidentImage == "Rescue" }
            
            for incident: Incident in fetchedObjects {
                
                if incident.incidentCreationDate != nil {
                    let componentMonth = calendar.dateComponents([.month], from: incident.incidentCreationDate ?? Date())
                    let month = componentMonth.month
//                    print("here is the month \(String(describing: month)) and the year \(yearInt)")
                   
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
//            print("this is \(yearInt) yearsOfMonths \(yearsOfMonths)")
        }
        return yearsOfMonths
    }
    
    
    
}
