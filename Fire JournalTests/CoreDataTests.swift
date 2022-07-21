//
//  CoreDataTests.swift
//  Fire JournalTests
//
//  Created by DuRand Jones on 7/15/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import XCTest
import UIKit
import Foundation
import MapKit
import CoreLocation
import CoreData
@testable import Fire_Journal

class CoreDataTests: XCTestCase, NSFetchedResultsControllerDelegate {
    
    var sut: NSManagedObjectContext!
    var theSut: NSManagedObjectModel!
    //    var autograph: T1Autograph = T1Autograph()
    var ics214Fetched: Array<ICS214Form>!
    var userFetched: Array<FireJournalUser>!
    var userResourcesFetched: Array<UserResources>!
    let entity: String = "ICS214Form"
    var user: FireJournalUser!
    var address: String = ""
    private var currentLocation: CLLocation?
    var userResources = [UserResources]()
    var fetchedUserResources = [UserResources]()
    var incidentFDResources = [UserFDResources]()
    let calendar = Calendar.current
    var months: YearOfMonths!
    var years = [Int]()
    var yearsOfMonths = [ Int : [(Int,[Int])] ]()
    var yearsOfMonthsSorted = [ Int : Any ]()
    var yearKeyMonthValueA = [Int: Any]()
    var yearMonthCountsA: [Int: [Int: Int]]!
    
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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        sut = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        theSut = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.managedObjectModel
        months = YearOfMonths.init(theYear: 2020, lastYear: 2019)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        super.tearDown()
    }
    
    func testCoreData() {
        XCTAssertNotNil(sut, "context not nil")
    }
    
    func testEntities() {
        let entityNames = theSut.entities.map({ $0.name!})
        print(entityNames)
        XCTAssertNotNil(sut, "context not nil")
    }
    
    func deadTestFetchAllICS214Masters() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", "ics214EffortMaster",  NSNumber(value: true))
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        
        do {
            self.ics214Fetched = try sut.fetch(fetchRequest) as? [ICS214Form]
        } catch {
        }
        
        XCTAssertEqual(self.ics214Fetched.count, 0)
    }
    
    func deadTestFetchAllICS214FormMastersWithLocation() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", "ics214EffortMaster",  NSNumber(value: true))
        let predicate2 = NSPredicate(format: "%K = nil","ics214Location")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        fetchRequest.predicate = predicateCan
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        
        do {
            self.ics214Fetched = try sut.fetch(fetchRequest) as? [ICS214Form]
        } catch {
        }
        
        XCTAssertEqual(self.ics214Fetched.count, 0)
        
    }
    
    func deadTestCreateFireJournalUserWithAddress() {
        let fju = FireJournalUser.init(entity: NSEntityDescription.entity(forEntityName: "FireJournalUser", in: sut)!, insertInto: sut)
        fju.firstName = "DuRand"
        fju.lastName = "Jones"
        fju.fireStationStreetNumber = "1455"
        fju.fireStationStreetName = "N Avenida Caballeros"
        fju.fireStationCity = "Palm Springs"
        fju.fireStationState = "CA"
        fju.fireStationZipCode = "92262"
        
        do {
            try sut.save()
        } catch {
            print("nothing happening here")
        }
        
        XCTAssertNotNil(fju, "Damn")
    }
    
    func createLocationFromFireStationAddress() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        let predicate = NSPredicate(format: "%K = %@","firstName","DuRand")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        let sectionSortDescriptor = NSSortDescriptor(key: "firstName", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        
        do {
            self.userFetched = try sut.fetch(fetchRequest) as? [FireJournalUser]
            self.user = self.userFetched.last
        } catch {
        }
        
        XCTAssertNotNil(self.user, "not empty")
    }
    
    func deadTestGetLocationFromUserFireStation() {
        createLocationFromFireStationAddress()
        if let number = self.user.fireStationStreetNumber {
            print(number)
            let geocoder = CLGeocoder()
            if let streetNum = user.fireStationStreetNumber {
                address = streetNum
            }
            if let streetName = user.fireStationStreetName {
                address = "\(address) \(streetName)"
            }
            if let city = user.fireStationCity {
                address = "\(address) \(city)"
            }
            if let state = user.fireStationState {
                address = "\(address) \(state)"
            }
            if let zip = user.fireStationZipCode {
                address = "\(address) \(zip)"
            }
            
            geocoder.geocodeAddressString(address) {
                placemarks, error in
                let placemark = placemarks?.first
                if let location = placemark?.location {
                    self.currentLocation = location
                    XCTAssertNotNil(self.currentLocation, "we have a location")
                }
            }
        }
    }
    
    func testPlistLoadIntoArray() {
        guard let path = Bundle.main.path(forResource: "Resources", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        //        let resources = dict?["resource"] as! Array<String>
        //        let displayOrders = dict?["displayOrder"] as! Array<Int>
        XCTAssertNotNil(dict)
    }
    
    func deadTestLoadPlistIntoContext() {
        guard let path = Bundle.main.path(forResource: "Resources", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        let resources = dict?["resource"] as! Array<String>
        let displayOrders = dict?["displayOrder"] as! Array<Int>
        
        
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let resource = resources[index]
                
                let list = UserResourcesList.init(display: display, type: resource, date: Date())
                
                let userResource = UserResources.init(entity: NSEntityDescription.entity(forEntityName: "UserResources", in: sut)!, insertInto: sut)
                userResource.displayOrder = Int64(list.displayOrder)
                userResource.entryState = list.entryState.rawValue
                userResource.defaultResource = list.defaultResource
                userResource.resource = list.theResource
                userResource.resourceModificationDate = list.theResourceDate
                userResource.resourceGuid = list.theResourceGuid
                userResource.resourceBackUp = false
                userResources.append(userResource)
            }
            do {
                try sut.save()
            } catch {
                print("nothing happening here")
            }
            XCTAssertNotNil(userResources)
        }
    }
    
    func deadTestAddCustomResourcesToUserResources() {
        let custom = ["Medic","Trombone","Quartet","Trumpet"]
        let display = [0,1,2,3]
        for c in display {
            let list = UserResourcesList.init(display: c, type: custom[c], date: Date())
            print(list)
            let userResource = UserResources.init(entity: NSEntityDescription.entity(forEntityName: "UserResources", in: sut)!, insertInto: sut)
            userResource.displayOrder = Int64(list.displayOrder)
            userResource.entryState = list.entryState.rawValue
            userResource.defaultResource = list.defaultResource
            userResource.resource = list.theResource
            userResource.resourceModificationDate = list.theResourceDate
            userResource.resourceGuid = list.theResourceGuid
            userResource.resourceBackUp = false
            userResources.append(userResource)
        }
        
        do {
            try sut.save()
        } catch {
            print("nothing happening here")
        }
        XCTAssertNotNil(userResources)
        
    }
    
    func deadTestDeleteAllResources() {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources")
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try sut.execute(batchDeleteRequest)
            XCTAssertNotNil(batchDeleteRequest, "NOT SURE")
        } catch {
            // Error Handling
        }
        
    }
    
    func getAllResources()->Array<UserResources> {
        var userResourcesArray = [UserResources]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources" )
        let predicate = NSPredicate(format: "%K != %@","resource","")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        let sectionSortDescriptor = NSSortDescriptor(key: "resource", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        
        do {
            userResourcesArray = (try sut.fetch(fetchRequest) as? [UserResources])!
            print("here is the userResources \(userResourcesArray.count)")
        } catch {
        }
        
        XCTAssertNotNil(userResourcesArray, "array not empty")
        return userResourcesArray
        //        XCTAssertNotNil(self.userResourcesFetched, "not empty")
    }
    
    func filterTheCollectionWithArray()->Array<UserResources>{
        self.userResourcesFetched = getAllResources()
        var resourcesArray = [UserResources]()
        guard let path = Bundle.main.path(forResource: "Resources", ofType:"plist") else { return resourcesArray }
        let dict = NSDictionary(contentsOfFile:path)
        let resources = dict?["resource"] as! Array<String>
        let displayOrders = dict?["displayOrder"] as! Array<Int>
        
        
        
        if dict != nil {
            for (index, _ ) in displayOrders.enumerated() {
                let resource = resources[index]
                let result = self.userResourcesFetched.filter{ $0.resource == resource }
                XCTAssertNotNil(result, "the result was not nil")
                if !result.isEmpty {
                    resourcesArray.append(result[0])
                }
            }
        }
        print("here are the resources \(resourcesArray.count) here are all the resources \(resourcesArray)")
        XCTAssertNotNil(resourcesArray, "array not empty")
        return resourcesArray
    }
    
    func deadTestUpdatingUserResourcesNotCustom() {
        let resourcesArray = filterTheCollectionWithArray()
        for resource in resourcesArray {
            resource.resourceCustom = false
            do {
                try sut.save()
            } catch {
                print("nothing happening here")
            }
            XCTAssertNotNil(resource)
        }
    }
    
    func fetchUserResourcesForCustomNotMarked()->Array<UserResources> {
        var userResourcesArray = [UserResources]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources" )
        //        let predicate = NSPredicate(format: "%K != %@","resourceCustom",NSNumber(value: false))
        let predicate = NSPredicate(format: "%K = nil","resourceCustom")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        let sectionSortDescriptor = NSSortDescriptor(key: "resource", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        
        do {
            userResourcesArray = (try sut.fetch(fetchRequest) as? [UserResources])!
            print("here is the userResources \(userResourcesArray.count)")
        } catch {
        }
        
        XCTAssertNotNil(userResourcesArray, "array not empty")
        return userResourcesArray
    }
    
    
    func testUpdateNilToCustomTrueUserResources() {
        let userResourceArray = fetchUserResourcesForCustomNotMarked()
        for resource in userResourceArray {
            resource.resourceCustom = true
            do {
                try sut.save()
            } catch {
                print("nothing happening here")
            }
            XCTAssertNotNil(resource)
        }
    }
    
    func getAllTheUserResources()->Array<UserResources> {
        var userResourcesArray = [UserResources]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources" )
        let sectionSortDescriptor = NSSortDescriptor(key: "resource", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        
        do {
            userResourcesArray = (try sut.fetch(fetchRequest) as? [UserResources])!
            print("here is the userResources \(userResourcesArray.count)")
        } catch {
        }
        
        XCTAssertNotNil(userResourcesArray, "array not empty")
        return userResourcesArray
    }
    
    func getAllFDResources()->Array<UserFDResources> {
        var userResourcesArray = [UserFDResources]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources" )
        let sectionSortDescriptor = NSSortDescriptor(key: "fdResource", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        
        do {
            userResourcesArray = (try sut.fetch(fetchRequest) as? [UserFDResources])!
            print("here is the userResources \(userResourcesArray.count)")
        } catch {
        }
        
        XCTAssertNotNil(userResourcesArray, "array not empty")
        return userResourcesArray
    }
    
    func testUserResourcesRemoveUserFDResources()->Array<UserResources> {
        let userResourcesArray = getAllTheUserResources()
        let userFDResourcesArray = getAllFDResources()
        var resourcesArray = [UserResources]()
        var resourceString = [String]()
        for resource in userFDResourcesArray {
            resourceString.append(resource.fdResource!)
        }
        let result = userResourcesArray.filter{ resourceString.contains($0.resource!) }
        XCTAssertNotNil(result)
        resourcesArray.append(contentsOf: result)
        return resourcesArray
    }
    
    func testStringToInt(){
        let stringArray = ["01","02","30","40","91"]
        for s in stringArray {
            let type = Int(s)
            switch type {
            case 01:
                print("here is the type \(String(describing: type))")
            case 02:
                print("here is the type \(String(describing: type))")
            case 30:
                print("here is the type \(String(describing: type))")
            case 40:
                print("here is the type \(String(describing: type))")
            case 91:
                print("here is the type \(String(describing: type))")
            default: break
            }
        }
    }
    
    func getTheYearArray() {
        var yearA = [Int]()
        let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()
               var predicate = NSPredicate.init()
               predicate = NSPredicate(format: "%K != %@","incidentDateSearch","")
               
               fetchRequest.predicate = predicate
               fetchRequest.fetchBatchSize = 20
               
               let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
               let sortDescriptors = [sectionSortDescriptor]
               fetchRequest.sortDescriptors = sortDescriptors
               
               let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: sut, sectionNameKeyPath: nil, cacheName: "Master")
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
    }
    
    func getTheIncidents() -> [Incident] {
        getTheYearArray()
        months.years = years
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
            
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: sut, sectionNameKeyPath: nil, cacheName: nil)
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
                    print("here is the month \(String(describing: month)) and the year \(yearInt)")
                   
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
            print("this is \(yearInt) yearsOfMonths \(yearsOfMonths)")
        }
        return months.totalIncidents
    }
    
    func getYearsWorthOfIncidents() -> [Incident] {
        getTheYearArray()
        months.years = years
        let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()
                   var predicate = NSPredicate.init()
                   predicate = NSPredicate(format: "%K != %@","incidentDateSearch","")
                    let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                   fetchRequest.predicate = predicateCan
                   fetchRequest.fetchBatchSize = 20
                   
                   let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
                   let sortDescriptors = [sectionSortDescriptor]
                   fetchRequest.sortDescriptors = sortDescriptors
                   
                   let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: sut, sectionNameKeyPath: nil, cacheName: nil)
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
        return months.totalIncidents
    }
    
    func testTheIncidents() {
        let incidents = getTheIncidents()
        for year in months.years {
            for (key, value) in yearsOfMonths {
                if key == year {
                    let test = value
                    for (month, count ) in test {
                        print("here is year \(year) here is the month \(month) and the count: for month \(count[0]) for fire: \(count[1]) for ems: \(count[2]) for rescue: \(count[3])\n")
                    }
                }
            }
        }
        print(months.years)
//        let incidents = getYearsWorthOfIncidents()
//        var tester = [Int: [(Int, Incident)]]()
//        for y in years {
//            months.yearForMonth = y
//            let test = months.yearAndMonths
//            tester[y] = test
//            print("this")
//        }
//        var testingCounts = [ Int: [ (Int, [Int] )] ]()
//        for y in years {
//            months.yearForMonth = y
//            let testC = months.yearAndCounts
//            testingCounts[y] = testC
//            print("this")
//        }
//        testingCounts.sorted(by:  { $0.0 < $1.0 })
//        print(months.yearsOfIncidents)
//        let count = String(incidents.count)
        XCTAssertNotNil(incidents)
    }
    
    
    
}
