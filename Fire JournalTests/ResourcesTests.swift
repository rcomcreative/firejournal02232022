//
//  ResourcesTests.swift
//  Fire JournalTests
//
//  Created by DuRand Jones on 1/20/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import XCTest
import UIKit
import Foundation
import MapKit
import CoreLocation
import CoreData
@testable import Fire_Journal

class ResourcesTests: XCTestCase {

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
    var resources = [String]()
    
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
    
    func fetchTheUserResources()->Array<UserResources> {
        var userResourcesArray = [UserResources]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources" )
        let sectionSortDescriptor = NSSortDescriptor(key: "resource", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            userResourcesArray = (try sut.fetch(fetchRequest) as? [UserResources])!
            print("here is the userResourcesArray.count  \(userResourcesArray.count)")
        } catch {
        }
        
        XCTAssertNotNil(userResourcesArray, "array not empty")
        return userResourcesArray
    }
    
    func testDuplicateResources() {
        let userResourceArray = fetchTheUserResources()
               for resource in userResourceArray {
                let r = resource.resource
                    if r != "" {
                        resources.append(r!)
                    }
               }
        resources = resources.map { $0.uppercased() }
        var resourceSet = Array(Set(resources))
        resourceSet = resourceSet.sorted{ $0 < $1 }
        
        print("here is resources count \(resourceSet.count)")
        print("here is resources \(resourceSet)")
               XCTAssertNotNil(resourceSet)
    }
    
    func testCaptureDuplicates() {
        let userResourceArray = fetchTheUserResources()
        for resource in userResourceArray {
                       let r = resource.resource
                           if r != "" {
                               resources.append(r!)
                           }
                      }
               resources = resources.map { $0.uppercased() }
               var resourceSet = Array(Set(resources))
               resourceSet = resourceSet.sorted{ $0 < $1 }
        var array = [UserResources]()
        var sArray = [String]()
        for resource in resourceSet {
            let result = userResourceArray.filter { $0.resource == resource }
            if result.count > 1 {
                for r in result {
                    array.append(r)
                    sArray.append(r.resource!)
                }
            }
        }
        var resourceS = Array(Set(sArray))
       print("here is the resourceS.count \(resourceS.count)")
        var userResourcesToDelete = [UserResources]()
        for r in resourceS {
            let result = array.filter { $0.resource == r }
            let resource1 = result.first
            let resultSet = result.filter { $0 != resource1 }
            userResourcesToDelete.append(contentsOf: resultSet)
            print("here is the resultSet \(resultSet.count)")
        }
        print("here is the result.count \(array.count)")
        XCTAssertNotNil(array)
    }
}
