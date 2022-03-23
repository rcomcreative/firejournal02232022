//
//  ShiftEndModalVC + Extensions.swift
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

extension ShiftEndModalVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        shiftTableView.register(UINib(nibName: "SubjectLabelTextFieldIndicatorTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextFieldIndicatorTVCell")
        shiftTableView.register(UINib(nibName: "SubjectLabelTextViewTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextViewTVCell")
        shiftTableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
        shiftTableView.register(RankTVCell.self, forCellReuseIdentifier: "RankTVCell")
    }
    
}

extension ShiftEndModalVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 60
        case 1:
            return 88
        case 2:
            return 55
        case 3:
           return discussionHeight
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch  row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelSingleDateFieldCell", for: indexPath) as! LabelSingleDateFieldCell
            cell = configureLabelSingleDateFieldCell(cell, index: indexPath)
            cell.configureTheLabel(width: 125)
            cell.configureDatePickersHoldingV()
            return cell
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextFieldIndicatorTVCell", for: indexPath) as! SubjectLabelTextFieldIndicatorTVCell
            cell = configureSubjectLabelTextFieldIndicatorTVCell(cell, index: indexPath)
            return cell
        case 2:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RankTVCell", for: indexPath) as! RankTVCell
            cell = configureRankTVCell(cell, index: indexPath)
            cell.selectionStyle = .none
            cell.configureTheButton()
            return cell
        case 3:
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
        case 1:
            presentCrew()
        default: break
        }
    }
    
    func configureSubjectLabelTextViewTVCell(_ cell: SubjectLabelTextViewTVCell, index: IndexPath) -> SubjectLabelTextViewTVCell {
        cell.subjectL.text = "Discussion"
        if let discussion = theUserTime.endShiftDiscussion {
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
        case 2:
            cell.type = IncidentTypes.leaveWork
            if theUserTime != nil {
                cell.theSubjectTF.text = theUserTime.endShiftLeaveWork
            }
        default: break
        }
        return cell
    }
    
    func configureSubjectLabelTextFieldIndicatorTVCell(_ cell: SubjectLabelTextFieldIndicatorTVCell, index: IndexPath) -> SubjectLabelTextFieldIndicatorTVCell {
        cell.subjectL.text = "Relieved By"
        cell.indicatorB.tintColor = UIColor(named: "FJGreenColor")
        if theUserTime != nil {
            if let relief = theUserTime.enShiftRelievedBy {
                cell.subjectTF.text = relief
            }
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
            case 0:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Date/Time"
                if theUserTime != nil {
                    if let relievingTime = theUserTime.userEndShiftTime {
                        cell.theFirstDose = relievingTime
                    } else {
                        let endShiftDate = Date()
                        cell.theFirstDose = endShiftDate
                        theUserTime.userEndShiftTime = endShiftDate
                    }
                } else {
                        let endShiftDate = Date()
                        cell.theFirstDose = endShiftDate
                }
            default: break
            }
        default: break
        }
        return cell
    }
    
}

extension ShiftEndModalVC: SubjectLabelTextViewTVCellDelegate {
    
    func subjectLabelTextViewEditing(text: String) {
        theUserTime.endShiftDiscussion = text
    }
    
    func subjectLabelTextViewDoneEditing(text: String) {
        theUserTime.endShiftDiscussion = text
    }
    
    
}

extension ShiftEndModalVC: RankTVCellDelegate {
    
    func theButtonChoiceWasMade(_ text: String, index: IndexPath, tag: Int) {
        theUserTime.endShiftLeaveWork = text
    }
    
}

extension ShiftEndModalVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        theUserTime.userEndShiftTime = date
    }
    
}

extension ShiftEndModalVC: SwitchCenteredTVCellDelegate {
    
    func switchCenteredHasBeenTapped(switchB: Bool) {
        theUserTime.endShiftStatus = switchB
    }
    
}

extension ShiftEndModalVC: ShiftModalHeaderVDelegate {
    
    func shiftModalSaveBTapped() {
        if theUserTime == nil {
            let errorMessage = "There is no shift to update"
            errorAlert(errorMessage: errorMessage)
        } else {
            if theUserTime.userEndShiftTime == nil {
                theUserTime.userEndShiftTime = Date()
            }
            if theUserTime.endShiftLeaveWork == nil || theUserTime.endShiftLeaveWork == "" {
                let cell = shiftTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! RankTVCell
                if let work = cell.theSubjectTF.text {
                theUserTime.endShiftLeaveWork = work
                } else {
                    theUserTime.endShiftLeaveWork = ""
                }
            }
            if theUserTime.enShiftRelievedBy == nil || theUserTime.enShiftRelievedBy == "" {
                let cell = shiftTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! SubjectLabelTextFieldIndicatorTVCell
                if let relieved = cell.subjectTF.text {
                theUserTime.enShiftRelievedBy = relieved
                } else {
                    theUserTime.enShiftRelievedBy = ""
                }
            }
            if theUserTime.endShiftDiscussion == nil || theUserTime.endShiftDiscussion == "" {
                let cell = shiftTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! SubjectLabelTextViewTVCell
                if let discussion = cell.subjectTV.text {
                theUserTime.endShiftDiscussion = discussion
                } else {
                    theUserTime.endShiftDiscussion = ""
                }
            }
            if theUserTime.enShiftRelievedBy != "", theUserTime.endShiftDiscussion != "" {
                buildTheEndShiftJournal()
                theUserTime.shiftCompleted = true
                self.userDefaults.set("", forKey: FJkUSERTIMEGUID)
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"EndShiftModal TVC merge that"])
                    }
                    let objectID = theUserTime.objectID
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue:FJkCKMODIFIEDSTARTENDTOCLOUD),
                                object: nil,
                                userInfo: ["objectID": objectID as NSManagedObjectID])
                    }
                    delegate?.dismissShiftEndModal()
                } catch let error as NSError {
                    let theError: String = error.localizedDescription
                    let error = "There was an error in saving " + theError
                    errorAlert(errorMessage: error)
                }
            } else {
                var message: String = "The following is needed to complete\n\n"
                var messagesA = [String]()
                if theUserTime.enShiftRelievedBy == "" {
                    let error = "Relief by needs a name."
                    messagesA.append(error)
                }
                if theUserTime.endShiftDiscussion == "" {
                    let error = "Discussion need to be entered."
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
    
    func presentAlert() {
        let message: InfoBodyText = .endShiftRecorded
        let title: InfoBodyText = .endShiftRecordedSubject
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func buildTheEndShiftJournal() {
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
        theJournal.journalHeader = "End Shift " + sDate
        var leftWork: String = ""
        if let l = theUserTime.endShiftLeaveWork {
            leftWork = l
        }
        var relief: String = ""
        if let r = theUserTime.enShiftRelievedBy {
            relief = r
        }
        var discussion: String = ""
        if let d = theUserTime.endShiftDiscussion {
            discussion = d
        }
        var station: String = ""
        if let fireID = theUser.fireStation {
            station = fireID
        }
        var address: String = ""
        if let theAddress = theUser.fireStationAddress {
            address = theAddress
        }
        let overview = """
End Shift
Left Work: \(leftWork)
Date/Time: \(sDate)
Relieved By: \(relief)
Discussion: \(discussion)
Fire Station: \(station)
Address: \(address)
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

extension ShiftEndModalVC {
    
        // MARK: -DATA-
        //    MARK: -PRESENT THE CONTACTS-
        //    MARK: -presentCrew for startShift
    func presentCrew(){
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "RelieveSupervisor", bundle:nil)
        let relieveSupervisorVC = storyBoard.instantiateViewController(withIdentifier: "RelieveSupervisorVC") as! RelieveSupervisorVC
        relieveSupervisorVC.delegate = self
        if superOrRelief {
            relieveSupervisorVC.headerTitle = "Relieved By"
            relieveSupervisorVC.relievingOrSupervisor = true
        } else {
            relieveSupervisorVC.headerTitle = "Supervisor"
            relieveSupervisorVC.relievingOrSupervisor = false
        }
        
        
        
        relieveSupervisorVC.transitioningDelegate = slideInTransitioningDelgate
        relieveSupervisorVC.modalPresentationStyle = .custom
        self.present(relieveSupervisorVC, animated: true, completion: nil)
    }
    
}

extension ShiftEndModalVC: RelieveSupervisorVCDelegate {
    
    func relieveSupervisorCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func relieveSupervisorChosen(relieveSupervisor: [UserAttendees], relieveOrSupervisor: Bool) {
            let crew = relieveSupervisor.first
            theUserTime.enShiftRelievedBy = crew?.attendee
            shiftTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            self.dismiss(animated: true, completion: nil)
    }
    
    
}
