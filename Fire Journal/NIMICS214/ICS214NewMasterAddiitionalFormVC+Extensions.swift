    //
    //  ICS214NewMasterAddiitionalFormVC+Extensions.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 8/3/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

public enum NewMasterSections: Int {
    case section1
    case section2
    case section3
}

extension ICS214NewMasterAddiitionalFormVC {
    
    func addObservers() {
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
    func buildCellParts() -> [CellParts] {
        let cellParts = [CellParts]()
        p0 = CellParts.init(cellAttributes: ["Header": ""], type: ["Type": FormType.modalHeader], vType: ["Value1":ValueType.fjKEmpty], dType: ["Date": Date() ], objID: ["objectID": nil])
        modalCells.append(p0)
        p1 = CellParts.init(cellAttributes: ["Header": ""], type: ["Type": FormType.paragraphCell], vType: ["Value1":ValueType.fjKEmpty], dType: ["Date": Date() ], objID: ["objectID": nil])
        modalCells.append(p1)
        p2 = CellParts.init(cellAttributes: ["Header": ""], type: ["Type": FormType.formSegmentCell], vType: ["Value1":ValueType.fjKEmpty], dType: ["Date": Date() ], objID: ["objectID": nil])
        modalCells.append(p2)
        p3 = CellParts.init(cellAttributes: ["Header": ""], type: ["Type": FormType.fourSwitchCell], vType: ["Value1":ValueType.fjKEmpty], dType: ["Date": Date() ], objID: ["objectID": nil])
        modalCells.append(p3)
        p4 = CellParts.init(cellAttributes: ["Header": ""], type: ["Type": FormType.efforWithDateCell], vType: ["Value1":ValueType.fjKEmpty], dType: ["Date": Date() ], objID: ["objectID": nil])
        modalCells.append(p4)
        return cellParts
    }
    
    func getTheLastMaster() {
        theICS214ProviderContext = theICS214Provider.persistentContainer.newBackgroundContext()
        guard let result = theICS214Provider.getTheInCompleteMasterICS214(theICS214ProviderContext) else {
            type = TypeOfForm.incidentForm
            return
        }
        if !result.isEmpty {
            let form = result.last
            if let theType = form?.ics214Effort {
                type = theICS214Provider.determineICS214TypeFromString(theType: theType)
            }
        }
    }
    
    func configureModalHeaderSaveDismiss() {
        ics214ModalHeaderV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as? ModalHeaderSaveDismiss
        ics214ModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(ics214ModalHeaderV)
        ics214ModalHeaderV.modalHTitleL.textColor = UIColor.white
        ics214ModalHeaderV.modalHCancelB.setTitle("Cancel",for: .normal)
        ics214ModalHeaderV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        ics214ModalHeaderV.modalHSaveB.setTitle("Save",for: .normal)
        ics214ModalHeaderV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        ics214ModalHeaderV.modalHSaveB.isEnabled = false
        ics214ModalHeaderV.modalHSaveB.isHidden = true
        ics214ModalHeaderV.modalHSaveB.alpha = 0.0
        ics214ModalHeaderV.modalHTitleL.text = headerTitle
        ics214ModalHeaderV.infoB.setTitle("", for: .normal)
        if let color = UIColor(named: "FJIconRed") {
            ics214ModalHeaderV.contentView.backgroundColor = color
        }
        ics214ModalHeaderV.myShift = MenuItems.incidents
        ics214ModalHeaderV.delegate = self
        
        NSLayoutConstraint.activate([
            ics214ModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            ics214ModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            ics214ModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            ics214ModalHeaderV.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configureics214TableView() {
        ics214TableView = UITableView(frame: .zero)
        registerCellsForTable()
        ics214TableView.translatesAutoresizingMaskIntoConstraints = false
        ics214TableView.backgroundColor = .systemBackground
        view.addSubview(ics214TableView)
        ics214TableView.delegate = self
        ics214TableView.dataSource = self
        ics214TableView.separatorStyle = .none
        ics214TableView.allowsSelection = true
        
        
        ics214TableView.rowHeight = UITableView.automaticDimension
        ics214TableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            ics214TableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            ics214TableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            ics214TableView.topAnchor.constraint(equalTo: ics214ModalHeaderV.bottomAnchor, constant: 5),
            ics214TableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }
    
}

extension ICS214NewMasterAddiitionalFormVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        ics214TableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        ics214TableView.register(UINib(nibName: "ModalHeaderCell", bundle: nil), forCellReuseIdentifier: "ModalHeaderCell")
        ics214TableView.register(UINib(nibName: "ParagraphCell", bundle: nil), forCellReuseIdentifier: "ParagraphCell")
        ics214TableView.register(UINib(nibName: "FormSegmentCell", bundle: nil), forCellReuseIdentifier: "FormSegmentCell")
        ics214TableView.register(UINib(nibName: "FourSwitchCell", bundle: nil), forCellReuseIdentifier: "FourSwitchCell")
        ics214TableView.register(UINib(nibName: "EffortWithDateCell", bundle: nil), forCellReuseIdentifier: "EffortWithDateCell")
        ics214TableView.register(UINib(nibName: "IncidentMasterCell", bundle: nil), forCellReuseIdentifier: "IncidentMasterCell")
        ics214TableView.register(UINib(nibName: "JournalMasterCell", bundle: nil), forCellReuseIdentifier: "JournalMasterCell")
    }
    
    func configureModalHeaderCell(_ cell: ModalHeaderCell, index: IndexPath) -> ModalHeaderCell {
        cell.tag = index.row
        cell.descriptionText = "ACTIVITY LOG (ICS 214)"
        cell.selectionStyle = .none
        return cell
    }
    
    func configureParagraphCell(_ cell: ParagraphCell, index: IndexPath) -> ParagraphCell {
        cell.header1Text = InfoBodyText.ics214ParagraphHeader1.rawValue
        cell.header2Text = InfoBodyText.ics214ParagraphHeader2.rawValue
        cell.header3Text = InfoBodyText.ics214ParagraphHeader3.rawValue
        cell.paragraph1Text = InfoBodyText.ics214Paragraph1.rawValue
        cell.paragraph2Text = InfoBodyText.ics214Paragraph2.rawValue
        cell.paragraph3Text = InfoBodyText.ics214Paragraph3.rawValue
        cell.tag = index.row
        cell.selectionStyle = .none
        return cell
    }
    
    func configureFormSegmentCell(_ cell: FormSegmentCell, index: IndexPath) -> FormSegmentCell {
        cell.delegate = self
        cell.tag = index.row
        cell.selectionStyle = .none
        return cell
    }
    
    func configureFourSwitchCell(_ cell: FourSwitchCell, index: IndexPath) -> FourSwitchCell {
        cell.delegate = self
        cell.selectionStyle = .none
        cell.masterOrMore = self.masterOrNot
        cell.localIncidentOn = false
        cell.femaTaksForceOn = false
        cell.strikeTeamOn = false
        cell.otherOn = false
        theICS214ProviderContext = theICS214Provider.persistentContainer.newBackgroundContext()
        getTheMasters()
        if self.masterOrNot {
            cell.instructionsText = InfoBodyText.ics214MasterInstructions.rawValue
            switch type {
            case .incidentForm:
                cell.localIncidentOn = true
                cell.setNeedsDisplay()
            case .femaTaskForceForm:
                cell.femaTaksForceOn = true
                cell.setNeedsDisplay()
            case .strikeForceForm:
                cell.strikeTeamOn = true
                cell.setNeedsDisplay()
            case .otherForm:
                cell.otherOn = true
                cell.setNeedsDisplay()
            }
        } else {
            cell.instructionsText = InfoBodyText.ics214AdditionalFormsInstructions.rawValue
            switch type {
            case .incidentForm:
                cell.localIncidentOn = true
                cell.setNeedsDisplay()
            case .femaTaskForceForm:
                cell.femaTaksForceOn = true
                cell.setNeedsDisplay()
            case .strikeForceForm:
                cell.strikeTeamOn = true
                cell.setNeedsDisplay()
            case .otherForm:
                cell.otherOn = true
                cell.setNeedsDisplay()
            }
        }
        return cell
    }
    
    func configureEffortWithDateCell(_ cell: EffortWithDateCell, index: IndexPath) -> EffortWithDateCell {
        cell.tag = index.row
        cell.selectionStyle = .none
        
        let theTypeOfEffort = userDefaults.string(forKey: FJkICS214TYPEOFFORM)
        
        if theTypeOfEffort == "incidentForm" {
            cell.type = TypeOfForm.incidentForm
        } else if theTypeOfEffort == "strikeForceForm" {
            cell.type = TypeOfForm.strikeForceForm
        } else if theTypeOfEffort == "femaTaskForceForm" {
            cell.type = TypeOfForm.femaTaskForceForm
        } else if theTypeOfEffort == "otherForm" {
            cell.type = TypeOfForm.otherForm
        }
        
        if masterOrNot {
            cell.instructionsText = InfoBodyText.ics214IncidentFormMasterInstructions.rawValue
            cell.newIncidentB.isHidden = false
            cell.newIncidentB.isEnabled = true
            cell.newIncidentB.alpha = 1.0
        } else {
            cell.instructionsText = InfoBodyText.ics214IncidentFormAdditionalInstructions.rawValue
            cell.newIncidentB.isHidden = true
            cell.newIncidentB.isEnabled = false
            cell.newIncidentB.alpha = 0.0
        }
        cell.delegate = self
        cell.setNeedsDisplay()
        return cell
    }
    
    func configureJournalMasterCell(_ cell: IncidentMasterCell, index: IndexPath) -> IncidentMasterCell {
        let theData = modalCells[index.row]
        cell.tag = index.row
        let objectID: NSManagedObjectID!
        let theTypeOfEffort = userDefaults.string(forKey: FJkICS214TYPEOFFORM)
        
        if theTypeOfEffort == "incidentForm" {
            cell.type = TypeOfForm.incidentForm
        } else if theTypeOfEffort == "strikeForceForm" {
            cell.type = TypeOfForm.strikeForceForm
        } else if theTypeOfEffort == "femaTaskForceForm" {
            cell.type = TypeOfForm.femaTaskForceForm
        } else if theTypeOfEffort == "otherForm" {
            cell.type = TypeOfForm.otherForm
        }
        
        if theData.objID["objectID"] != nil {
            objectID = theData.objID["objectID"] as? NSManagedObjectID
            cell.obID = objectID
            if let ics214 = context.object(with: objectID) as? ICS214Form {
                var theAddress: String = ""
                var imageName: String = ""
                var theEffortName: String = ""
                var effortFromDateTime: String = ""
                var theImage: UIImage!
                var theEffortType: String = ""
                switch cell.type {
                case .incidentForm:
                    imageName = "ICS_214_Form_LOCAL_INCIDENT"
                    theImage = UIImage(named: imageName)
                    theEffortType = "Local Incident"
                case .strikeForceForm:
                    imageName = "ICS214FormSTRIKETEAM"
                    theImage = UIImage(named: imageName)
                    theEffortType = "Strike Force Team"
                case .femaTaskForceForm:
                    imageName = "ICS214FormFEMA"
                    theImage = UIImage(named: imageName)
                    theEffortType = "FEMA Task Force Form"
                case .otherForm:
                    imageName = "ICS214FormOTHER"
                    theImage = UIImage(named: imageName)
                    theEffortType = "Other"
                default: break
                }
                if theImage != nil {
                    cell.incidentIV.image = theImage
                }
                if let effortName = ics214.ics214IncidentName {
                    theEffortName = effortName
                }
                if ics214.ics214IncidentInfo != nil {
                    if let incident = ics214.ics214IncidentInfo {
                        if incident.theLocation != nil {
                            if let theLocation = incident.theLocation {
                                if let number = theLocation.streetNumber {
                                    theAddress = number
                                }
                                if let street = theLocation.streetName {
                                    theAddress = theAddress + " " + street
                                }
                                if let city = theLocation.city {
                                    theAddress = theAddress + " " + city + ", "
                                }
                                if let state = theLocation.state {
                                    theAddress = theAddress + state + " "
                                }
                                if let zip = theLocation.zip {
                                    theAddress = theAddress + zip
                                }
                            }
                        }
                    }
                }
                if let effortFromTime = ics214.ics214FromTime {
                    effortFromDateTime = buildTheDate(effortFromTime)
                }
                if theAddress == "" {
                    cell.incidentAddressL.text = theEffortType
                } else {
                    cell.incidentAddressL.text = theAddress
                }
                cell.titleL.text = theEffortName
                cell.incidentTimeL.text = effortFromDateTime
            }
            
        }
        return cell
    }
    
    func configureIncidentMasterCell(_ cell: IncidentMasterCell, index: IndexPath) -> IncidentMasterCell {
        let theData = modalCells[index.row]
        cell.tag = index.row
        let objectID: NSManagedObjectID!
        if theData.objID["objectID"] != nil {
            objectID = theData.objID["objectID"] as? NSManagedObjectID
            cell.obID = objectID
            if let incident = context.object(with: objectID) as? Incident {
                var address: String = ""
                var imageName: String = ""
                var incidentNumber: String = ""
                var incidentTime: String = ""
                if incident.theLocation != nil {
                    if let theLocation = incident.theLocation {
                        if let number = theLocation.streetNumber {
                            address = number
                        }
                        if let street = theLocation.streetName {
                            address = address + " " + street
                        }
                        if let city = theLocation.city {
                            address = address + " " + city + ", "
                        }
                        if let state = theLocation.state {
                            address = address + state + " "
                        }
                        if let zip = theLocation.zip {
                            address = address + zip
                        }
                    }
                }
                if let theNumber = incident.incidentNumber {
                    incidentNumber = "Incident #" + theNumber
                }
                if let theImage = incident.situationIncidentImage {
                    if theImage == "Fire" {
                        imageName = "100515IconSet_092016_fireboard"
                    } else if theImage == "EMS" {
                        imageName = "100515IconSet_092016_emsboard"
                    } else if theImage == "Rescue" {
                        imageName = "100515IconSet_092016_rescueboard"
                    }
                } else {
                    imageName = "100515IconSet_092016_fireboard"
                }
                if let image = UIImage(named: imageName) {
                    cell.incidentIV.image = image
                }
                if incident.incidentTimerDetails != nil {
                    if let incidentTimer = incident.incidentTimerDetails {
                        if let alarmDate = incidentTimer.incidentAlarmDateTime {
                            incidentTime = buildTheDate(alarmDate)
                        }
                    }
                }
                cell.incidentAddressL.text = address
                cell.titleL.text = incidentNumber
                cell.incidentTimeL.text = incidentTime
            }
        }
        return cell
    }
    
    func buildTheDate(_ theDate: Date) -> String {
        let theComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: theDate)
        let m = theComponents.month!
        let y = theComponents.year!
        let d = theComponents.day!
        let h = theComponents.hour!
        let min = theComponents.minute!
        
        let month = m < 10 ? "0\(m)" : String(m)
        let day = d < 10 ? "0\(d)" : String(d)
        let year = String(y)
        let hour = String(h)
        let minute = String(min)
        
            //        let firstDay = "2020-05-27T23:59:00+0000"
        let firstDay = year + "/" + month + "/" + day + " " + hour + ":" + minute + "HR"
        return firstDay
    }
    
    func getTheMastersForEffort(type: TypeOfForm) -> [ICS214Form] {
        var masters = [ICS214Form]()
        theICS214ProviderContext = theICS214Provider.persistentContainer.newBackgroundContext()
        guard let mastersType = theICS214Provider.getTheMasterListICS214(theICS214ProviderContext, thetype: type) else {
            let errorMessage = "There is no incomplete master forms"
            self.errorAlert(errorMessage: errorMessage)
            return masters
        }
        
        var imageName: String = ""
        for ics214 in mastersType {
            imageName = theICS214Provider.determineTheICS214Image(type: type)
        }
        return masters
    }
    
    func getTheMasters() {
        theICS214ProviderContext = theICS214Provider.persistentContainer.newBackgroundContext()
        guard let masters = theICS214Provider.getTheInCompleteMasterICS214(theICS214ProviderContext) else {
            let errorMessage = "There is no incomplete master forms"
            self.errorAlert(errorMessage: errorMessage)
            return
        }
        
        if let aMaster = masters.last {
            if let effort = aMaster.ics214Effort {
                formMaster = effort
                if formMaster == TypeOfForm.incidentForm.rawValue {
                    type = TypeOfForm.incidentForm
                } else if effort == TypeOfForm.femaTaskForceForm.rawValue {
                    type = TypeOfForm.femaTaskForceForm
                } else if effort == TypeOfForm.strikeForceForm.rawValue {
                    type = TypeOfForm.strikeForceForm
                } else if effort == TypeOfForm.otherForm.rawValue {
                    type = TypeOfForm.otherForm
                } else {
                    type = TypeOfForm.incidentForm
                }
            }
        }
        
    }
    
}

extension ICS214NewMasterAddiitionalFormVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modalCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        let theCell: CellParts = modalCells[row]
        let theCellType = theCell.type["Type"]
        switch  theCellType {
        case .modalHeader:
            return 100
        case .paragraphCell:
            if sections == NewMasterSections.section1 {
                if Device.IS_IPHONE {
                    return 480
                } else {
                    return 450
                }
            } else {
                return 0
            }
        case .formSegmentCell:
            if sections == NewMasterSections.section1 {
                return 135
            } else {
                return 0
            }
        case .fourSwitchCell:
            if sections == NewMasterSections.section2 {
                if Device.IS_IPHONE {
                    return 660
                } else {
                    return 600
                }
            } else {
                return 0
            }
        case .efforWithDateCell:
            if sections == NewMasterSections.section3 {
                return 250
            } else {
                return 0
            }
        case .incidentMasterCell:
            if dataRetrieved {
                if showIncidents {
                    return 66
                } else {
                    return 0
                }
            } else {
                return 0
            }
        case .journalMasterCell:
            if dataRetrieved {
                if showMasters {
                    return 100
                } else {
                    return 0
                }
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let theCell: CellParts = modalCells[row]
        let theCellType = theCell.type["Type"]
        switch  theCellType {
        case .modalHeader:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ModalHeaderCell", for: indexPath) as! ModalHeaderCell
            cell = configureModalHeaderCell(cell, index: indexPath)
            return cell
        case .paragraphCell:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ParagraphCell", for: indexPath) as! ParagraphCell
            cell = configureParagraphCell(cell, index: indexPath)
            return cell
        case .formSegmentCell:
            var cell = tableView.dequeueReusableCell(withIdentifier: "FormSegmentCell", for: indexPath) as! FormSegmentCell
            cell = configureFormSegmentCell(cell, index: indexPath)
            return cell
        case .fourSwitchCell:
            var cell = tableView.dequeueReusableCell(withIdentifier: "FourSwitchCell", for: indexPath) as! FourSwitchCell
            cell = configureFourSwitchCell(cell, index: indexPath)
            return cell
        case .efforWithDateCell:
            var cell = tableView.dequeueReusableCell(withIdentifier: "EffortWithDateCell", for: indexPath) as! EffortWithDateCell
            cell = configureEffortWithDateCell(cell, index: indexPath)
            return cell
        case .incidentMasterCell:
            if dataRetrieved {
                if showIncidents {
                    var cell = tableView.dequeueReusableCell(withIdentifier: "IncidentMasterCell", for: indexPath) as! IncidentMasterCell
                    cell = configureIncidentMasterCell(cell, index: indexPath)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                return cell
            }
        case .journalMasterCell:
            if dataRetrieved {
                if showMasters {
                    var cell = tableView.dequeueReusableCell(withIdentifier: "IncidentMasterCell", for: indexPath) as! IncidentMasterCell
                    cell = configureJournalMasterCell(cell, index: indexPath)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        print("here is the index path selection \(indexPath.row)")
        let theCell: CellParts = modalCells[row]
        let theCellType = theCell.type["Type"]
        switch theCellType {
        case .modalHeader, .paragraphCell, .formSegmentCell, .fourSwitchCell, .efforWithDateCell: break
        case .incidentMasterCell:
            let cell = ics214TableView.cellForRow(at: indexPath) as! IncidentMasterCell
            if masterOrNot {
                if let objectID = cell.obID {
                    theIncidentOID = objectID
                    performSegue(withIdentifier: ICS214NewVCSegue, sender: self)
                }
            }
        case .journalMasterCell:
            let cell = ics214TableView.cellForRow(at: indexPath) as! IncidentMasterCell
            switch type {
            case .incidentForm:
                if let objectID = cell.obID {
                    if let master = context.object(with: objectID) as? ICS214Form {
                        if let theGuid = master.ics214MasterGuid {
                            theMasterGuid = theGuid
                        }
                        theMasterICS214FormOID = master.objectID
                        if master.ics214IncidentInfo != nil {
                            if let incident = master.ics214IncidentInfo {
                                theIncidentOID = incident.objectID
                            }
                        }
                        performSegue(withIdentifier: ICS214NewVCSegue, sender: self)
                    }
                }
            case .strikeForceForm:
                if let objectID = cell.obID {
                    if let master = context.object(with: objectID) as? ICS214Form {
                        if let theGuid = master.ics214MasterGuid {
                            theMasterGuid = theGuid
                        }
                        theMasterICS214FormOID = master.objectID
                        if master.ics214IncidentInfo != nil {
                            if let incident = master.ics214IncidentInfo {
                                theIncidentOID = incident.objectID
                            }
                        }
                        performSegue(withIdentifier: ICS214NewFSOSegue, sender: self)
                    }
                }
            case .femaTaskForceForm:
                if let objectID = cell.obID {
                    if let master = context.object(with: objectID) as? ICS214Form {
                        if let theGuid = master.ics214MasterGuid {
                            theMasterGuid = theGuid
                        }
                        theMasterICS214FormOID = master.objectID
                        if master.ics214IncidentInfo != nil {
                            if let incident = master.ics214IncidentInfo {
                                theIncidentOID = incident.objectID
                            }
                        }
                        performSegue(withIdentifier: ICS214NewFSOSegue, sender: self)
                    }
                }
            case .otherForm:
                if let objectID = cell.obID {
                    if let master = context.object(with: objectID) as? ICS214Form {
                        if let theGuid = master.ics214MasterGuid {
                            theMasterGuid = theGuid
                        }
                        theMasterICS214FormOID = master.objectID
                        if master.ics214IncidentInfo != nil {
                            if let incident = master.ics214IncidentInfo {
                                theIncidentOID = incident.objectID
                            }
                        }
                        performSegue(withIdentifier: ICS214NewFSOSegue, sender: self)
                    }
                }
            default: break
            }
        default:  break
        }
    }
    
}

extension ICS214NewMasterAddiitionalFormVC: ModalHeaderSaveDismissDelegate {
    
    func modalDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func modalSave(myShift: MenuItems) {
            //        <#code#>
    }
    
    func modalInfoBTapped(myShift: MenuItems) {
        presentAlert()
    }
    
    
}

extension ICS214NewMasterAddiitionalFormVC: FormSegmentCellDelegate {
    
    func typeChosen(type: Int) {
        switch type {
        case 0:
            masterOrNot = true
        case 1:
            masterOrNot = false
        default: break
        }
        sections = NewMasterSections.section2
        ics214TableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    
}

extension ICS214NewMasterAddiitionalFormVC: FourSwitchCellDelegate {
    
    func fourSwitchContinueTapped(type: String, masterOrMore: Bool, typeOfForm: TypeOfForm) {
        self.type = typeOfForm
        switch typeOfForm {
        case .incidentForm:
            userDefaults.set(TypeOfForm.incidentForm.rawValue, forKey: FJkICS214TYPEOFFORM)
        case .strikeForceForm:
            userDefaults.set(TypeOfForm.strikeForceForm.rawValue, forKey: FJkICS214TYPEOFFORM)
        case .femaTaskForceForm:
            userDefaults.set(TypeOfForm.femaTaskForceForm.rawValue, forKey: FJkICS214TYPEOFFORM)
        case.otherForm:
            userDefaults.set(TypeOfForm.otherForm.rawValue, forKey: FJkICS214TYPEOFFORM)
        }
        switch typeOfForm {
        case .incidentForm:
            sections = NewMasterSections.section3
            self.ics214TableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
        case .strikeForceForm:
            if masterOrNot {
                performSegue(withIdentifier: ICS214NewFSOSegue, sender: self)
            } else {
                sections = NewMasterSections.section3
                self.ics214TableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            }
        case .femaTaskForceForm:
            if masterOrNot {
                performSegue(withIdentifier: ICS214NewFSOSegue, sender: self)
            } else {
                sections = NewMasterSections.section3
                self.ics214TableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            }
        case .otherForm:
            if masterOrNot {
                performSegue(withIdentifier: ICS214NewFSOSegue, sender: self)
            } else {
                sections = NewMasterSections.section3
                self.ics214TableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            }
        }
    }
    
    
}

extension ICS214NewMasterAddiitionalFormVC: EffortWithDateDelegate {
    
    func theSearchButtonTapped(incidentNum: String, incidentDate: Date?) {
    }
    
    func theSearchButtonTappedNoDate(incidentNum: String) {
        if masterOrNot {
            theIncidentContext = theIncidentProvider.persistentContainer.newBackgroundContext()
            guard let incidents = theIncidentProvider.getAllIncidents(theIncidentContext) else {
                let errorMessage = "There was an error retrieving the incident list"
                errorAlert(errorMessage: errorMessage)
                return
            }
            for incident in incidents {
                let objectID = incident.objectID
                let i10 = CellParts.init(cellAttributes: ["Header": "Incident"], type: ["Type": FormType.incidentMasterCell], vType: ["Value1":ValueType.fjKEmpty], dType: ["Date": Date() ], objID: ["objectID": objectID])
                modalCells.append(i10)
            }
            dataRetrieved = true
            showIncidents = true
            self.ics214TableView.reloadData()
        } else {
            theICS214ProviderContext = theICS214Provider.persistentContainer.newBackgroundContext()
            let theTypeOfEffort = userDefaults.string(forKey: FJkICS214TYPEOFFORM)
            
            if theTypeOfEffort == "incidentForm" {
                type = TypeOfForm.incidentForm
            } else if theTypeOfEffort == "strikeForceForm" {
                type = TypeOfForm.strikeForceForm
            } else if theTypeOfEffort == "femaTaskForceForm" {
                type = TypeOfForm.femaTaskForceForm
            } else if theTypeOfEffort == "otherForm" {
                type = TypeOfForm.otherForm
            }
            guard let masters = theICS214Provider.getTheMasterListICS214(theICS214ProviderContext, thetype: theTypeOfForm) else {
                let errorMessage = "There was an error retrieving the master list"
                errorAlert(errorMessage: errorMessage)
                return
            }
            for master in masters {
                let objectID = master.objectID
                let i10 = CellParts.init(cellAttributes: ["Header": "ICS214"], type: ["Type": FormType.journalMasterCell], vType: ["Value1":ValueType.fjKEmpty], dType: ["Date": Date() ], objID: ["objectID": objectID])
                modalCells.append(i10)
            }
            dataRetrieved = true
            showMasters = true
            self.ics214TableView.reloadData()
        }
    }
    
    func theNewIncidentButtonTapped() {
        performSegue(withIdentifier: ICS214NewIncidentVCSegue, sender: self)
    }
    
    func theTimeButtonWasTappedForIncident() {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var typeForSegue: TypeOfForm = TypeOfForm.incidentForm
        
        let theTypeOfEffort = userDefaults.string(forKey: FJkICS214TYPEOFFORM)
        
        if theTypeOfEffort == "incidentForm" {
            typeForSegue = TypeOfForm.incidentForm
        } else if theTypeOfEffort == "strikeForceForm" {
            typeForSegue = TypeOfForm.strikeForceForm
        } else if theTypeOfEffort == "femaTaskForceForm" {
            typeForSegue = TypeOfForm.femaTaskForceForm
        } else if theTypeOfEffort == "otherForm" {
            typeForSegue = TypeOfForm.otherForm
        }
        
        if segue.identifier == ICS214NewIncidentVCSegue {
            if theUserTimeOID != nil {
                ics214NewIncidentVC = segue.destination as? ICS214NewIncidentVC
                ics214NewIncidentVC.delegate = self
                ics214NewIncidentVC.userTimeObjectID = theUserTimeOID
                ics214NewIncidentVC.transitioningDelegate = slideInTransitioningDelgate
            } else {
                
            }
        } else if segue.identifier == ICS214NewVCSegue {
            
            if theIncidentOID != nil {
                if theIncidentOID != nil && theUserTimeOID != nil && theUserOID != nil {
                    ics214NewVC = segue.destination as? ICS214NewVC
                    ics214NewVC.delegate = self
                    ics214NewVC.type = typeForSegue
                    ics214NewVC.masterOrNot = self.masterOrNot
                    if !self.masterOrNot {
                        ics214NewVC.theMasterGuid = self.theMasterGuid
                        ics214NewVC.theMasterICS214FormOID = self.theMasterICS214FormOID
                    }
                    ics214NewVC.theIncidentOID = theIncidentOID
                    ics214NewVC.theUserTimeOID = theUserTimeOID
                    ics214NewVC.theUserOID = theUserOID
                    ics214NewVC.transitioningDelegate = slideInTransitioningDelgate
                } else {
                    errorAlert(errorMessage: "there is an error here")
                }
            }
        } else if segue.identifier == ICS214NewFSOSegue {
            if theUserTimeOID != nil && theUserOID != nil {
                ics214NewFSOVC = segue.destination as? ICS214NewFSOVC
                ics214NewFSOVC.type = typeForSegue
                ics214NewFSOVC.masterOrNot = self.masterOrNot
                if !self.masterOrNot {
                    ics214NewFSOVC.theMasterGuid = self.theMasterGuid
                    ics214NewFSOVC.theMasterICS214FormOID = self.theMasterICS214FormOID
                }
                if theJournalOID != nil {
                    ics214NewFSOVC.theJournalOID = theJournalOID
                }
                ics214NewFSOVC.theUserTimeOID = theUserTimeOID
                ics214NewFSOVC.theUserOID = theUserOID
                ics214NewFSOVC.transitioningDelegate = slideInTransitioningDelgate
                ics214NewFSOVC.delegate = self
            }
        }
    }
    
    
}

extension ICS214NewMasterAddiitionalFormVC: ICS214NewIncidentVCDelegate {
    
    func ics214IncidentNewCancelled() {
        ics214NewIncidentVC.dismiss(animated: true, completion: nil)
    }
    
    func ics214IncidentNewSaved(objectID: NSManagedObjectID) {
        ics214NewIncidentVC.dismiss(animated: true, completion: nil)
    }
    
    
}

extension ICS214NewMasterAddiitionalFormVC: ICS214NewVCDelegate {
    
    func cancelTheICS214New() {
        ics214NewVC.dismiss(animated: true, completion: nil)
    }
    
    func saveTheICS214New(objectID: NSManagedObjectID) {
        delegate?.newMasterAdditionalFormSaved(objectID)
    }
    
}

extension ICS214NewMasterAddiitionalFormVC: ICS214NewFSOVCDelegate {
    
    func cancelTheICS214NewFSO() {
        ics214NewFSOVC.dismiss(animated: true, completion: nil)
    }
    
    func saveTheICS214NewFSO(objectID: NSManagedObjectID) {
        ics214NewFSOVC.dismiss(animated: true, completion: {
            self.delegate?.newMasterAdditionalFormSaved(objectID)
        })
    }
    
    
}
