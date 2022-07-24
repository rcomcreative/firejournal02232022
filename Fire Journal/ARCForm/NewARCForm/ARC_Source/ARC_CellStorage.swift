//
//  ARC_CellStorage.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 8/27/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import Foundation
import CoreData

protocol ARC_CellStorage: AnyObject {
    //    MARK: - CELL type - FormType
    var type: ARC_CellType { get }
    //    MARK: - Cell Tag Int
    var tag: Int { get set }
}

enum ARC_CellType: String{
    case FJkHeadCell = "FJkHeadCell"
    case FJkAddressCell = "FJkAddressCell"
    case FJkTextViewCell = "FJkTextViewCell"
    case FJkARC_DateTimeAdminCell = "FJkARC_DateTimeAdminCell"
    case FJkARC_LabelCell = "FJkARC_LabelCell"
    case FJkLabelExtendedCell = "FJkLabelExtendedCell"
    case FJkARC_LabelTextViewCell = "FJkARC_LabelTextViewCell"
    case FJkLabelExtendedTextField = "FJkLabelExtendedTextField"
    case FJkARC_MapViewCell = "FJkARC_MapViewCell"
    case FJkDatePickerCell = "FJkDatePickerCell"
    case FJkDateTimeCell = "FJkDateTimeCell"
    case FJkLabelTextFieldCell = "FJkLabelTextFieldCell"
    case FJkSignatureCell = "FJkSignatureCell"
    case FJkARC_ParagraphCell = "FJkARC_ParagraphCell"
    case FJkARC_QuestionWSwitchCell = "FJkARC_QuestionWSwitchCell"
    case FJkARC_StepperTFCell = "FJkARC_StepperTFCell"
    case FJKARC_AdminSegmentCell = "FJKARC_AdminSegmentCell"
    case FJkARC_TwoButtonCell = "FJkARC_TwoButtonCell"
    case FJkARC_CampaignNameCell = "FJkARC_CampaignNameCell"
    case FJkARC_ChooseACampaignCell = "FJkARC_ChooseACampaignCell"
    case FJkARC_CampaignCell = "FJkARC_CampaignCell"
    case FJkARC_CampaignResidenceTypeCell = "FJkARC_CampaignResidenceTypeCell"
}


/// Build the Cell classes for the campaign view
class ARCCampaign0: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_ParagraphCell
    var tag = 0
}

class ARCCampaign1: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_TwoButtonCell
    var tag = 1
}

class ARCCampaign2: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_CampaignNameCell
    var tag = 2
}

class ARCCampaign3: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_ChooseACampaignCell
    var tag = 3
}

class ARCCampaign4: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_CampaignCell
    var tag = 4
    var objectID: NSManagedObjectID!
    var address: String!
    var date: String!
    var name: String!
    var masterGuid: String!
}

// Create ARC_CellStorage Array to hold the cell structure for the the campaign view
class NewARC_CampaignCells: NSObject {
    var cells = [ARC_CellStorage]()
    override init() {
        super.init()
        let cell0 = ARCCampaign0()
        cells.append(cell0)
        let cell1 = ARCCampaign1()
        cells.append(cell1)
        let cell2 = ARCCampaign2()
        cells.append(cell2)
        let cell3 = ARCCampaign3()
        cells.append(cell3)
    }
}


/// Build the cells for the form
class ARCCell0: ARC_CellStorage {
    var type = ARC_CellType.FJkHeadCell
    var tag = 0
}

class ARCCell1: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_CampaignResidenceTypeCell
    var tag = 1
}

class ARCCell2: ARC_CellStorage {
    var type = ARC_CellType.FJkAddressCell
    var tag = 2
}

class ARCCell3: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_MapViewCell
    var tag = 3
}

class ARCCell4: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_LabelCell
    var tag = 4
}

class ARCCell5: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_StepperTFCell
    var tag = 5
}

class ARCCell6: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_StepperTFCell
    var tag = 6
}

class ARCCell7: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_StepperTFCell
    var tag = 7
}

class ARCCell8: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_LabelCell
    var tag = 8
}

class ARCCell9: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_StepperTFCell
    var tag = 9
}

class ARCCell10: ARC_CellStorage {
    var type = ARC_CellType.FJkLabelExtendedCell
    var tag = 10
}

class ARCCell11: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_QuestionWSwitchCell
    var tag = 11
}

class ARCCell12: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_QuestionWSwitchCell
    var tag = 12
}

class ARCCell13: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_QuestionWSwitchCell
    var tag = 13
}

class ARCCell14: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_QuestionWSwitchCell
    var tag = 14
}

class ARCCell15: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_QuestionWSwitchCell
    var tag = 15
}

class ARCCell16: ARC_CellStorage {
    var type = ARC_CellType.FJkTextViewCell
    var tag = 16
}

class ARCCell17: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_LabelTextViewCell
    var tag = 17
}

class ARCCell18: ARC_CellStorage {
    var type = ARC_CellType.FJkLabelTextFieldCell
    var tag = 18
}

class ARCCell19: ARC_CellStorage {
    var type = ARC_CellType.FJkSignatureCell
    var tag = 19
}

class ARCCell20: ARC_CellStorage {
    var type = ARC_CellType.FJkDateTimeCell
    var tag = 20
}

class ARCCell21: ARC_CellStorage {
    var type = ARC_CellType.FJkDatePickerCell
    var tag = 21
}

class ARCCell22: ARC_CellStorage {
    var type = ARC_CellType.FJkLabelTextFieldCell
    var tag = 22
}

class ARCCell23: ARC_CellStorage {
    var type = ARC_CellType.FJkSignatureCell
    var tag = 23
}

class ARCCell24: ARC_CellStorage {
    var type = ARC_CellType.FJkDateTimeCell
    var tag = 24
}

class ARCCell25: ARC_CellStorage {
    var type = ARC_CellType.FJkDatePickerCell
    var tag = 25
}

class ARCCell26: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_LabelCell
    var tag = 26
}

class ARCCell27: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_StepperTFCell
    var tag = 27
}

class ARCCell28: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_StepperTFCell
    var tag = 28
}

class ARCCell29: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_StepperTFCell
    var tag = 29
}

class ARCCell30: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_StepperTFCell
    var tag = 30
}

class ARCCell31: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_StepperTFCell
    var tag = 31
}

class ARCCell32: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_StepperTFCell
    var tag = 32
}

class ARCCell33: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_StepperTFCell
    var tag = 33
}

class ARCCell34: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_StepperTFCell
    var tag = 34
}

class ARCCell35: ARC_CellStorage {
    var type = ARC_CellType.FJkTextViewCell
    var tag = 35
}

class ARCCell36: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_LabelCell
    var tag = 36
}

class ARCCell37: ARC_CellStorage {
    var type = ARC_CellType.FJkLabelTextFieldCell
    var tag = 37
}

class ARCCell38: ARC_CellStorage {
    var type = ARC_CellType.FJkLabelTextFieldCell
    var tag = 38
}

class ARCCell39: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_LabelCell
    var tag = 39
}

class ARCCell40: ARC_CellStorage {
    var type = ARC_CellType.FJkLabelTextFieldCell
    var tag = 40
}

class ARCCell41: ARC_CellStorage {
    var type = ARC_CellType.FJkLabelTextFieldCell
    var tag = 41
}

class ARCCell42: ARC_CellStorage {
    var type = ARC_CellType.FJkLabelExtendedCell
    var tag = 42
}

class ARCCell43: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_QuestionWSwitchCell
    var tag = 43
}

class ARCCell44: ARC_CellStorage {
    var type = ARC_CellType.FJkLabelTextFieldCell
    var tag = 44
}

class ARCCell45: ARC_CellStorage {
    var type = ARC_CellType.FJkLabelTextFieldCell
    var tag = 45
}

class ARCCell46: ARC_CellStorage {
    var type = ARC_CellType.FJkLabelTextFieldCell
    var tag = 46
}

class ARCCell47: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_LabelTextViewCell
    var tag = 47
}

class ARCCell48: ARC_CellStorage {
    var type = ARC_CellType.FJkLabelExtendedTextField
    var tag = 48
}

class ARCCell49: ARC_CellStorage {
    var type = ARC_CellType.FJkARC_DateTimeAdminCell
    var tag = 49
}

class ARCCell50: ARC_CellStorage {
    var type = ARC_CellType.FJkDatePickerCell
    var tag = 50
}

class ARCCell51: ARC_CellStorage {
    var type = ARC_CellType.FJKARC_AdminSegmentCell
    var tag = 51
}

/// Create ARC_CellStorage Array to hold the cell structure for the form
class NewCells: NSObject {
    var cells = [ARC_CellStorage]()
    override init() {
        super.init()
        let cell0 = ARCCell0()
        cells.append(cell0)
        let cell1 = ARCCell1()
        cells.append(cell1)
        let cell2 = ARCCell2()
        cells.append(cell2)
        let cell3 = ARCCell3()
        cells.append(cell3)
        let cell4 = ARCCell4()
        cells.append(cell4)
        let cell5 = ARCCell5()
        cells.append(cell5)
        let cell6 = ARCCell6()
        cells.append(cell6)
        let cell7 = ARCCell7()
        cells.append(cell7)
        let cell8 = ARCCell8()
        cells.append(cell8)
        let cell9 = ARCCell9()
        cells.append(cell9)
        let cell10 = ARCCell10()
        cells.append(cell10)
        let cell11 = ARCCell11()
        cells.append(cell11)
        let cell12 = ARCCell12()
        cells.append(cell12)
        let cell13 = ARCCell13()
        cells.append(cell13)
        let cell14 = ARCCell14()
        cells.append(cell14)
        let cell15 = ARCCell15()
        cells.append(cell15)
        let cell16 = ARCCell16()
        cells.append(cell16)
        let cell17 = ARCCell17()
        cells.append(cell17)
        let cell18 = ARCCell18()
        cells.append(cell18)
        let cell19 = ARCCell19()
        cells.append(cell19)
        let cell20 = ARCCell20()
        cells.append(cell20)
        let cell21 = ARCCell21()
        cells.append(cell21)
        let cell22 = ARCCell22()
        cells.append(cell22)
        let cell23 = ARCCell23()
        cells.append(cell23)
        let cell24 = ARCCell24()
        cells.append(cell24)
        let cell25 = ARCCell25()
        cells.append(cell25)
        let cell26 = ARCCell26()
        cells.append(cell26)
        let cell27 = ARCCell27()
        cells.append(cell27)
        let cell28 = ARCCell28()
        cells.append(cell28)
        let cell29 = ARCCell29()
        cells.append(cell29)
        let cell30 = ARCCell30()
        cells.append(cell30)
        let cell31 = ARCCell31()
        cells.append(cell31)
        let cell32 = ARCCell32()
        cells.append(cell32)
        let cell33 = ARCCell33()
        cells.append(cell33)
        let cell34 = ARCCell34()
        cells.append(cell34)
        let cell35 = ARCCell35()
        cells.append(cell35)
        let cell36 = ARCCell36()
        cells.append(cell36)
        let cell37 = ARCCell37()
        cells.append(cell37)
        let cell38 = ARCCell38()
        cells.append(cell38)
        let cell39 = ARCCell39()
        cells.append(cell39)
        let cell40 = ARCCell40()
        cells.append(cell40)
        let cell41 = ARCCell41()
        cells.append(cell41)
        let cell42 = ARCCell42()
        cells.append(cell42)
        let cell43 = ARCCell43()
        cells.append(cell43)
        let cell44 = ARCCell44()
        cells.append(cell44)
        let cell45 = ARCCell45()
        cells.append(cell45)
        let cell46 = ARCCell46()
        cells.append(cell46)
        let cell47 = ARCCell47()
        cells.append(cell47)
        let cell48 = ARCCell48()
        cells.append(cell48)
        let cell49 = ARCCell49()
        cells.append(cell49)
        let cell50 = ARCCell50()
        cells.append(cell50)
        let cell51 = ARCCell51()
        cells.append(cell51)
    }
}
