//
//  ShiftNewModalVC + Extensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/10/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit
import MapKit
import CoreLocation

extension ShiftNewModalVC: UITableViewDelegate {
    
    func registerCellsForTable() {
            shiftTableView.register(UINib(nibName: "SubjectLabelTextFieldIndicatorTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextFieldIndicatorTVCell")
            shiftTableView.register(UINib(nibName: "SubjectLabelTextViewTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextViewTVCell")
            shiftTableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
            shiftTableView.register(UINib(nibName: "SwitchCenteredTVCell", bundle: nil), forCellReuseIdentifier: "SwitchCenteredTVCell")
            shiftTableView.register(RankTVCell.self, forCellReuseIdentifier: "RankTVCell")
    }
    
}

extension ShiftNewModalVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 44
        case 1:
            return 60
        case 2, 5, 6:
            return 88
        case 3, 4:
            return 55
        case 7:
           return 150
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch  row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCenteredTVCell", for: indexPath) as! SwitchCenteredTVCell
            cell = configureSwitchCenteredTVCell(cell, index: indexPath)
            return cell
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelSingleDateFieldCell", for: indexPath) as! LabelSingleDateFieldCell
            cell = configureLabelSingleDateFieldCell(cell, index: indexPath)
            cell.configureTheLabel(width: 125)
            cell.configureDatePickersHoldingV()
            return cell
        case 2, 5, 6:
            var cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextFieldIndicatorTVCell", for: indexPath) as! SubjectLabelTextFieldIndicatorTVCell
            cell = configureSubjectLabelTextFieldIndicatorTVCell(cell, index: indexPath)
            return cell
        case 3, 4:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RankTVCell", for: indexPath) as! RankTVCell
            cell = configureRankTVCell(cell, index: indexPath)
            cell.selectionStyle = .none
            cell.configureTheButton()
            return cell
        case 7:
            var cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextViewTVCell", for: indexPath) as! SubjectLabelTextViewTVCell
            cell = configureSubjectLabelTextViewTVCell(cell, index: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch row {
        case 5:
            slideInTransitioningDelgate.direction = .bottom
            slideInTransitioningDelgate.disableCompactHeight = true
            let storyBoard : UIStoryboard = UIStoryboard(name: "RelieveSupervisor", bundle:nil)
            let relieveSupervisorVC = storyBoard.instantiateViewController(withIdentifier: "RelieveSupervisorVC") as! RelieveSupervisorVC
            relieveSupervisorVC.delegate = self
    
            relieveSupervisorVC.relievingOrSupervisor = true
            relieveSupervisorVC.headerTitle = "Relieving"
    
            relieveSupervisorVC.menuType = MenuItems.endShift
            relieveSupervisorVC.transitioningDelegate = slideInTransitioningDelgate
            if Device.IS_IPHONE {
                relieveSupervisorVC.modalPresentationStyle = .formSheet
            } else {
                relieveSupervisorVC.modalPresentationStyle = .custom
            }
            self.present(relieveSupervisorVC, animated: true, completion: nil)
        case 6:
            let storyBoard : UIStoryboard = UIStoryboard(name: "RelieveSupervisor", bundle:nil)
            let relieveSupervisorVC = storyBoard.instantiateViewController(withIdentifier: "RelieveSupervisorVC") as! RelieveSupervisorVC
            relieveSupervisorVC.delegate = self
    
            relieveSupervisorVC.relievingOrSupervisor = false
            relieveSupervisorVC.headerTitle = "Supervisor"
    
            relieveSupervisorVC.menuType = MenuItems.endShift
            relieveSupervisorVC.transitioningDelegate = slideInTransitioningDelgate
            if Device.IS_IPHONE {
                relieveSupervisorVC.modalPresentationStyle = .formSheet
            } else {
                relieveSupervisorVC.modalPresentationStyle = .custom
            }
            self.present(relieveSupervisorVC, animated: true, completion: nil)
        default: break
        }
    }
    
    func configureSubjectLabelTextViewTVCell(_ cell: SubjectLabelTextViewTVCell, index: IndexPath) -> SubjectLabelTextViewTVCell {
        cell.subjectL.text = "Discussion"
        if let discussion = theUserTime.startShiftDiscussion {
            cell.subjectTV.text = discussion
        }
        cell.delegate = self
        return cell
    }
    
    func configureRankTVCell(_ cell: RankTVCell, index: IndexPath) -> RankTVCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        cell.indexPath = index
        cell.theSubjectTF.font = UIFont.preferredFont(forTextStyle: .caption1)
        switch row {
        case 3:
            cell.type = IncidentTypes.platoon
            if theUserTime != nil {
                cell.theSubjectTF.text = theUserTime.startShiftPlatoon
            }
        case 4:
            cell.type = IncidentTypes.assignment
            if theUserTime != nil {
                cell.theSubjectTF.text = theUserTime.startShiftAssignment
                cell.theSubjectTF.font = .systemFont(ofSize: 22)
            }
        default: break
        }
        return cell
    }
    
    func configureSwitchCenteredTVCell(_ cell: SwitchCenteredTVCell, index: IndexPath) -> SwitchCenteredTVCell {
        cell.centerSwitch.tintColor = UIColor(named: "FJRedColor")
        if theUserTime != nil {
            shiftAMorRelief = theUserTime.startShiftStatus
            cell.centerSwitch.isOn = shiftAMorRelief
        }
        cell.delegate = self
        return  cell
    }
    
    func configureLabelSingleDateFieldCell(_ cell: LabelSingleDateFieldCell, index: IndexPath ) -> LabelSingleDateFieldCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        cell.index = index
        let section = index.section
        switch section {
        case 0:
            switch row {
            case 1:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Date/Time"
                if theUserTime != nil {
                    if let relievingTime = theUserTime.userStartShiftTime {
                        cell.theFirstDose = relievingTime
                    } else {
                        let startShiftDate = Date()
                        cell.theFirstDose = startShiftDate
                        theUserTime.userStartShiftTime = startShiftDate
                    }
                } else {
                        let startShiftDate = Date()
                        cell.theFirstDose = startShiftDate
                }
            default: break
            }
        default: break
        }
        return cell
    }
    
    
    func configureSubjectLabelTextFieldIndicatorTVCell(_ cell: SubjectLabelTextFieldIndicatorTVCell, index: IndexPath) -> SubjectLabelTextFieldIndicatorTVCell {
        let row = index.row
        switch row {
        case 2:
            cell.subjectL.text = "Fire Station"
            cell.indicatorB.tintColor = UIColor(named: "FJGreenColor")
            cell.indicatorB.isHidden = true
            cell.indicatorB.alpha = 0.0
            cell.indicatorB.isEnabled = false
            if theUserTime != nil {
                if let station = theUser.fireStation {
                    cell.subjectTF.text = station
                    theUserTime.startShiftFireStation = station
                }
            }
        case 5:
            cell.subjectL.text = "Relieving"
            cell.indicatorB.tintColor = UIColor(named: "FJGreenColor")
            cell.indicatorB.isHidden = false
            cell.indicatorB.alpha = 100.0
            cell.indicatorB.isEnabled = true
            if theUserTime != nil {
                if let relieving = theUserTime.startShiftRelieving {
                    cell.subjectTF.text = relieving
                }
            }
        case 6:
            cell.subjectL.text = "Supervisor"
            cell.indicatorB.tintColor = UIColor(named: "FJGreenColor")
            cell.indicatorB.isHidden = false
            cell.indicatorB.alpha = 100.0
            cell.indicatorB.isEnabled = true
            if theUserTime != nil {
                if let supervisor = theUserTime.startShiftSupervisor {
                    cell.subjectTF.text = supervisor
                }
            }
        default: break
        }
        
        
        return cell
    }
    
}

extension ShiftNewModalVC: RelieveSupervisorVCDelegate {

    func relieveSupervisorCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func relieveSupervisorChosen(relieveSupervisor: [UserAttendees], relieveOrSupervisor: Bool) {
        if relieveOrSupervisor {
            if let relief = relieveSupervisor.last {
                if let relieving = relief.attendee {
                    theUserTime.startShiftRelieving = relieving
                }
                shiftTableView.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .automatic)
            }
        } else {
            if let theSuper = relieveSupervisor.last {
                if let supervisor = theSuper.attendee {
                    theUserTime.startShiftSupervisor = supervisor
                }
            }
            shiftTableView.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .automatic)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension ShiftNewModalVC: SubjectLabelTextViewTVCellDelegate {
    
    func subjectLabelTextViewEditing(text: String) {
        theUserTime.startShiftDiscussion = text
    }
    
    func subjectLabelTextViewDoneEditing(text: String) {
        theUserTime.startShiftDiscussion = text
    }
    
    
}

extension ShiftNewModalVC: RankTVCellDelegate {
    
    func theButtonChoiceWasMade(_ text: String, index: IndexPath, tag: Int) {
        let row = index.row
        switch row {
        case 3:
            theUserTime.startShiftPlatoon = text
            shiftTableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
        case 4:
            theUserTime.startShiftAssignment = text
            shiftTableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
        default: break
        }
    }
    
}


extension ShiftNewModalVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        theUserTime.userStartShiftTime = date
    }
    
}

extension ShiftNewModalVC: SwitchCenteredTVCellDelegate {
    
    func switchCenteredHasBeenTapped(switchB: Bool) {
        theUserTime.startShiftStatus = switchB
    }
    
}

extension ShiftNewModalVC: ShiftModalHeaderVDelegate {
    
    func shiftModalSaveBTapped() {
        if theUserTime == nil {
            let errorMessage = "There is no shift to update"
            errorAlert(errorMessage: errorMessage)
        } else {
            if theUserTime.userStartShiftTime == nil {
                theUserTime.userEndShiftTime = Date()
            }
            if theUserTime.startShiftFireStation == "" || theUserTime.startShiftFireStation == nil {
                let cell = shiftTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! SubjectLabelTextFieldIndicatorTVCell
                if let station = cell.subjectTF.text {
                    theUserTime.startShiftFireStation = station
                } else {
                    theUserTime.startShiftFireStation = ""
                }
            }
            if theUserTime.startShiftPlatoon == "" || theUserTime.startShiftPlatoon == nil {
                let cell = shiftTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! RankTVCell
                if let platoon = cell.theSubjectTF.text {
                    theUserTime.startShiftPlatoon = platoon
                } else {
                    theUserTime.startShiftPlatoon = ""
                }
            }
            if theUserTime.startShiftAssignment == "" || theUserTime.startShiftAssignment == nil {
                let cell = shiftTableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! RankTVCell
                if let assignment = cell.theSubjectTF.text {
                    theUserTime.startShiftAssignment = assignment
                } else {
                    theUserTime.startShiftAssignment = ""
                }
            }
            if theUserTime.startShiftRelieving == "" || theUserTime.startShiftRelieving == nil {
                let cell = shiftTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as! SubjectLabelTextFieldIndicatorTVCell
                if let relieving = cell.subjectTF.text {
                    theUserTime.startShiftRelieving = relieving
                } else {
                    theUserTime.startShiftRelieving = ""
                }
            }
            if theUserTime.startShiftSupervisor == "" || theUserTime.startShiftSupervisor == nil {
                let cell = shiftTableView.cellForRow(at: IndexPath(row: 6, section: 0)) as! SubjectLabelTextFieldIndicatorTVCell
                if let supervisor = cell.subjectTF.text {
                    theUserTime.startShiftSupervisor = supervisor
                } else {
                    theUserTime.startShiftSupervisor = ""
                }
            }
            if theUserTime.startShiftDiscussion == "" || theUserTime.startShiftDiscussion == nil {
                let cell = shiftTableView.cellForRow(at: IndexPath(row: 7, section: 0)) as! SubjectLabelTextViewTVCell
                if let discussion = cell.subjectTV.text {
                    theUserTime.startShiftDiscussion = discussion
                } else {
                    theUserTime.startShiftDiscussion = ""
                }
            }
            if theUserTime.startShiftFireStation != "",  theUserTime.startShiftPlatoon != "", theUserTime.startShiftAssignment != "", theUserTime.startShiftRelieving != "", theUserTime.startShiftSupervisor != "", theUserTime.startShiftDiscussion != "" {
                buildTheStartShiftJournal()
                if let guid = theUserTime.userTimeGuid {
                    self.userDefaults.set(guid, forKey: FJkUSERTIMEGUID)
                } else {
                    var guidDate: GuidFormatter!
                    if let date = theUserTime.userStartShiftTime {
                        guidDate = GuidFormatter.init(date: date)
                    } else {
                        guidDate = GuidFormatter.init(date: Date())
                    }
                    let guid = guidDate.formatGuid()
                    let theUserGuid = "78."+guid
                    theUserTime.userTimeGuid = theUserGuid
                    self.userDefaults.set(theUserGuid, forKey: FJkUSERTIMEGUID)
                }
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"StartShiftModal TVC merge that"])
                    }
                    let objectID = theUserTime.objectID
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue:FJkCKNewStartEndCreated),
                                object: nil,
                                userInfo: ["objectID": objectID as NSManagedObjectID])
                    }
                    delegate?.dismissShiftStartModal()
                } catch let error as NSError {
                    let theError: String = error.localizedDescription
                    let error = "There was an error in saving " + theError
                    errorAlert(errorMessage: error)
                }
            } else {
                var message: String = "The following is needed to complete\n\n"
                var messagesA = [String]()
                if theUserTime.startShiftFireStation == "" {
                    let error = "The fire station id is needed."
                    messagesA.append(error)
                }
                if theUserTime.startShiftPlatoon == "" {
                    let error = "Your platoon is needed."
                    messagesA.append(error)
                }
                if theUserTime.startShiftAssignment == "" {
                    let error = "Assignment needs to be designated."
                    messagesA.append(error)
                }
                if theUserTime.startShiftRelieving == "" {
                    let error = "Who you are relieving is necessary."
                    messagesA.append(error)
                }
                if theUserTime.startShiftSupervisor == "" {
                    let error = "Who is your supervisor."
                    messagesA.append(error)
                }
                if theUserTime.startShiftDiscussion == "" {
                    let error = "Assignment needs to be designated."
                    messagesA.append(error)
                }
                let theMessage = messagesA.joined(separator: "\n")
                message = message + theMessage
                errorAlert(errorMessage: message)
            }
            
        }
    }
    
    
    func shiftModalCancelBTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func shiftModalInfoBTapped() {
            presentAlert()
    }
    
    func buildTheStartShiftJournal() {
        let theJournal = Journal(context: context)
        let journalModDate = Date()
        let jGuidDate = GuidFormatter.init(date:journalModDate)
        let searchDate = FormattedDate.init(date:journalModDate)
        let sDate:String = searchDate.formatTheDateAndTime()
        let jGuid:String = jGuidDate.formatGuid()
        theJournal.fjpJGuidForReference = "01."+jGuid
        theJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        theJournal.journalEntryType = "Station"
        theJournal.journalCreationDate = journalModDate
        theJournal.journalModDate = journalModDate
        theJournal.journalDateSearch = sDate
        theJournal.fjpIncReference = ""
        theJournal.fjpUserReference = theUser.userGuid
        theJournal.journalHeader = "Start Shift " + sDate
        var shiftStatus: String = ""
        if theUserTime.startShiftStatus {
           shiftStatus = "Overtime"
        } else {
            shiftStatus = "AM Relief"
        }
        var station: String = ""
        if let fireID = theUser.fireStation {
            station = fireID
        }
        var platoon: String = ""
        if let p = theUserTime.startShiftPlatoon {
            platoon = p
        }
        var assignment: String = ""
        if let a = theUserTime.startShiftAssignment {
            assignment = a
        }
        var relief: String = ""
        if let r = theUserTime.startShiftRelieving {
            relief = r
        }
        var supervisor: String = ""
        if let s = theUserTime.startShiftSupervisor {
            supervisor = s
        }
        var discussion: String = ""
        if let d = theUserTime.startShiftDiscussion {
            discussion = d
        }
        var address: String = ""
        if let theAddress = theUser.fireStationAddress {
            address = theAddress
        } else {
            if let number = theUser.fireStationStreetNumber {
                address = number + ""
            }
            if let street = theUser.fireStationStreetName {
                address = address + street + ""
            }
            if let city = theUser.fireStationCity {
                address = address + "\n\n" + city + ", "
            }
            if let state = theUser.fireStationState {
                address = address + state + ""
            }
            if let zip = theUser.fireStationZipCode {
                address = address + zip
            }
        }
        let overview = """
Start Shift
Status: \(shiftStatus)
Date/Time: \(sDate)
Fire Station: \(station)
Station address: \(address)
Platoon: \(platoon)
Assignment: \(assignment)
Relieving: \(relief)
Supervisor: \(supervisor)
Discussion: \(discussion)
"""
        theJournal.journalOverview = overview as NSObject
        theJournal.journalTempFireStation = station
        theJournal.journalFireStation = station
        theJournal.journalTempPlatoon = theUserTime.startShiftPlatoon
        theJournal.journalTempApparatus = theUserTime.startShiftApparatus
        theJournal.journalTempAssignment = theUserTime.startShiftAssignment
        theJournal.journalBackedUp = false
        theJournal.journalPhotoTaken = false
        theJournal.journalPrivate = true
        
        theJournal.userTime = theUserTime
        theJournal.fireJournalUserInfo = theUser
        
    }
    
    
}

