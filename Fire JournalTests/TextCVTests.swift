//
//  TextCVTests.swift
//  Fire JournalTests
//
//  Created by DuRand Jones on 8/3/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import XCTest
import UIKit
import Foundation
import MapKit
import CoreLocation
import CoreData
@testable import Fire_Journal

class TextCVTests: XCTestCase {
    
    var sut: TestViewController!
    var testArray: Array<String>!
    private var rootWindow: UIWindow!

    override func setUp() {
        super.setUp()
//        rootWindow = UIWindow(frame: UIScreen.main.bounds)
//        rootWindow.isHidden = false
//
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let controller:TestViewController = storyboard.instantiateViewController(withIdentifier: "TestViewController") as! TestViewController
//         sut = controller
//
//        _ = sut.view // To call viewDidLoad
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc: TestViewController = storyboard.instantiateViewController(withIdentifier: "TestViewController") as! TestViewController
//        sut = vc
//        _ = sut.view // To call viewDidLoad
//
////        load view hiarchy
////        _ = sut.view
        testArray = ["AC1","AC2","AC3","BC1","bC2","BC3","BIKE1","BIKE2","BOAT1","BOAT2"]
        
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func deadTestSUT_canInstantiateViewController() {
        XCTAssertNotNil(sut)
    }
    
    func testSUT_testArrayCountIs10() {
        if testArray.count == 10 {
            XCTAssertTrue(true)
        } else {
            XCTAssertTrue(false)
        }
    }
    

}
