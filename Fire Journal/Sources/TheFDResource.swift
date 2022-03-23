//
//  TheFDResource.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/30/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class TheFDResource {
    var fdResourceGuid: String = ""
    var fdResource: String
    var fdResourceDate: Date
    
    init(fdResource: String, fdResourceDate: Date) {
        self.fdResource = fdResource
        self.fdResourceDate = fdResourceDate
    }
    
    func createFDResourceGuid() ->String {
        let fdResourceDate = GuidFormatter.init(date:self.fdResourceDate)
        let fdResourceGuid: String = fdResourceDate.formatGuid()
        self.fdResourceGuid = "91."+fdResourceGuid
        return self.fdResourceGuid
    }
}
