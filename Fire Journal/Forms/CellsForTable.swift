//
//  CellsForTable.swift
//  dashboard
//
//  Created by DuRand Jones on 9/6/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation


//class CellsForTable: StartShiftOvertimeSwitchDelegate,dismissUpdateSaveCellDelegate,dismissSaveCellDelegate,AddressFieldsButtonsCellDelegate,LabelTextViewDirectionalCellDelegate,LabelDateTimeButtonCellDelegate,DatePickerCellDelegate,LabelTextFieldCellDelegate,LabelTextViewCellDelegate,LabelAnswerSwitchCellDelegate,LabelTextViewSwitchCellDelegate,LabelTextFieldWithDirectionCellDelegate,MapViewCellDelegate,IncidentTextViewWithDirectionalCellDelegate,SegmentCellDelegate,CLLocationManagerDelegate,ImageTextFieldTextViewCellDelegate,LabelDirectionalTVSwitchCellDelegate,LabelTextFieldDirectionalSwitchCellDelegate,LabelNoDescripAnswerSwitchCellDelegate,LabelDateTimeSearchSwitchButtonCellDelegate,AddressSearchButtonsCellDelegate,LabelSearchTextViewDirectionalSwitchCellDelegate {
class CellsForTable {
    var shift: MenuItems!
    
    init(myShift: MenuItems) {
        shift = myShift
    }
    
    func cellForTheTable(myShift:MenuItems,tableView: UITableView, indexPath: IndexPath,showMap: Bool, showPicker: Bool, updateTapped: Bool,segmentType: MenuItems, modalTitle: String, modalInstructions: String,startShift: StartShift,incidentStructure: IncidentData, journalStructure: JournalData, startShiftStructure: StartShiftData, endShiftStructure: EndShiftData, alarmStructure: AlarmData, ics214Structure: ICS214Data )->UITableViewCell {
        _ = indexPath.row
        
//        switch row {
//        case 0:
//            switch myShift {
//            case .endShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "dismissUpdateSaveCell", for: indexPath) as! dismissUpdateSaveCell
//                cell.delegate = self
//                cell.myShift = myShift
//                if updateTapped {
//                    cell.updateB.isHidden = true
//                    cell.updateB.alpha = 0.0
//                } else {
//                    cell.updateB.isHidden = false
//                    cell.updateB.alpha = 1.0
//                }
//                return cell
//            case .startShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "dismissSaveCell", for: indexPath) as! dismissSaveCell
//                cell.delegate = self
//                cell.myShift = myShift
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "dismissSaveCell", for: indexPath) as! dismissSaveCell
//                cell.delegate = self
//                return cell
//            }
//        case 1:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
//            cell.modalTitleL.text = modalTitle
//            return cell
//        case 2:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
//            cell.modalInstructions.text = modalInstructions
//            return cell
//        case 3:
//            switch myShift {
//            case .incidents?:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
//                cell.delegate = self
//                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
//                cell.startOrEndB = true
//                cell.myShift = myShift
//                cell.amOrOvertimeL.text = "Emergency"
//                cell.amOrOvertimeL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                return cell
//            case .journal:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
//                cell.delegate = self
//                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
//                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
//                cell.startOrEndB = true
//                cell.myShift = myShift
//                cell.amOrOvertimeL.text = "Public"
//                cell.amOrOvertimeL.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                return cell
//            case .forms:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTextFieldTextViewCell", for: indexPath) as! ImageTextFieldTextViewCell
//                cell.delegate = self
//                let image = UIImage(named: "100515IconSet_092016_NFIRSBasic1")
//                cell.iconIV.image = image
//                cell.subjectL.text = "NFIRS Basic 1"
//                cell.myShift = .nfirs
//                cell.descriptionTV.text = "The NFIRS-1 Basic Form is the most commonly used form following an emergency incident. Designed by the U.S. Fire Administration (USFA), this form should be used following every incident, regardless of type. Data may be shared, or, using Fire Journal Cloud (subscription required), you may create a PDF file that matches the Government NFIRS-1 form."
//                return cell
//            case .nfirsBasic1Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
//                cell.delegate = self
//                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
//                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
//                cell.startOrEndB = true
//                cell.myShift = myShift
//                cell.amOrOvertimeL.text = "Completed"
//                cell.amOrOvertimeL.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                return cell
//            case .incidentSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
//                cell.delegate = self
//                cell.subjectL.text = "Incident Type"
//                cell.myShift = .incidents
//                cell.typeSegment.setTitle("Fire", forSegmentAt: 0)
//                cell.typeSegment.setTitle("EMS", forSegmentAt: 1)
//                cell.typeSegment.setTitle("Rescue", forSegmentAt: 2)
//                if segmentType != nil {
//                    switch segmentType {
//                    case .fire:
//                        cell.typeSegment.selectedSegmentIndex = 0
//                    case .ems:
//                        cell.typeSegment.selectedSegmentIndex = 1
//                    case .rescue:
//                        cell.typeSegment.selectedSegmentIndex = 2
//                    default:
//                        cell.typeSegment.selectedSegmentIndex = 0
//                    }
//                }
//                return cell
//            case .startShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
//                cell.amOrOvertimeL.text = startShiftStructure.ssAMReliefDefaultT
//                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
//                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
//                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
//                cell.startOrEndB = startShiftStructure.ssAMReliefDefault
//                cell.myShift = myShift
//                cell.delegate = self
//                return cell
//            case .endShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
//                cell.amOrOvertimeL.text = "AM Relief"
//                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
//                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
//                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
//                cell.startOrEndB = true
//                cell.myShift = myShift
//                cell.delegate = self
//                return cell
//            case .alarmSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
//                cell.delegate = self
//                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
//                cell.startOrEndB = true
//                cell.myShift = myShift
//                cell.amOrOvertimeL.text = "Completed"
//                cell.amOrOvertimeL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                return cell
//            case .ics214Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
//                cell.delegate = self
//                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
//                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
//                cell.startOrEndB = true
//                cell.myShift = myShift
//                cell.amOrOvertimeL.text = "Completed"
//                cell.amOrOvertimeL.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//                return cell
//            }
//        case 4:
//            switch myShift {
//            case .incidents?:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
//                cell.delegate = self
//                cell.subjectL.text = "Incident Number"
//                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "01",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                return cell
//            case .incidentSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNoDescripAnswerSwitchCell", for: indexPath) as! LabelNoDescripAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Incident Number"
//                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "01",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                cell.myShift = myShift
//                cell.defaultOrNot = false
//                cell.switchType = .incidentNumber
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .alarmSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNoDescripAnswerSwitchCell", for: indexPath) as! LabelNoDescripAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Campaign"
//                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Wilson",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                cell.myShift = myShift
//                cell.defaultOrNot = false
//                cell.switchType = .incidentNumber
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .ics214Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNoDescripAnswerSwitchCell", for: indexPath) as! LabelNoDescripAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Incident Name"
//                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "01",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.45)])
//                cell.myShift = myShift
//                cell.defaultOrNot = false
//                cell.switchType = .incidentNumber
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .journal:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
//                cell.delegate = self
//                cell.subjectL.text = "Entry Title"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Roll Call",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)])
//                return cell
//            case .nfirsBasic1Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
//                cell.delegate = self
//                cell.dateTimeTV.text = startShift?.startTime
//                cell.dateTimeL.text = "Date/Time"
//                let image = UIImage(named: "ICONS_TimePiece")
//                cell.dateTimeB.setImage(image, for: .normal)
//                switch myShift {
//                case .incidents?:
//                    cell.dateTimeTV.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)
//                default:
//                    cell.dateTimeTV.textColor = UIColor.black
//                }
//                return cell
//            case .forms:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTextFieldTextViewCell", for: indexPath) as! ImageTextFieldTextViewCell
//                cell.delegate = self
//                let image = UIImage(named: "100515IconSet_092016_ICS 214 Form")
//                cell.iconIV.image = image
//                cell.myShift = .ics214
//                cell.subjectL.text = "NIMS ICS 214 Activity Log"
//                cell.descriptionTV.text = "When assigned to a campaign incident, the Activity Log (ICS-214) records details of notably activities at any ICS level, including but not limited to single resources, equipment, crew, etc. These forms are to be completed on a daily basis. You may create a single form, or create a campaign, with ongoing daily forms attached to the master form. Data may be shared, or, using Fire Journal Cloud (subscription required), you may create a PDF file that matches that used by NIMS."
//                return cell
//            case .startShift, .endShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
//                cell.delegate = self
//                cell.dateTimeTV.text = startShift?.startTime
//                cell.dateTimeL.text = "Date/Time"
//                switch myShift {
//                case .incidents?:
//                    cell.dateTimeTV.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)
//                case .startShift:
//                    let image = UIImage(named: "ICONS_TimePiece green")
//                    cell.dateTimeB.setImage(image, for: .normal)
//                    cell.dateTimeTV.textColor = UIColor.black
//                case .endShift:
//                    let image = UIImage(named: "ICONS_TimePiece orange")
//                    cell.dateTimeB.setImage(image, for: .normal)
//                    cell.dateTimeTV.textColor = UIColor.black
//                default:
//                    cell.dateTimeTV.textColor = UIColor.black
//                }
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//                return cell
//            }
//        case 5:
//            switch myShift {
//            case .incidents?:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
//                cell.delegate = self
//                cell.dateTimeTV.text = startShift?.startTime
//                cell.dateTimeL.text = "Date/Time"
//                let image = UIImage(named: "ICONS_TimePiece red")
//                cell.dateTimeB.setImage(image, for: .normal)
//                switch myShift {
//                case .incidents?:
//                    cell.dateTimeTV.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)
//                default:
//                    cell.dateTimeTV.textColor = UIColor.black
//                }
//                return cell
//            case .incidentSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeSearchSwitchButtonCell", for: indexPath) as! LabelDateTimeSearchSwitchButtonCell
//                cell.delegate = self
//                cell.descriptionTF.text = startShift?.startTime
//                cell.subjectL.text = "Date/Time"
//                let image = UIImage(named: "ICONS_TimePiece red")
//                cell.clockB.setImage(image, for: .normal)
//                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)
//                cell.myShift = myShift
//                cell.defaultOrNot = false
//                cell.switchType = .dateTime
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .alarmSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNoDescripAnswerSwitchCell", for: indexPath) as! LabelNoDescripAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Local Partner"
//                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Red Cross",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                cell.myShift = myShift
//                cell.defaultOrNot = false
//                cell.switchType = .incidentNumber
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .ics214Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNoDescripAnswerSwitchCell", for: indexPath) as! LabelNoDescripAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Campaign"
//                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Freemont",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.45)])
//                cell.myShift = myShift
//                cell.defaultOrNot = false
//                cell.switchType = .incidentNumber
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .journal:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
//                cell.delegate = self
//                cell.subjectL.text = "Entry Type"
//                cell.myShift = .journal
//                cell.typeSegment.setTitle("Station", forSegmentAt: 0)
//                cell.typeSegment.setTitle("Community", forSegmentAt: 1)
//                cell.typeSegment.setTitle("Members", forSegmentAt: 2)
//                cell.typeSegment.tintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                if segmentType != nil {
//                    switch segmentType {
//                    case .station:
//                        cell.typeSegment.selectedSegmentIndex = 0
//                    case .community:
//                        cell.typeSegment.selectedSegmentIndex = 1
//                    case .members:
//                        cell.typeSegment.selectedSegmentIndex = 2
//                    default:
//                        cell.typeSegment.selectedSegmentIndex = 0
//                    }
//                }
//                return cell
//            case .nfirsBasic1Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
//                cell.delegate = self
//                if(showPicker) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 216)
//                    )
//                    cell.dateHolderV.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.dateHolderV.frame = frame
//                }
//                return cell
//            case .forms:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTextFieldTextViewCell", for: indexPath) as! ImageTextFieldTextViewCell
//                cell.delegate = self
//                let image = UIImage(named: "100515IconSet_092016_redCross")
//                cell.iconIV.image = image
//                cell.myShift = .arcForm
//                cell.subjectL.text = "ARC Smoke Alarm Form"
//                cell.descriptionTV.text = "This form is to be used when inspecting a living space for working smoke alarms. You may use a single form, or create a campaign (such as when inspecting an entire street). Data may be shared, or, using Fire Journal Cloud (subscription required), you may create a PDF file that matches that used by the American Red Cross."
//                return cell
//            case .startShift, .endShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
//                cell.delegate = self
//                if(showPicker) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 216)
//                    )
//                    cell.dateHolderV.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.dateHolderV.frame = frame
//                }
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//                return cell
//            }
//        case 6:
//            switch myShift {
//            case .incidents?:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
//                cell.delegate = self
//                if(showPicker) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 216)
//                    )
//                    cell.dateHolderV.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.dateHolderV.frame = frame
//                }
//                return cell
//            case .incidentSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
//                cell.delegate = self
//                if(showPicker) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 216)
//                    )
//                    cell.dateHolderV.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.dateHolderV.frame = frame
//                }
//                return cell
//            case .ics214Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNoDescripAnswerSwitchCell", for: indexPath) as! LabelNoDescripAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Effort"
//                cell.descriptionTF.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "FEMA",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.45)])
//                cell.myShift = myShift
//                cell.defaultOrNot = false
//                cell.switchType = .incidentNumber
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .alarmSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeSearchSwitchButtonCell", for: indexPath) as! LabelDateTimeSearchSwitchButtonCell
//                cell.delegate = self
//                cell.descriptionTF.text = startShift?.startTime
//                cell.subjectL.text = "Date/Time"
//                let image = UIImage(named: "ICONS_TimePiece red")
//                cell.clockB.setImage(image, for: .normal)
//                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)
//                cell.myShift = myShift
//                cell.defaultOrNot = false
//                cell.switchType = .dateTime
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .journal:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
//                cell.delegate = self
//                cell.dateTimeTV.text = startShift?.startTime
//                cell.dateTimeL.text = "Date/Time"
//                let image = UIImage(named: "ICONS_TimePiece")
//                cell.dateTimeB.setImage(image, for: .normal)
//                switch myShift {
//                case .incidents?:
//                    cell.dateTimeTV.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)
//                default:
//                    cell.dateTimeTV.textColor = UIColor.black
//                }
//                return cell
//            case .nfirsBasic1Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
//                cell.delegate = self
//                cell.subjectL.text = "Incident Number"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "14",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)])
//                return cell
//            case .startShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
//                cell.delegate = self
//                cell.myShift = myShift
//                cell.subjectL.text = "Relieving"
//                cell.descriptionTF.text = startShiftStructure.ssRelieving
//                return cell
//            case .endShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
//                cell.delegate = self
//                cell.myShift = myShift
//                cell.descriptionTF.text = endShiftStructure.esRelieving
//                cell.subjectL.text = "Relieved By"
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//                return cell
//            }
//        case 7:
//            switch myShift {
//            case .incidents?:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
//                cell.delegate = self
//                cell.subjectL.text = "Incident Type"
//                cell.myShift = .incidents
//                cell.typeSegment.setTitle("Fire", forSegmentAt: 0)
//                cell.typeSegment.setTitle("EMS", forSegmentAt: 1)
//                cell.typeSegment.setTitle("Rescue", forSegmentAt: 2)
//                if segmentType != nil {
//                    switch segmentType {
//                    case .fire:
//                        cell.typeSegment.selectedSegmentIndex = 0
//                    case .ems:
//                        cell.typeSegment.selectedSegmentIndex = 1
//                    case .rescue:
//                        cell.typeSegment.selectedSegmentIndex = 2
//                    default:
//                        cell.typeSegment.selectedSegmentIndex = 0
//                    }
//                }
//                return cell
//            case .incidentSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "AddressSearchButtonsCell", for: indexPath) as! AddressSearchButtonsCell
//                cell.subjectL.text = "Address"
//                if streetName == "" {
//                    cell.addressL.attributedPlaceholder = NSAttributedString(string: "100 Main Street",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                } else {
//                    cell.addressL.text = "\(streetNum) \(streetName)"
//                }
//                cell.addressL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                if city == "" {
//                    cell.cityL.attributedPlaceholder = NSAttributedString(string: "Los Angeles",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                } else {
//                    cell.cityL.text = city
//                }
//                cell.cityL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                if stateName == "" {
//                    cell.stateL.attributedPlaceholder = NSAttributedString(string: "CA",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                } else {
//                    cell.stateL.text = stateName
//                }
//                cell.stateL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                if zipNum == "" {
//                    cell.zipL.attributedPlaceholder = NSAttributedString(string: "90001",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                } else {
//                    cell.zipL.text = zipNum
//                }
//                cell.zipL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.delegate = self
//                cell.myShift = myShift
//                cell.defaultOrNot = false
//                cell.switchType = .address
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .ics214Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeSearchSwitchButtonCell", for: indexPath) as! LabelDateTimeSearchSwitchButtonCell
//                cell.delegate = self
//                cell.descriptionTF.text = startShift?.startTime
//                cell.subjectL.text = "Date From"
//                let image = UIImage(named: "ICONS_TimePiece")
//                cell.clockB.setImage(image, for: .normal)
//                cell.descriptionTF.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)
//                cell.myShift = myShift
//                cell.defaultOrNot = false
//                cell.switchType = .dateTime
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .alarmSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
//                cell.delegate = self
//                if(showPicker) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 216)
//                    )
//                    cell.dateHolderV.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.dateHolderV.frame = frame
//                }
//                return cell
//            case .journal:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
//                cell.delegate = self
//                if(showPicker) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 216)
//                    )
//                    cell.dateHolderV.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.dateHolderV.frame = frame
//                }
//                return cell
//            case .nfirsBasic1Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "AddressFieldsButtonsCell", for: indexPath) as! AddressFieldsButtonsCell
//                cell.subjectL.text = "Address"
//                let image1 = UIImage(named: "ICONS_location blue")
//                let image2 = UIImage(named: "ICONS_world blue")
//                cell.locationB.setImage(image1, for: .normal)
//                cell.mapB.setImage(image2, for: .normal)
//                if streetName == "" {
//                    cell.addressTF.attributedPlaceholder = NSAttributedString(string: "100 Main Street",attributes: [NSAttributedStringKey.foregroundColor:UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
//                } else {
//                    cell.addressTF.text = "\(streetNum) \(streetName)"
//                }
//                cell.addressTF.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                if city == "" {
//                    cell.cityTF.attributedPlaceholder = NSAttributedString(string: "Los Angeles",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
//                } else {
//                    cell.cityTF.text = city
//                }
//                cell.cityTF.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                if stateName == "" {
//                    cell.stateTF.attributedPlaceholder = NSAttributedString(string: "CA",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
//                } else {
//                    cell.stateTF.text = stateName
//                }
//                cell.stateTF.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                if zipNum == "" {
//                    cell.zipTF.attributedPlaceholder = NSAttributedString(string: "90001",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
//                } else {
//                    cell.zipTF.text = zipNum
//                }
//                cell.zipTF.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                cell.delegate = self
//                return cell
//            case .startShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
//                cell.delegate = self
//                cell.myShift = myShift
//                cell.subjectL.text = "Discussion"
//                cell.descriptionTV.text = startShiftStructure.ssDiscussion
//                return cell
//            case .endShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
//                cell.delegate = self
//                cell.myShift = myShift
//                cell.subjectL.text = "Discussion"
//                cell.descriptionTV.text = endShiftStructure.esDiscussion
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//                return cell
//            }
//        case 8:
//            switch myShift {
//            case .incidents?:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "AddressFieldsButtonsCell", for: indexPath) as! AddressFieldsButtonsCell
//                cell.subjectL.text = "Address"
//                if streetName == "" {
//                    cell.addressTF.attributedPlaceholder = NSAttributedString(string: "100 Main Street",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                } else {
//                    cell.addressTF.text = "\(streetNum) \(streetName)"
//                }
//                cell.addressTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                if city == "" {
//                    cell.cityTF.attributedPlaceholder = NSAttributedString(string: "Los Angeles",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                } else {
//                    cell.cityTF.text = city
//                }
//                cell.cityTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                if stateName == "" {
//                    cell.stateTF.attributedPlaceholder = NSAttributedString(string: "CA",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                } else {
//                    cell.stateTF.text = stateName
//                }
//                cell.stateTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                if zipNum == "" {
//                    cell.zipTF.attributedPlaceholder = NSAttributedString(string: "90001",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                } else {
//                    cell.zipTF.text = zipNum
//                }
//                cell.zipTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.delegate = self
//                return cell
//            case .incidentSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
//                cell.delegate = self
//                if(showMap) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 500)
//                    )
//                    cell.contentView.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.contentView.frame = frame
//                }
//                return cell
//            case .ics214Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
//                cell.delegate = self
//                if(showPicker) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 216)
//                    )
//                    cell.dateHolderV.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.dateHolderV.frame = frame
//                }
//                return cell
//            case .alarmSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "AddressSearchButtonsCell", for: indexPath) as! AddressSearchButtonsCell
//                cell.subjectL.text = "Address"
//                if streetName == "" {
//                    cell.addressL.attributedPlaceholder = NSAttributedString(string: "100 Main Street",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                } else {
//                    cell.addressL.text = "\(streetNum) \(streetName)"
//                }
//                cell.addressL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                if city == "" {
//                    cell.cityL.attributedPlaceholder = NSAttributedString(string: "Los Angeles",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                } else {
//                    cell.cityL.text = city
//                }
//                cell.cityL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                if stateName == "" {
//                    cell.stateL.attributedPlaceholder = NSAttributedString(string: "CA",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                } else {
//                    cell.stateL.text = stateName
//                }
//                cell.stateL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                if zipNum == "" {
//                    cell.zipL.attributedPlaceholder = NSAttributedString(string: "90001",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                } else {
//                    cell.zipL.text = zipNum
//                }
//                cell.zipL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.delegate = self
//                cell.myShift = myShift
//                cell.defaultOrNot = false
//                cell.switchType = .address
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .journal:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
//                cell.delegate = self
//                cell.subjectL.text = "Overview"
//                return cell
//            case .nfirsBasic1Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
//                cell.delegate = self
//                if(showMap) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 500)
//                    )
//                    cell.contentView.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.contentView.frame = frame
//                }
//                return cell
//            case .startShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Platoon"
//                cell.myShift = myShift
//                cell.switchType = .platoon
//                cell.defaultOvertimeL.text = startShiftStructure.ssPlatoon
//                cell.switched = startShiftStructure.ssPlatoonB
//                cell.answerL.text = startShiftStructure.ssPlatoonTF
//                cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
//                cell.descriptionL.text = "Select the plaoon your working today"
//                switch myShift {
//                case .startShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                case .endShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                default:
//                    print("no shift")
//                }
//                return cell
//            case .endShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Platoon"
//                cell.myShift = myShift
//                cell.switchType = .platoon
//                cell.defaultOvertimeL.text = endShiftStructure.esPlatoon
//                cell.switched = endShiftStructure.esPlatoonB
//                cell.answerL.text = endShiftStructure.esPlatoonTF
//                cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
//                cell.descriptionL.text = "Select the plaoon your working today"
//                switch myShift {
//                case .startShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                case .endShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                default:
//                    print("no shift")
//                }
//                if(updateTapped) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 85)
//                    )
//                    cell.contentView.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.contentView.frame = frame
//                }
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//                return cell
//            }
//
//        case 9:
//            switch myShift {
//            case .incidents?:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
//                cell.delegate = self
//                if(showMap) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 500)
//                    )
//                    cell.contentView.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.contentView.frame = frame
//                }
//                return cell
//            case .incidentSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDirectionalTVSwitchCell", for: indexPath) as! LabelDirectionalTVSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "NFIRS Incident Type"
//                cell.descriptionTV.textColor =  UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)
//                cell.descriptionTV.text = "121 Fire in mobile home used as a fixed residence. Includes mobile homes when not in transit and used as a structure for residential purposes; and manufactured homes built on a permanent chassis."
//                let image = UIImage(named: "ICONS_Directional red")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.defaultOvertimeL.text = "Off"
//                cell.myShift = myShift
//                cell.defaultOvertimeB = false
//                cell.myShift = .nfirsBasic1Search
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .ics214Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeSearchSwitchButtonCell", for: indexPath) as! LabelDateTimeSearchSwitchButtonCell
//                cell.delegate = self
//                cell.descriptionTF.text = startShift?.startTime
//                cell.subjectL.text = "Date To"
//                let image = UIImage(named: "ICONS_TimePiece")
//                cell.clockB.setImage(image, for: .normal)
//                cell.descriptionTF.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)
//                cell.myShift = myShift
//                cell.defaultOrNot = false
//                cell.switchType = .dateTime
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .alarmSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
//                cell.delegate = self
//                if(showMap) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 500)
//                    )
//                    cell.contentView.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.contentView.frame = frame
//                }
//                return cell
//            case .journal:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
//                cell.delegate = self
//                cell.subjectL.text = "User"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "Mark Smith"
//                return cell
//            case .nfirsBasic1Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Platoon"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "C-Platoon"
//                let image = UIImage(named: "ICONS_Directional blue")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.myShift = myShift
//                cell.defaultOrNote = false
//                cell.switchType = .platoon
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .startShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Fire Station"
//                cell.myShift = myShift
//                cell.switchType = .fireStation
//                cell.defaultOvertimeL.text = startShiftStructure.ssFireStation
//                cell.switched = startShiftStructure.ssFireStationB
//                cell.answerL.text = startShiftStructure.ssFireStationTF
//                cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
//                cell.descriptionL.text = "Select or set up Fire Station you’re working at today."
//                switch myShift {
//                case .startShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                case .endShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                default:
//                    print("no shift")
//                }
//                return cell
//            case .endShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Fire Station"
//                cell.myShift = myShift
//                cell.switchType = .fireStation
//                cell.defaultOvertimeL.text = endShiftStructure.esFireStation
//                cell.switched = endShiftStructure.esFireStationB
//                cell.answerL.text = endShiftStructure.esFireStationTF
//                cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
//                cell.descriptionL.text = "Select or set up Fire Station you’re working at today."
//                switch myShift {
//                case .startShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                case .endShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                    if(updateTapped) {
//                        let frame = CGRect(
//                            origin: CGPoint(x: 0, y: 0),
//                            size: CGSize(width: tableView.frame.size.width, height: 85)
//                        )
//                        cell.contentView.frame = frame
//                    } else {
//                        let frame = CGRect(
//                            origin: CGPoint(x: 0, y: 0),
//                            size: CGSize(width: tableView.frame.size.width, height: 0)
//                        )
//                        cell.contentView.frame = frame
//                    }
//                default:
//                    print("no shift")
//                }
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//                return cell
//            }
//        case 10:
//            switch myShift {
//            case .incidents?:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentTextViewWithDirectionalCell", for: indexPath) as! IncidentTextViewWithDirectionalCell
//                cell.delegate = self
//                cell.subjectL.text = "NFIRS Incident Type"
//                cell.descriptionTV.textColor =  UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)
//                cell.descriptionTV.text = "121 Fire in mobile home used as a fixed residence. Includes mobile homes when not in transit and used as a structure for residential purposes; and manufactured homes built on a permanent chassis."
//                let image = UIImage(named: "ICONS_Directional red")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.myShift = .incidents
//                return cell
//            case .incidentSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Local Incident Type"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "Structure Fire"
//                let image = UIImage(named: "ICONS_Directional red")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.myShift = myShift
//                cell.defaultOrNote = false
//                cell.switchType = .localIncidentType
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .ics214Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
//                cell.delegate = self
//                if(showPicker) {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 216)
//                    )
//                    cell.dateHolderV.frame = frame
//                } else {
//                    let frame = CGRect(
//                        origin: CGPoint(x: 0, y: 0),
//                        size: CGSize(width: tableView.frame.size.width, height: 0)
//                    )
//                    cell.dateHolderV.frame = frame
//                }
//                return cell
//            case .journal:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
//                cell.delegate = self
//                cell.subjectL.text = "Entry Type"
//                cell.descriptionTF.textColor = UIColor.black
//                if journalStructure.journalType != "" {
//                    cell.descriptionTF.text = journalStructure.journalType
//                } else {
//                    cell.descriptionTF.placeholder = "Station"
//                }
//                return cell
//            case .nfirsBasic1Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Crew"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "FF Smith, FF Marks"
//                let image = UIImage(named: "ICONS_Directional blue")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.myShift = myShift
//                cell.defaultOrNote = false
//                cell.switchType = .crew
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .startShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Assignment"
//                cell.myShift = myShift
//                cell.switchType = .assignment
//                cell.defaultOvertimeL.text = startShiftStructure.ssAssignment
//                cell.switched = startShiftStructure.ssAssignmentB
//                cell.answerL.text = startShiftStructure.ssAssignmentTF
//                cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
//                cell.descriptionL.text = "Select or set up your assignment"
//                switch myShift {
//                case .startShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                case .endShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                default:
//                    print("no shift")
//                }
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//                return cell
//            }
//        case 11:
//            switch myShift {
//            case .incidents?:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
//                cell.delegate = self
//                cell.subjectL.text = "Local Incident Type"
//                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                let image = UIImage(named: "ICONS_Directional red")
//                cell.moreB.setImage(image, for: .normal)
//                return cell
//            case .incidentSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Platoon"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "C-Platoon"
//                let image = UIImage(named: "ICONS_Directional red")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.myShift = myShift
//                cell.defaultOrNote = false
//                cell.switchType = .platoon
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .journal:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
//                cell.delegate = self
//                cell.subjectL.text = "Fire Station"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "01"
//                return cell
//            case .nfirsBasic1Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Fire Station"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "76"
//                let image = UIImage(named: "ICONS_Directional blue")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.myShift = myShift
//                cell.defaultOrNote = false
//                cell.switchType = .fireStation
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .startShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Apparatus"
//                cell.myShift = myShift
//                cell.switchType = .apparatus
//                cell.defaultOvertimeL.text = startShiftStructure.ssApparatus
//                cell.switched = startShiftStructure.ssApparatusB
//                cell.answerL.text = startShiftStructure.ssApparatusTF
//                cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
//                cell.descriptionL.text = "Select or set up the rig you are working with"
//                switch myShift {
//                case .startShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                case .endShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                default:
//                    print("no shift")
//                }
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//                return cell
//            }
//        case 12:
//            switch myShift {
//            case .incidents?:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
//                cell.delegate = self
//                cell.subjectL.text = "Location Type"
//                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                let image = UIImage(named: "ICONS_Directional red")
//                cell.moreB.setImage(image, for: .normal)
//                return cell
//            case .incidentSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Crew"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "FF Smith, FF Marks"
//                let image = UIImage(named: "ICONS_Directional red")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.myShift = myShift
//                cell.defaultOrNote = false
//                cell.switchType = .crew
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .journal:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
//                cell.delegate = self
//                cell.subjectL.text = "Platoon"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "B-Platoon"
//                let image = UIImage(named: "ICONS_Directional blue")
//                cell.moreB.setImage(image, for: .normal)
//                return cell
//            case .nfirsBasic1Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Tags"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "March, Emergency"
//                let image = UIImage(named: "ICONS_Directional blue")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.myShift = myShift
//                cell.defaultOrNote = false
//                cell.switchType = .tag
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .startShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Resources"
//                cell.myShift = myShift
//                cell.switchType = .resources
//                cell.defaultOvertimeL.text = startShiftStructure.ssResources
//                cell.switched = startShiftStructure.ssResourcesB
//                cell.answerL.text = startShiftStructure.ssResourcesTF
//                cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
//                cell.descriptionL.text = "Select or create the rigs in your station"
//                switch myShift {
//                case .startShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                case .endShift:
//                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
//                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
//                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                default:
//                    print("no shift")
//                }
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//                return cell
//            }
//        case 13:
//            switch myShift {
//            case .incidents?:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
//                cell.delegate = self
//                cell.subjectL.text = "Street Type"
//                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                let image = UIImage(named: "ICONS_Directional red")
//                cell.moreB.setImage(image, for: .normal)
//                return cell
//            case .incidentSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Fire Station"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "76"
//                let image = UIImage(named: "ICONS_Directional red")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.myShift = myShift
//                cell.defaultOrNote = false
//                cell.switchType = .fireStation
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .startShift:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewSwitchCell", for: indexPath) as! LabelTextViewSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Crew"
//                cell.myShift = .startShift
//                cell.switchType = .crew
//                cell.switchL.text = startShiftStructure.ssCrews
//                cell.answerTV.text = startShiftStructure.ssCrewsTF
//                cell.switched = startShiftStructure.ssCrewB
//                cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
//                cell.descriptionL.text = "Select your default crew"
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .journal:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
//                cell.delegate = self
//                cell.subjectL.text = "Assignment"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "Chief Officer"
//                let image = UIImage(named: "ICONS_Directional blue")
//                cell.moreB.setImage(image, for: .normal)
//                return cell
//            case .nfirsBasic1Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDirectionalTVSwitchCell", for: indexPath) as! LabelDirectionalTVSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "NFIRS Incident Type"
//                cell.descriptionTV.textColor =  UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)
//                cell.descriptionTV.text = "121 Fire in mobile home used as a fixed residence. Includes mobile homes when not in transit and used as a structure for residential purposes; and manufactured homes built on a permanent chassis."
//                let image = UIImage(named: "ICONS_Directional blue")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.defaultOvertimeL.text = "Off"
//                cell.myShift = myShift
//                cell.defaultOvertimeB = false
//                cell.myShift = .nfirsBasic1Search
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//                return cell
//            }
//        case 14:
//            switch myShift {
//            case .incidents?:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
//                cell.delegate = self
//                cell.subjectL.text = "Street Prefix"
//                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
//                let image = UIImage(named: "ICONS_Directional red")
//                cell.moreB.setImage(image, for: .normal)
//                return cell
//            case .incidentSearch:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Tags"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "Emergency, March"
//                let image = UIImage(named: "ICONS_Directional red")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.myShift = myShift
//                cell.defaultOrNote = false
//                cell.switchType = .tag
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            case .journal:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
//                cell.delegate = self
//                cell.subjectL.text = "Apparatus"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "Engine"
//                let image = UIImage(named: "ICONS_Directional blue")
//                cell.moreB.setImage(image, for: .normal)
//                return cell
//            case .nfirsBasic1Search:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
//                cell.delegate = self
//                cell.subjectL.text = "Local Incident Type"
//                cell.descriptionTF.textColor = UIColor.black
//                cell.descriptionTF.placeholder = "Structure Fire"
//                let image = UIImage(named: "ICONS_Directional blue")
//                cell.directionalB.setImage(image, for: .normal)
//                cell.myShift = myShift
//                cell.defaultOrNote = false
//                cell.switchType = .localIncidentType
//                cell.defaultOvertimeL.text = "Off"
//                cell.defaultOvertimeSwitch.setOn(false, animated: true)
//                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
//                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
//                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//                return cell
//            }
//        default:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! startShiftOvertimeSwitchCell
//            return cell
//        }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! startShiftOvertimeSwitchCell
            return cell
    }
    
}
