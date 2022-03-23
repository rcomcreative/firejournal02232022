//
//  NewICS214Tests.swift
//  Fire JournalTests
//
//  Created by DuRand Jones on 7/20/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import XCTest
import UIKit
import Foundation
import MapKit
import CoreLocation
import CoreData
@testable import Fire_Journal

class NewICS214Tests: XCTestCase, NSFetchedResultsControllerDelegate {
    
    var sut: NSManagedObjectContext!
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
    var form: ICS214Form!

    var crewGuid = ""
    var formGuid = ""
    
    private var fetchedResultsController: NSFetchedResultsController<ICS214Form>? = nil
    var _fetchedResultsController: NSFetchedResultsController<ICS214Form> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    var fetchedObjects: [ICS214Form] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        sut = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        super.tearDown()
    }
    
    func testCoreData() {
        XCTAssertNotNil(sut, "context not nil")
    }
    
    func getTheICS214() -> [ICS214Form] {
        var ics214 = [ICS214Form]()
        let fetchRequest: NSFetchRequest<ICS214Form> = ICS214Form.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: true)
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
        ics214 = fetchedObjects
        return ics214
    }
    
    func getOneUserAttendeeRandomAndAddToPersonnel(){
        
    }
    
    func getAnICS214Form() -> [ICS214Form] {
        var form = [ICS214Form]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form")
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K == %@","ics214IncidentName", "Young blond")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 1
        fetchRequest.returnsObjectsAsFaults = false
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let forms = try sut.fetch(fetchRequest) as! [ICS214Form]
            if !forms.isEmpty {
                if let f = forms.last {
                    form.append(f)
                }
            }
        }  catch {
            let nserror = error as NSError
            let errorMessage = "NewICS214Resources getTheAttendees line 81 Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        
        return form
    }
    
    func getAllOfTheUserAttendees() ->[UserAttendees] {
        var crew = [UserAttendees]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees")
        fetchRequest.fetchBatchSize = 20
        let sectionSortDescriptor = NSSortDescriptor(key: "attendee", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let attend = try sut.fetch(fetchRequest) as! [UserAttendees]
            if !attend.isEmpty {
                if let c = attend.randomElement() {
                    crew.append(c)
                }
            }
            
        }  catch {
            let nserror = error as NSError
            let errorMessage = "NewICS214Resources getTheAttendees line 81 Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        return crew
    }
    
    func createNewPersonnel(formGuid: String, crewGuid: String) ->ICS214Personnel {
        let fjuICS214Personnel = ICS214Personnel.init(entity: NSEntityDescription.entity(forEntityName: "ICS214Personnel", in: sut)!, insertInto: sut)
                       fjuICS214Personnel.ics214Guid = formGuid
                       var uuidA:String = NSUUID().uuidString.lowercased()
                       let dateFormatter = DateFormatter()
                       dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
                       let resourceDate = Date()
                       let dateFrom = dateFormatter.string(from: resourceDate)
                       uuidA = uuidA+dateFrom
                       let uuidA1 = "80."+uuidA
                       fjuICS214Personnel.ics214PersonelGuid = uuidA1
                       fjuICS214Personnel.userAttendeeGuid = crewGuid
        return fjuICS214Personnel
    }
    
    func saveTheCD() {
        do {
            try sut.save()
            print("NewICS214DetailTVC personnel saved yeah!")
        } catch let error as NSError {
            print("NewICS214DetailTVC line 356 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func buildAPersonnelEntry() -> [ICS214Personnel] {
        let crews = getAllOfTheUserAttendees()
        let forms = getAnICS214Form()
        let crew = crews.last
        form = forms.last
        if let guid = crew?.attendeeGuid {
            crewGuid = guid
        }
        if let fguid = form?.ics214Guid {
            formGuid = fguid
        }
        print(form as Any)
        let personnel = form?.ics214PersonneDetail as! Set<ICS214Personnel>
         let result = personnel.filter { $0.userAttendeeGuid == crewGuid }
         return Array(result)
    }
    
    func getAllARCFormLocationsNotNull() -> [ARCrossForm] {
        var array = [ARCrossForm]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != nil", "arcLocation")
        let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 20
        do {
            let fetched = try sut.fetch(fetchRequest) as! [ARCrossForm]
            if !fetched.isEmpty {
                array = fetched
            }
        } catch let error as NSError {
            print("IncidentTVC line 1132 Fetch Error: \(error.localizedDescription)")
        }
        return array
    }
    
    func deadTestGetAllARCFormsWithLocation() {
        let result = getAllARCFormLocationsNotNull()
        if !result.isEmpty {
            print(result.count)
            XCTAssertNotNil(result)
        }
    }
    
    func deadTestGetAnCrewAddAsPersonnelToICS214() {
        let result = buildAPersonnelEntry()
        if result.isEmpty {
            print(result)
            let crewAdded = createNewPersonnel(formGuid: formGuid, crewGuid: crewGuid)
            form.addToIcs214PersonneDetail(crewAdded)
            saveTheCD()
            XCTAssertNotNil(form)
        }
    }
    
    func deadTestGetICS214FormWithCrew() {
        let forms = getTheICS214()
        var personnel = [ICS214Personnel]()
        //        for form in forms {
        if let form = forms.last {
            print(form.ics214IncidentName)
            if let guid = form.ics214Guid {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Personnel")
                var predicate = NSPredicate.init()
                predicate = NSPredicate(format: "%K = %@","ics214Guid", guid)
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                fetchRequest.predicate = predicateCan
                fetchRequest.fetchBatchSize = 20
                fetchRequest.returnsObjectsAsFaults = false
                let sectionSortDescriptor = NSSortDescriptor(key: "ics214Guid", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                do {
                    let persons = try sut.fetch(fetchRequest) as! [ICS214Personnel]
                    if !persons.isEmpty {
                        personnel.append(contentsOf: persons)
                    }
                }  catch {
                    let nserror = error as NSError
                    let errorMessage = "NewICS214Resources getTheAttendees line 81 Unresolved error \(nserror), \(nserror.userInfo)"
                    print(errorMessage)
                }
                
            }
        }
        print(personnel)
        XCTAssertNotNil(personnel)
    }
}
