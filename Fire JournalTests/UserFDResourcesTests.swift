//
//  UserFDResourcesTests.swift
//  Fire JournalTests
//
//  Created by DuRand Jones on 7/19/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import XCTest
@testable import Fire_Journal

class UserFDResourcesTests: XCTestCase {
    
    var sut: Array<String>!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = theFDResources.allCases.map{ $0.rawValue }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStringInTheFDResource() {
        let resource = "AC1"
        
        let result = sut.filter { $0 == resource}
        XCTAssert(!result.isEmpty, "result is empty")
    }

}
