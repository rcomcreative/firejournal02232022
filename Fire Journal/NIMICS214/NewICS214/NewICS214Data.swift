//
//  NewICS214Data.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/30/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import CoreData

protocol NewICS214CellStorage: AnyObject {
    //    MARK: - CELL type - FormType
    var type: NewICS214Type { get }
    //    MARK: - Cell Tag Int
    var tag: Int { get set }
    var arrayPosition: Int { get set}
}

enum NewICS214Type: String{
    case FJkHeadCell = "FJkHeadCell"
    case FJkDateTimeCell = "FJkDateTimeCell"
    case FJkSignatureCell = "FJkSignatureCell"
    case FJkResourceAssignCell = "FJkResourceAssignCell"
    case FJkResourceAssignedCell = "FJkResourceAssignedCell"
    case FJkNewActivityLogCell = "FJkNewActivityLogCell"
    case FJkCompletedActivityLogCell = "FJkCompletedActivityLogCell"
    case FJkNewICS214LabelTextFieldCell = "FJkNewICS214LabelTextFieldCell"
    case FJkDatePickerCell = "FJkDatePickerCell"
    case FJkDatePickerCell2 = "FJkDatePickerCell2"
    case FJkDatePickerCell3 = "FJkDatePickerCell3"
    case FJkDatePickerCell4 = "FJkDatePickerCell4"
    case FJkLabelCell = "FJkLabelCell"
}

class NewICS214Cell0: NewICS214CellStorage {
    var type = NewICS214Type.FJkHeadCell
    var tag = 0
    var arrayPosition = 0
}

class NewICS214Cell1: NewICS214CellStorage {
    var type = NewICS214Type.FJkNewICS214LabelTextFieldCell
    var tag = 1
    var arrayPosition = 0
}

class NewICS214Cell2: NewICS214CellStorage {
    var type = NewICS214Type.FJkLabelCell
    var tag = 2
    var arrayPosition = 0
}

class NewICS214Cell3: NewICS214CellStorage {
    var type = NewICS214Type.FJkDateTimeCell
    var tag = 3
    var arrayPosition = 0
}

class NewICS214Cell4: NewICS214CellStorage {
    var type = NewICS214Type.FJkDatePickerCell
    var tag = 4
    var arrayPosition = 0
}

class NewICS214Cell5: NewICS214CellStorage {
    var type = NewICS214Type.FJkDateTimeCell
    var tag = 5
    var arrayPosition = 0
}

class NewICS214Cell6: NewICS214CellStorage {
    var type = NewICS214Type.FJkDatePickerCell2
    var tag = 6
    var arrayPosition = 0
}

class NewICS214Cell7: NewICS214CellStorage {
    var type = NewICS214Type.FJkNewICS214LabelTextFieldCell
    var tag = 7
    var arrayPosition = 0
}

class NewICS214Cell8: NewICS214CellStorage {
    var type = NewICS214Type.FJkNewICS214LabelTextFieldCell
    var tag = 8
    var arrayPosition = 0
}

class NewICS214Cell9: NewICS214CellStorage {
    var type = NewICS214Type.FJkNewICS214LabelTextFieldCell
    var tag = 9
    var arrayPosition = 0
}

class NewICS214Cell10: NewICS214CellStorage {
    var type = NewICS214Type.FJkLabelCell
    var tag = 10
    var arrayPosition = 0
}

class NewICS214Cell11: NewICS214CellStorage {
    var type = NewICS214Type.FJkResourceAssignCell
    var tag = 11
    var arrayPosition = 0
}

class NewICS214Cell12: NewICS214CellStorage {
    var type = NewICS214Type.FJkLabelCell
    var tag = 12
    var arrayPosition = 0
}

class NewICS214Cell13: NewICS214CellStorage {
    var type = NewICS214Type.FJkNewActivityLogCell
    var tag = 13
    var arrayPosition = 0
}

class NewICS214Cell14: NewICS214CellStorage {
    var type = NewICS214Type.FJkDatePickerCell3
    var tag = 14
    var arrayPosition = 0
}

class NewICS214Cell15: NewICS214CellStorage {
    var type = NewICS214Type.FJkLabelCell
    var tag = 15
    var arrayPosition = 0
}

class NewICS214Cell16: NewICS214CellStorage {
    var type = NewICS214Type.FJkNewICS214LabelTextFieldCell
    var tag = 16
    var arrayPosition = 0
}

class NewICS214Cell17: NewICS214CellStorage {
    var type = NewICS214Type.FJkNewICS214LabelTextFieldCell
    var tag = 17
    var arrayPosition = 0
}

class NewICS214Cell18: NewICS214CellStorage {
    var type = NewICS214Type.FJkNewICS214LabelTextFieldCell
    var tag = 18
    var arrayPosition = 0
}

class NewICS214Cell19: NewICS214CellStorage {
    var type = NewICS214Type.FJkDatePickerCell4
    var tag = 19
    var arrayPosition = 0
}

class NewICS214Cell20: NewICS214CellStorage {
    var type = NewICS214Type.FJkSignatureCell
    var tag = 20
    var arrayPosition = 0
}

class NewICS214CellResourceAssigned: NewICS214CellStorage {
    var type = NewICS214Type.FJkResourceAssignedCell
    var tag = 21
    var arrayPosition = 0
}

class NewICS214CellCompletedLog: NewICS214CellStorage {
    var type = NewICS214Type.FJkCompletedActivityLogCell
    var tag = 22
    var arrayPosition = 0
}

class NewICS214CrewMember {
    var name: String = ""
    var email: String = ""
    var phone: String = ""
    var icsPostion: String = ""
    var homeAgency: String = ""
    var objectID: NSManagedObjectID = NSManagedObjectID()
}


class NewICS214Cells: NSObject {
    var cells = [NewICS214CellStorage]()
    override init() {
        super.init()
        let cell0 = NewICS214Cell0()
        cells.append(cell0)
        let cell1 = NewICS214Cell1()
        cells.append(cell1)
        let cell2 = NewICS214Cell2()
        cells.append(cell2)
        let cell3 = NewICS214Cell3()
        cells.append(cell3)
        let cell4 = NewICS214Cell4()
        cells.append(cell4)
        let cell5 = NewICS214Cell5()
        cells.append(cell5)
        let cell6 = NewICS214Cell6()
        cells.append(cell6)
        let cell7 = NewICS214Cell7()
        cells.append(cell7)
        let cell8 = NewICS214Cell8()
        cells.append(cell8)
        let cell9 = NewICS214Cell9()
        cells.append(cell9)
        let cell10 = NewICS214Cell10()
        cells.append(cell10)
        let cell11 = NewICS214Cell11()
        cells.append(cell11)
        let cell12 = NewICS214Cell12()
        cells.append(cell12)
        let cell13 = NewICS214Cell13()
        cells.append(cell13)
        let cell14 = NewICS214Cell14()
        cells.append(cell14)
        let cell15 = NewICS214Cell15()
        cells.append(cell15)
        let cell16 = NewICS214Cell16()
        cells.append(cell16)
        let cell17 = NewICS214Cell17()
        cells.append(cell17)
        let cell18 = NewICS214Cell18()
        cells.append(cell18)
        let cell19 = NewICS214Cell19()
        cells.append(cell19)
        let cell20 = NewICS214Cell20()
        cells.append(cell20)
    }
}
