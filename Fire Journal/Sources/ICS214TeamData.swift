//
//  ICS214TeamData.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/29/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import CoreData
import Contacts
import ContactsUI
import T1Autograph
import MapKit
import CoreLocation

class ICS214TeamCell0:  CellStorage {
    
    var tag = 0
    
    var type: FormType = FormType.modalHeader
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
}

class ICS214TeamCell1:  CellStorage {
    
    var tag = 1
    
    var type: FormType = FormType.contactsCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var field1: String = "Name:"
    
    var field2: String = "ICS Postion"
    
    var field3: String = "Home Agency"
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
    var valueType1: ValueType {
        return ValueType.fjKTeamMember
    }
    
    var valueType2: ValueType {
        return ValueType.fjKTeamICSPosition
    }
    
    var valueType3: ValueType {
        return ValueType.fjKTeamHomeAgency
    }
    
}

class ICS214TeamCell2:  CellStorage {
    
    var tag = 2
    
    var type: FormType = FormType.addButtonCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var field1: String = "Name:"
    
    var field2: String = "ICS Position:"
    
    var field3: String = "Home Agency"
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
    var valueType1: ValueType {
        return ValueType.fjKTeamMember
    }
    
    var valueType2: ValueType {
        return ValueType.fjKTeamICSPosition
    }
    
    var valueType3: ValueType {
        return ValueType.fjKTeamHomeAgency
    }
    
}

class ICS214TeamCell3:  CellStorage {
    
    var tag = 3
    
    var type: FormType = FormType.noSelectCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
    var valueType1: ValueType {
        return ValueType.fjKTeamMember
    }
    
    var valueType2: ValueType {
        return ValueType.fjKTeamICSPosition
    }
    
    var valueType3: ValueType {
        return ValueType.fjKTeamHomeAgency
    }
    
}

class TeamCellAttributes: NSObject {
    var teamCells = [CellStorage]()
    
    override init() {
        super.init()
        let emptyString: String = ""
        let date = Date()
        let obID = NSManagedObjectID()
        let cell00 = ICS214TeamCell0.init(header: emptyString, date: date, id:obID)
        teamCells.append(cell00)
        let headerString: String = "Tap the button next to Name to add contacts from your contacts or add a name, ICS\nPosition and Home Agency"
        let cell01 = ICS214TeamCell1.init(header: headerString, date: date, id: obID)
        teamCells.append(cell01)
    }
}
