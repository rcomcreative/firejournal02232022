//
//  ARC_FormTVC+Extensions.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 8/27/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import T1Autograph

extension ARC_FormTVC {
    
    //    MARK: -SHARE-
    /// present the pdf link that has been created for the form
    /// - Parameter ns: userInfo has pdf link for sharing of form pdf
    @objc func deliverTheShare(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            self.pdfLink = userInfo["pdfLink"] as? String ?? ""
            let items = [ self.pdfLink ]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            if let pc = ac.popoverPresentationController {
                pc.barButtonItem = saveButton
            }
             self.present(ac, animated: true, completion: nil)
        }
    }
    
    //    MARK: -REGISTERCELLS-
    
    /// 17 Cells are used in this form the cellResueIdentifier is the same as the class name
    func registerCells() {
        tableView.register(UINib(nibName: "ARC_AddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "ARC_AddressFieldsButtonsCell")
        tableView.register(UINib(nibName: "ARC_AdminSegmentCell", bundle: nil), forCellReuseIdentifier: "ARC_AdminSegmentCell")
        tableView.register(UINib(nibName: "ARC_TextViewCell", bundle: nil), forCellReuseIdentifier: "ARC_TextViewCell")
        tableView.register(UINib(nibName: "ARC_DateTimeAdminCell", bundle: nil), forCellReuseIdentifier: "ARC_DateTimeAdminCell")
        tableView.register(UINib(nibName: "ARC_LabelCell", bundle: nil), forCellReuseIdentifier: "ARC_LabelCell")
        tableView.register(UINib(nibName: "ARC_LabelExpandedCell", bundle: nil), forCellReuseIdentifier: "ARC_LabelExpandedCell")
        tableView.register(UINib(nibName: "ARC_LabelExtendedTextFieldCell", bundle: nil), forCellReuseIdentifier: "ARC_LabelExtendedTextFieldCell")
        tableView.register(UINib(nibName: "ARC_LabelTextViewCell", bundle: nil), forCellReuseIdentifier: "ARC_LabelTextViewCell")
        tableView.register(UINib(nibName: "ARC_MapViewCell", bundle: nil), forCellReuseIdentifier: "ARC_MapViewCell")
        tableView.register(UINib(nibName: "ARC_DatePickerCell", bundle: nil), forCellReuseIdentifier: "ARC_DatePickerCell")
        tableView.register(UINib(nibName: "ARC_DateTimeCell", bundle: nil), forCellReuseIdentifier: "ARC_DateTimeCell")
        tableView.register(UINib(nibName: "ARC_HeadCell", bundle: nil), forCellReuseIdentifier: "ARC_HeadCell")
        tableView.register(UINib(nibName: "ARC_arcLabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "ARC_arcLabelTextFieldCell")
        tableView.register(UINib(nibName: "ARC_SignatureCell", bundle: nil), forCellReuseIdentifier: "ARC_SignatureCell")
        tableView.register(UINib(nibName: "ARC_QuestionWSwitch", bundle: nil), forCellReuseIdentifier: "ARC_QuestionWSwitch")
        tableView.register(UINib(nibName: "ARC_StepperTFCell", bundle: nil), forCellReuseIdentifier: "ARC_StepperTFCell")
        tableView.register(UINib(nibName: "ARC_CampaignResidenceTypeCell", bundle: nil), forCellReuseIdentifier: "ARC_CampaignResidenceTypeCell")
    }
    
    //    MARK: -Build the form with object-
    func buildWithObject() {
        arcFormToCloud = ARCFormToCloud.init(context)
        newTheCells = cellsForForm.cells
        registerCells()
        if let form = context.object(with: objectID!) as? ARCrossForm {
            self.theForm = form
            if self.theForm.campaignName == "Single" {
                singleOrCampaign = true
            } else {
                singleOrCampaign = false
            }
            if self.theForm.residentSignature != nil {
                residentSignature = true
            }
            if self.theForm.installerSignature != nil {
                installerSignature = true
            }
            let user = userDefaults.bool(forKey: FJkFJUSERSavedToCoreDataFromCloud)
            if user {
                fireJournalUser = getTheUser()
            }
        }
    }
    
    //    MARK: -Build new Single Form-
    func buildNewSingleForm() {
        arcFormToCloud = ARCFormToCloud.init(context)
        newTheCells = cellsForForm.cells
        registerCells()
        singleOrCampaign = true
        self.theForm = ARCrossForm(context: context)
        self.theResidence = Residence(context: context)
        self.theLocalPartners = LocalPartners(context: context)
        self.theNationalPartners = NationalPartners(context: context)
        self.theForm.arcMaster = true
        let creationDate = Date()
        self.theForm.arcFormCampaignGuid = self.theForm.guidForCampaign(creationDate, dateFormatter: self.dateFormatter)
        self.theForm.arcFormGuid = self.theForm.guidForARCForm(creationDate, dateFormatter: self.dateFormatter)
        self.theForm.arcCreationDate = creationDate
        self.theForm.cStartDate = creationDate
        self.theForm.receiveSPM = false
        self.theForm.recieveEP = false
        self.theForm.reviewFEPlan = false
        self.theForm.createFEPlan = false
        self.theForm.localHazard = false
        self.theForm.residentContactInfo = false
        self.theForm.residentSigned = false
        self.theForm.installerSigend = false
        self.theForm.arcBackup = false
        self.theForm.arcMaster = true
        self.theForm.campaignCount = 0
        self.theForm.campaign = false
        self.theForm.cComplete = false
        self.theForm.campaignName = "Single"
        self.theForm.arcLocationAptMobile = "NA"
        self.theForm.arcPortalSystem = "ARC ORP"
        
        self.theForm.addToArCrossFormInfo(theNationalPartners)
        self.theForm.addToLocalPartnerInto(theLocalPartners)
        self.theForm.addToResidentsInfo(theResidence)
        
        let user = userDefaults.bool(forKey: FJkFJUSERSavedToCoreDataFromCloud)
        if user {
            fireJournalUser = getTheUser()
        }
        journal = Journal(context: context)
        journal.fjpJGuidForReference = journal.guidForJournal( creationDate, dateFormatter: dateFormatter)
        journal.journalModDate = creationDate
        journal.fjpJournalModifiedDate = creationDate
        journal.journalCreationDate = creationDate
        self.theForm.journalGuid = journal.fjpJGuidForReference
        journal.arcFormMasterGuid = self.theForm.arcFormCampaignGuid
        journal.journalEntryTypeImageName = "administrativeNewColor58"
        journal.journalEntryType = "Station"
        journal.journalHeader = "Smoke Alarm Installation Form Campaign: Single"
        let timeStamp = journal.journalFullDateFormatted(creationDate, dateFormatter: dateFormatter)
        var summary: String = ""
        if fireJournalUser != nil {
            var name: String = ""
            if let first = fireJournalUser.firstName {
                name = first
            }
            if let last = fireJournalUser.lastName {
                name = "\(name) \(last)"
            }
            summary = "Time Stamp: \(timeStamp) Smoke Alarm Inspection Form: Single Master entered by \(name)"
            let platoon = fireJournalUser.tempPlatoon  ?? ""
            journal.journalTempPlatoon = platoon
            let assignment = fireJournalUser.tempAssignment ?? ""
            journal.journalTempAssignment = assignment
            let apparatus = fireJournalUser.tempApparatus ?? ""
            journal.journalTempApparatus = apparatus
            let fireStation = fireJournalUser.tempFireStation ?? fireJournalUser.fireStation ?? ""
            journal.journalTempFireStation = fireStation
        } else {
            summary = "Time Stamp: \(timeStamp) Smoke Alarm Inspection Form: Single Master"
        }
        
        journal.journalSummary = summary as NSObject
        let overview = "Smoke Alarm Inspection Form entered"
        journal.journalOverview = overview as NSObject
        journal.journalEntryType = "Station"
        journal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        
        journal.journalDateSearch = timeStamp
        journal.journalCreationDate = creationDate
        journal.journalModDate = creationDate
        journal.journalPrivate = true
        journal.journalBackedUp = false
        theForm.journalDetail = journal
    }
    
    //    MARK: -CONFIGURE CELLS-
    
    /// ARC_AddressFieldsButtonsCell with map and location buttons
    /// - Parameters:
    ///   - cell: ARC_AddressFieldsButtonsCell
    ///   - indexPath: indexPath
    ///   - tag: cell tag
    /// - Returns: configured ARC_AddressFieldsButtonsCell with delegate assigned can call mapcellview to be opened
    func configureARC_AddressFieldsButtonsCell(_ cell: ARC_AddressFieldsButtonsCell, at indexPath: IndexPath, tag: Int) -> ARC_AddressFieldsButtonsCell {
        cell.subjectL.text = "Address"
        cell.delegate = self
        if theForm != nil {
            if let number = theForm.arcLocationStreetNum {
                if number != "" {
                    cell.streetNumTF.text = number
                }
            } else {
                if let address = theForm.arcLocationAddress {
                    if address != "" {
                        let number = address.components(separatedBy: " ").first
                        cell.streetNumTF.text = number
                        theForm.arcLocationStreetNum = number
                    }
                }
            }
            if let name = theForm.arcLocationStreetName {
                if name != "" {
                    cell.streetNameTF.text = name
                }
            } else {
                if let address = theForm.arcLocationAddress {
                    if address != "" {
                        let number = address.components(separatedBy: " ").first
                        var count = number?.count ?? 0
                        count = count + 1
                        let theStreet = String(address.dropFirst(count))
                        cell.streetNameTF.text = theStreet
                        theForm.arcLocationStreetNum = theStreet
                    }
                }
            }
            if let apt = theForm.arcLocationAptMobile {
                cell.aptMobileNumberTF.text = apt
            }
            if let city = theForm.arcLocationCity {
                cell.cityTF.text = city
            }
            if let theState = theForm.arcLocaitonState {
                cell.stateTF.text = theState
            }
            if let theZip = theForm.arcLocationZip {
                cell.zipTF.text = theZip
            }
            if let latitude = theForm.arcLocationLatitude {
                cell.addressLatitudeTF.text = latitude
            }
            if let longitude = theForm.arcLocationLongitude {
                cell.addressLongitudeTF.text = longitude
            }
            if let apt = theForm.arcLocationAptMobile {
                cell.aptMobileNumberTF.text = apt
            }
        }
        cell.streetNumTF.placeholder = "100"
        cell.streetNameTF.placeholder = "Main Street"
        cell.aptMobileNumberTF.placeholder = "Mark NA if not applicable"
        cell.cityTF.placeholder = "Your Town"
        cell.stateTF.placeholder = "Your State"
        cell.zipTF.placeholder = "90001"
        cell.addressLatitudeTF.placeholder = "34.05223"
        cell.addressLongitudeTF.placeholder = "-118.24368"
        return cell
    }
    
    
    /// ARC_AdminSegmentCell configured with title and past segment choice
    /// - Parameters:
    ///   - cell: ARC_AdminSegmentCell
    ///   - indexPath: placement on the form
    ///   - tag: cell tag
    /// - Returns: configured ARC_AdminSegmentCell with delegate assigned
    func configureARC_AdminSegmentCell(_ cell: ARC_AdminSegmentCell, at indexPath: IndexPath, tag: Int) ->ARC_AdminSegmentCell {
        cell.path = indexPath
        cell.delegate = self
        switch tag {
        case 51:
            cell.subjectL.text = "What portal system?"
            if theForm.arcPortalSystem == "ARC ORP" {
                cell.theType = ARC_FormType.arcOrp
            } else if theForm.arcPortalSystem == "MySmokeAlarm" {
                cell.theType = ARC_FormType.mySmokeAlarm
            } else if theForm.arcPortalSystem ==  "Other" {
                cell.theType = ARC_FormType.other
            } else {
                cell.theType = ARC_FormType.arcOrp
            }
        default: break
        }
        return cell
    }
    
    
    /// ARC_TextViewCell label and text view
    /// - Parameters:
    ///   - cell: ARC_TextViewCell
    ///   - indexPath: indexPath placement in form
    ///   - tag: cell tag
    /// - Returns: configured ARC_TextViewCell with delegate assigned
    func configureARC_TextViewCell(_ cell: ARC_TextViewCell, at indexPath: IndexPath, tag: Int) ->ARC_TextViewCell {
        cell.notesTV.text = ""
        cell.delegate = self
        switch tag {
        case 16:
            cell.titleL.text = "If yes, what hazard?"
            if let hazard = theForm.hazard {
                cell.notesTV.text = hazard
            }
        case 35:
            cell.titleL.text = "Additional Notes"
            if let notes = theForm.iaNotes {
                cell.notesTV.text = notes
            }
        default: break
        }
        return cell
    }
    
    
    /// ARC_DateTimeAdminCell with label and text field and time button
    /// - Parameters:
    ///   - cell: ARC_DateTimeAdminCell
    ///   - indexPath: indexPath on the form
    ///   - tag: cell tag
    /// - Returns: configured ARC_DateTimeAdminCell with delegate button sends out  call to open datepicker
    func configureARC_DateTimeAdminCell(_ cell: ARC_DateTimeAdminCell, at indexPath: IndexPath, tag: Int) -> ARC_DateTimeAdminCell {
        cell.delegate = self
        cell.path = indexPath
        switch tag {
        case 49:
            cell.subjectL.text = "What date was the record entered into the appropriate online system?"
            
            if let date = theForm.adminDate {
                dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                let adminDate = dateFormatter.string(from: date)
                cell.described = adminDate
            }
        default: break
        }
        return cell
    }
    
    
    /// ARC_LabelCell is used as section headers - font size is 24
    /// - Parameters:
    ///   - cell: ARC_LabelCell
    ///   - indexPath: indexPath on the form
    ///   - tag: cell tag
    /// - Returns: configured cell with section title no delegate
    func configureARC_LabelCell(_ cell: ARC_LabelCell, at indexPath: IndexPath, tag: Int) ->ARC_LabelCell {
        switch tag {
        case 4:
            cell.modalTitleL.text = "Services Provided"
        case 26:
            cell.modalTitleL.text = "Initial Visit Assessment"
        case 36:
            cell.modalTitleL.text = "Agency/Partner Reporting"
        default: break
        }
        return cell
    }
    
    
    /// ARC_LabelExpandedCell section header with two or more lines of text font size 24
    /// - Parameters:
    ///   - cell: ARC_LabelExpandedCell
    ///   - indexPath: IndexPath on the form
    ///   - tag: cell tag
    /// - Returns: configured ARC_LabelExpandedCell with section header no delegate
    func configureARC_LabelExpandedCell(_ cell: ARC_LabelExpandedCell, at indexPath: IndexPath, tag: Int) ->ARC_LabelExpandedCell {
        switch tag {
        case 8:
            cell.subjectL.text = "Carbon Monoxide\nDetectors"
        case 10:
            cell.subjectL.text = "Fire/Life Safety\nMaterials"
        case 39:
            cell.subjectL.text = "Region Designated Reporting Fields"
        case 42:
            cell.subjectL.text = "Information for Future Follow-Up"
        default: break
        }
        return cell
    }
    
    
    /// ARC_LabelExtendedTextFieldCell 2 or more lines for the subject with textfield answer
    /// - Parameters:
    ///   - cell: ARC_LabelExtendedTextFieldCell
    ///   - indexPath: indexPath on form
    ///   - tag: cell tag
    /// - Returns: configured ARC_LabelExtendedTextFieldCell with delegate for text field
    func configureARC_LabelExtendedTextFieldCell(_ cell: ARC_LabelExtendedTextFieldCell, at indexPath: IndexPath, tag: Int) ->ARC_LabelExtendedTextFieldCell {
        cell.delegate = self
        switch tag {
        case 48:
            cell.label = "Who entered the record into the appropriate online system?"
            if let name = theForm.adminName {
                cell.answer = name
            }
        default: break
        }
        return cell
    }
    
    
    /// ARC_LabelTextViewCell subject and textView used for notes on form
    /// - Parameters:
    ///   - cell: ARC_LabelTextViewCell
    ///   - indexPath: indexPath on form
    ///   - tag: cell tag
    /// - Returns: configured ARC_LabelTextViewCell with delegate for TextView
    func configureARC_LabelTextViewCell(_ cell: ARC_LabelTextViewCell, at indexPath: IndexPath, tag: Int) ->ARC_LabelTextViewCell {
        switch tag {
        case 17:
            cell.subjectL.text = "Resident Acknowledgement"
            cell.descriptionTV.text = FJkARCCrossDECLARATION
        case 47:
            cell.subjectL.text = "Administrative Section"
            cell.descriptionTV.text = FJkARCCrossAdministrative
        default: break
        }
        return cell
    }
    
    
    /// ARC_MapViewCell map for choosing the address and location of the form with two buttons
    /// - Parameters:
    ///   - cell: ARC_MapViewCell
    ///   - indexPath: indexPath on form
    ///   - tag: cell tag
    /// - Returns: configured ARC_MapViewCell with delegated buttons - one for using the address chosen and send  back to form, info button calls for alert to be shown explaining the useage of the map
    func configureARC_MapViewCell(_ cell: ARC_MapViewCell, at indexPath: IndexPath, tag: Int) ->ARC_MapViewCell {
        cell.delegate = self
        if !showMap {
            cell.mapShow = true
        }
        cell.pinImageName = "CRRAlarmPin"
        
        /// arcLocation unarchived from secureCodeing
        if theForm.arcLocationSC != nil {
            
            if let location = theForm.arcLocationSC {
                guard let  archivedData = location as? Data else { return cell }
                do {
                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return  cell }
                    let location:CLLocation = unarchivedLocation
                    cell.theCurrentLocation = location
                } catch {
                    print("something's going on here")
                }
            }
        }
        return cell
    }
    
    
    /// ARC_DatePickerCell used to get date for signatures and for closing the form
    /// - Parameters:
    ///   - cell: ARC_DatePickerCell
    ///   - indexPath: indexPath on form
    ///   - tag: cell tag
    /// - Returns: configured ARC_DatePickerCell is closed and opened with boolean assigned, date time is sent to delegate
    func configureARC_DatePickerCell(_ cell: ARC_DatePickerCell, at indexPath: IndexPath, tag: Int) ->ARC_DatePickerCell {
        cell.delegate = self
        cell.path = indexPath
        switch tag {
        case 21:
            if theForm.residentSigDate != nil {
                cell.pDate = theForm.residentSigDate
            }
        case 25:
            if theForm.installerDate != nil {
                cell.pDate = theForm.installerDate
            }
        case 50:
            if theForm.adminDate != nil {
                cell.pDate = theForm.adminDate
            }
        default: break
        }
        return cell
    }
    
    
    /// ARC_DateTimeCell used for signature date time button closes and opens datePicker
    /// - Parameters:
    ///   - cell: ARC_DateTimeCell
    ///   - indexPath: indexPath on form
    ///   - tag: cell tag
    /// - Returns: configure ARC_DateTimeCell with delegate, time and date for signatures for installer and resident
    func configureARC_DateTimeCell(_ cell: ARC_DateTimeCell, at indexPath: IndexPath, tag: Int) ->ARC_DateTimeCell {
        cell.delegate = self
        cell.path = indexPath
        switch tag {
        case 20:
            cell.dateL.text = "Resident Signature Date"
            if let date = theForm.residentSigDate {
                dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                let signatureDate = dateFormatter.string(from: date)
                cell.dateT = signatureDate
            }
        case 24:
            cell.dateL.text = "Installation Agent Signature Date"
            if let date = theForm.installerDate {
                dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                let signatureDate = dateFormatter.string(from: date)
                cell.dateT = signatureDate
            }
        default: break
        }
        return cell
    }
    
    
    /// ARC_HeadCell includes, share, info buttons, campaign switch, icon, campaign name, address, date
    /// - Parameters:
    ///   - cell: ARC_HeadCell
    ///   - indexPath: indexPath on form
    ///   - tag: cell tag
    /// - Returns: configure ARC_HeadCell with delegate for share, info buttons and campaign switch
    func configureARC_HeadCell(_ cell: ARC_HeadCell, at indexPath: IndexPath, tag: Int) ->ARC_HeadCell {
        cell.delegate = self
        let campaignCount = theForm.campaignCount
        var theCount = 0
        if campaignCount > 1 {
            theCount = Int(campaignCount)
        }
        cell.path = indexPath
        var campaignDate: String = ""
        if let date = theForm.arcCreationDate {
            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
            campaignDate = dateFormatter.string(from: date)
        }
        if campaignDate == "" {
            let date = Date()
            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
            campaignDate = dateFormatter.string(from: date)
        }
        cell.dateL.text = campaignDate
        if let campaign = theForm.campaignName {
            if theCount != 0 {
                cell.formNameL.text = "\(campaign) \(theCount)"
            } else {
                cell.formNameL.text = campaign
            }
        }
        if let address = theForm.arcLocationAddress {
            cell.campaignTypeL.text = address
        }
        
        if theForm.cComplete {
            cell.campaign = false
            cell.cText = "Campaign Closed"
        } else {
            cell.campaign = true
            cell.cText = "Campaign Open"
        }
        
        if singleOrCampaign {
            cell.campaignSwitch.isHidden = true
            cell.campaignSwitch.alpha = 0.0
            cell.campaignSwitch.isEnabled = false
            cell.infoB.isHidden = true
            cell.infoB.alpha = 0.0
            cell.infoB.isEnabled = false
        }
        
        cell.firstRun = firstForm
        
        return cell
    }
    
    
    /// ARC_arcLabelTextFieldCell subject label, answer text field, delegate for textField
    /// - Parameters:
    ///   - cell: ARC_arcLabelTextFieldCell
    ///   - indexPath: indexPath for form
    ///   - tag: cell tag
    /// - Returns: configured ARC_arcLabelTextFieldCell with delegate
    func configureARC_arcLabelTextFieldCell(_ cell: ARC_arcLabelTextFieldCell, at indexPath: IndexPath, tag: Int) ->ARC_arcLabelTextFieldCell {
        cell.path = indexPath
        cell.delegate = self
        cell.descriptionTF.text = ""
        switch tag {
        case 18:
            cell.subjectL.text = "Resident’s Printed Name"
            if let name = theForm.residentName {
                cell.descriptionTF.text = name
            }
        case 22:
            checkForDefaultInstallerName()
            cell.subjectL.text = "Installation Agency Printed Name"
            if let name = theForm.installerName {
                cell.descriptionTF.text = name
            }
        case 40:
            cell.subjectL.text = "Optional 1"
            if let name = theForm.option1 {
                cell.descriptionTF.text = name
            }
        case 41:
            cell.subjectL.text = "Optional 2"
            if let name = theForm.option2 {
                cell.descriptionTF.text = name
            }
        case 44:
            cell.subjectL.text = "eMail Address"
            if let name = theForm.residentEmail {
                cell.descriptionTF.text = name
            }
        case 45:
            cell.subjectL.text = "Mobile Phone #"
            if let name = theForm.residentCellNum {
                cell.descriptionTF.text = name
            }
        case 46:
            cell.subjectL.text = "Other Phone #"
            if let name = theForm.residentOtherPhone {
                cell.descriptionTF.text = name
            }
        default: break
        }
        return cell
    }
    
    
    /// ARC_SignatureCell signature button, delegate and imageView for signature
    /// - Parameters:
    ///   - cell: ARC_SignatureCell
    ///   - indexPath: indexPath on the form
    ///   - tag: cell tag
    /// - Returns: configure ARC_SignatureCell delegate to call signature framework to capture resident and installer signatures.
    func configureARC_SignatureCell(_ cell: ARC_SignatureCell, at indexPath: IndexPath, tag: Int) ->ARC_SignatureCell {
        cell.delegate = self
        cell.path = indexPath
        switch tag {
        case 19:
            cell.signatureB.setTitle("Resident's Signature", for: .normal)
            if residentSignature {
                if theForm.residentSignature != nil {
                    let imageUIImage: UIImage = UIImage(data: theForm.residentSignature!)!
                    cell.sImage = imageUIImage
                }
            }
        case 23:
            cell.signatureB.setTitle("Installation Agent's Signature", for: .normal)
            if installerSignature {
                if theForm.installerSignature != nil {
                    let imageUIImage: UIImage = UIImage(data: theForm.installerSignature!)!
                    cell.sImage = imageUIImage
                }
            }
        default: break
        }
        return cell
    }
    
    
    /// ARC_QuestionWSwitch delegate for switch and subject label
    /// - Parameters:
    ///   - cell: ARC_QuestionWSwitch
    ///   - indexPath: indexPath on form
    ///   - tag: cell tag
    /// - Returns: configure ARC_QuestionWSwitch with delegate for switch
    func configureARC_QuestionWSwitch(_ cell: ARC_QuestionWSwitch, at indexPath: IndexPath, tag: Int) ->ARC_QuestionWSwitch {
        cell.path = indexPath
        cell.delegate = self
        switch tag {
        case 11:
            cell.questionL.text = "Did the resident receive fire / life safety print materials?"
            if theForm.receiveSPM {
                cell.theSwitch = true
            } else {
                cell.theSwitch = false
            }
        case 12:
            cell.questionL.text = "Did the resident receive a print escape plan?"
            if theForm.recieveEP {
                cell.theSwitch = true
            } else {
                cell.theSwitch = false
            }
        case 13:
            cell.questionL.text = "Did the resident(s) create a fire escape plan?"
            if theForm.createFEPlan {
                cell.theSwitch = true
            } else {
                cell.theSwitch = false
            }
        case 14:
            cell.questionL.text = "Did the resident(s) review a Home Fire Safety Checklist?"
            if theForm.reviewFEPlan {
                cell.theSwitch = true
            } else {
                cell.theSwitch = false
            }
        case 15:
            cell.questionL.text = "Did the resident(s) learn about a local hazard?"
            if theForm.localHazard {
                cell.theSwitch = true
            } else {
                cell.theSwitch = false
            }
        case 43:
            cell.questionL.text = "Did the resident provide contact information?"
            if theForm.residentContactInfo {
                cell.theSwitch = true
            } else {
                cell.theSwitch = false
            }
        default: break
        }
        return cell
    }
    
    
    /// ARC_StepperTFCell subject label, stepper with delegate, textfield for stepper count, delegate for textfield
    /// - Parameters:
    ///   - cell: ARC_StepperTFCell
    ///   - indexPath: indexPath on form
    ///   - tag: cell tag
    /// - Returns: configure ARC_StepperTFCell delegate for when user taps stepper, updating the textfield with a string converted int
    func configureARC_StepperTFCell(_ cell: ARC_StepperTFCell, at indexPath: IndexPath, tag: Int) ->ARC_StepperTFCell {
        cell.delegate = self
        cell.path = indexPath
        if tag == 32 {
            print(tag)
        }
        switch tag {
        case 5:
            cell.questionL.text = "# of new sealed smoke alarms installed and tested?"
            if theForm.numNewSA != nil {
                if let counted = theForm.numNewSA {
                    cell.count = Double(counted)
                }
            } else {
                cell.count = 0
            }
        case 6:
            cell.questionL.text = "# of new bed shaker alarms installed and tested (DHH)"
            if theForm.numBedShaker != nil {
                if let counted = theForm.numBedShaker {
                    cell.count = Double(counted)
                }
            } else {
                cell.count = 0
            }
        case 7:
            cell.questionL.text = "# of new batteries replaced or provided"
            if theForm.numBatteries != nil {
                if let counted = theForm.numBatteries {
                    cell.count = Double(counted)
                }
            } else {
                cell.count = 0
            }
        case 9:
            cell.questionL.text = "# of new battery powered CO detectors installed and tested?"
            if theForm.numC02detectors != nil {
                if let counted = theForm.numC02detectors {
                    cell.count = Double(counted)
                }
            } else {
                cell.count = 0
            }
        case 27:
            cell.questionL.text = "How many people live here?"
            if theForm.iaNumPeople != nil {
                if let counted = theForm.iaNumPeople {
                    cell.count = Double(counted)
                }
            } else {
                cell.count = 0
            }
        case 28:
            cell.questionL.text = "How many persons age 17 and under live here?"
            if theForm.ia17Under != nil {
                if let counted = theForm.ia17Under {
                    cell.count = Double(counted)
                }
            } else {
                cell.count = 0
            }
        case 29:
            cell.questionL.text = "How many persons age 65 and older live here?"
            if theForm.ia65Over != nil {
                if let counted = theForm.ia65Over {
                    cell.count = Double(counted)
                }
            } else {
                cell.count = 0
            }
        case 30:
            cell.questionL.text = "How many persons with a disability, or an access or functional need live here?"
            if theForm.iaDisability != nil {
                if let counted = theForm.iaDisability {
                    cell.count = Double(counted)
                }
            } else {
                cell.count = 0
            }
        case 31:
            cell.questionL.text = "How many veterans, military members, or military family members live here?"
            if theForm.iaVets != nil {
                if let counted = theForm.iaVets {
                    cell.count = Double(counted)
                }
            } else {
                cell.count = 0
            }
        case 32:
            cell.questionL.text = "How many pre-existing smoke alarms does the household already have?"
            print("here is the tag \(tag)\n")
            if theForm.iaPrexistingSA != nil {
                if let counted = theForm.iaPrexistingSA {
                    cell.count = Double(counted)
                }
            } else {
                cell.count = 0
            }
        case 33:
            cell.questionL.text = "How many pre-existing smoke alarms are functional?"
            if theForm.iaWorkingSA != nil {
                if let counted = theForm.iaWorkingSA {
                    cell.count = Double(counted)
                }
            } else {
                cell.count = 0
            }
        case 34:
            cell.questionL.text = "How old are the pre-existing smoke alarms (in years)?"
            if theForm.iaHowOldSA != nil {
                if let counted = theForm.iaHowOldSA {
                    cell.count = Double(counted)
                }
            } else {
                cell.count = 0
            }
        default: break
        }
        return cell
    }
    
    
    /// Selection cell to gather residence, local and national partners
    /// - Parameters:
    ///   - cell: ARC_CampaignResidenceTypeCell
    ///   - indexPath: cells indexPath
    ///   - tag: cells tag
    /// - Returns: a cell to select and segue to TypeTVC with EntityType .residence, .localPartners, .nationalPartner
    func configureARC_CampaignResidenceTypeCell(_ cell: ARC_CampaignResidenceTypeCell, indexPath: IndexPath, tag: Int ) -> ARC_CampaignResidenceTypeCell {
        cell.path = indexPath
        switch tag {
        case 1:
            cell.theSubject = "Campaign Residence Type"
            cell.descriptionL.textColor = UIColor.black
            cell.theEntityType = EntityType.residence
            if let residence = theForm.campaignResidenceType {
                cell.descriptionText = residence
            } else {
                cell.descriptionText = "Choose or create a residence type for this form."
                cell.descriptionL.textColor = UIColor(named: "FJARCRed")
            }
        case 37:
            cell.theSubject = "National Partner"
            cell.descriptionL.textColor = UIColor.black
            cell.theEntityType = EntityType.nationalPartner
            if let nationalPartner = theForm.nationalPartner {
                cell.descriptionText = nationalPartner
            } else {
                cell.descriptionText = "Choose or create a National Partner for this form."
                cell.descriptionL.textColor = UIColor(named: "FJARCRed")
            }
        case 38:
            cell.theSubject = "Local Partner(s)"
            cell.descriptionL.textColor = UIColor.black
            cell.theEntityType = EntityType.localPartners
            if let localPartner = theForm.localPartner {
                cell.descriptionText = localPartner
            } else {
                cell.descriptionText = "Choose or create a Local Partner for this form."
                cell.descriptionL.textColor = UIColor(named: "FJARCRed")
            }
        default: break
        }
        return cell
    }
    
    //    MARK: -PERFORM SEGUE-
    // MARK: - Segues
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //            if segue.identifier == "ARC_FormTVCToResidenceTypeSegue" {
    //                let typeTVC = segue.destination as! TypeTVC
    //                typeTVC.theType = entityType
    //                if entityType == EntityType.localPartners {
    //                    if let partners = theForm.localPartner {
    //                        selected.removeAll()
    //                        selected = partners.components(separatedBy: ", ")
    //                        typeTVC.selected = selected
    //                    }
    //                }
    //                typeTVC.path = self.path
    //                typeTVC.delegate = self
    //        }
    //    }
    
    func presentModal(path: IndexPath, title: String) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "ResidenceType", bundle:nil)
        let typeTVC = storyBoard.instantiateViewController(withIdentifier: "TypeTVC") as! TypeTVC
        typeTVC.delegate = self
        typeTVC.theType = entityType
        typeTVC.transitioningDelegate = slideInTransitioningDelgate
        if entityType == EntityType.localPartners {
            if let partners = theForm.localPartner {
                selected.removeAll()
                selected = partners.components(separatedBy: ", ")
                typeTVC.selected = selected
            }
        }
        typeTVC.path = self.path
        
        typeTVC.modalPresentationStyle = .custom
        self.present(typeTVC, animated: true, completion: nil)
    }
    
    //    MARK: -BUILD THE FORM-
    //    MARK: -Get The User-
    func getTheUser() ->FireJournalUser {
        var fju:FireJournalUser? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "userGuid", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
            if !fetched.isEmpty {
                fju = fetched.last
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return fju!
    }
    
    //    MARK: -SAVE SINGLE MASTER FORM AND JOURNAL ENTRY-
    fileprivate func saveSingleAndJournalToCD() {
        do {
            try context.save()
            print("here we go with the save")
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ARC_FormTVC merge that"])
                print("letting the context know we are updating")
            }
            if let guid = theForm.arcFormGuid {
                getTheLastSaved(guid: guid)
                if let object = self.objectID {
                    DispatchQueue.main.async {
                        self.nc.post(name: Notification.Name(rawValue: FJkNEWARCFORMForCloudKit), object: nil, userInfo: ["objectID": object])
                    }
                }
            }
        } catch let error as NSError {
            print("ARC_FormTVC line 236 Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let error: String = "Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
    }
    
    //    MARK: -GET THE LAST FORM SAVED-
    private func getTheLastSaved(guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm" )
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K == %@" , "arcFormGuid" , guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [ARCrossForm]
            let arcForm = self.fetched.last as! ARCrossForm
            self.objectID = arcForm.objectID
        } catch let error as NSError {
            print("CampaignTVC line 885 Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let error: String = "Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
    }
    
    //    MARK: -SAVE THE FORM-
    func saveToCD() {
        do {
            try context.save()
            print("here we go with the save")
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ARC_FormTVC merge that"])
                print("letting the context know we are updating")
            }
            if let object = self.objectID {
                DispatchQueue.main.async {
                    self.nc.post(name: Notification.Name(rawValue: FJkMODIFIEDARCFORMForCloudKit), object: nil, userInfo: ["objectID": object])
                }
            }
            if fromMap {
                if (Device.IS_IPHONE) {
                    if fireJournalUser != nil {
                        let id = fireJournalUser.objectID
                        vcLaunch.mapCalledPhone(type: incidentType, theUserOID: id)
                    }
                } else {
                    if fireJournalUser != nil {
                        let id = fireJournalUser.objectID
                        vcLaunch.mapCalled(type: incidentType, theUserOID: id )
                    }
                }
            }
        } catch let error as NSError {
            print("ARC_FormTVC line 236 Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let error: String = "Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
    }
    //    MARK: -SHARE THE FORM-
    //    MARK: -CALL NEW FORM-
    //    MARK: -ACKNOWLEDGEMENTHEIGHT-
    func getTheAcknowledgementHeight()->CGFloat {
        let textView = UITextView()
        textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: acknowledgementHeight)
        let size = CGSize(width: textView.frame.width, height: .infinity)
        textView.text = FJkARCCrossDECLARATION
        let estimatedSize = textView.sizeThatFits(size)
        
        acknowledgementHeight = estimatedSize.height + 200
        return acknowledgementHeight
    }
    //    MARK: -ADMINISTRATIVEHEIGHT-
    func getTheAdministrativeHeight()->CGFloat {
        let textView = UITextView()
        textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: administrativeHeight)
        let size = CGSize(width: textView.frame.width, height: .infinity)
        textView.text = FJkARCCrossAdministrative
        let estimatedSize = textView.sizeThatFits(size)
        
        administrativeHeight = estimatedSize.height + 90
        return administrativeHeight
    }
    
    @objc func removeTheForm(_ sender: Any) {
        dismiss(animated: true, completion: {
        if self.objectID == nil {
            self.context.delete(self.theForm)
            self.context.delete(self.theResidence)
            self.context.delete(self.theLocalPartners)
            self.context.delete(self.theNationalPartners)
            do {
                try self.context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ARCForm merge that"])
                }
            } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "ARCForm saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
            self.theForm = nil
        }
        })
    }
    
    @objc func saveTheForm(_ sender:Any) {
        let modDate = Date()
        theForm.arcModDate = modDate
        if theForm.campaignName == "Single" {
            theForm.cComplete = true
            theForm.cEndDate = modDate
        }
        saveToCD()
        delegate?.theFormHasBeenSaved()
    }
    
}

extension ARC_FormTVC: MapFormHeaderVDelegate {
    
    func mapFormHeaderBackBTapped(type: IncidentTypes) {
        switch type {
        case .arcForm:
            dismiss(animated: true, completion: {
            if self.objectID == nil {
                self.context.delete(self.theForm)
                self.context.delete(self.theResidence)
                self.context.delete(self.theLocalPartners)
                self.context.delete(self.theNationalPartners)
                do {
                    try self.context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ARCForm merge that"])
                    }
                } catch let error as NSError {
                    let nserror = error
                    
                    let errorMessage = "ARCForm saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                    print(errorMessage)
                }
                self.theForm = nil
            }
            })
        default:
            if (Device.IS_IPHONE) {
                if fireJournalUser != nil {
                    let id = fireJournalUser.objectID
                    vcLaunch.mapCalledPhone(type: type, theUserOID: id)
                }
            } else {
                if fireJournalUser != nil {
                    let id = fireJournalUser.objectID
                    vcLaunch.mapCalled(type: type, theUserOID: id)
                }
            }
        }
    }
    
    func mapFormHeaderSaveBTapped() {
        let modDate = Date()
        theForm.arcModDate = modDate
        if theForm.campaignName == "Single" {
            theForm.cComplete = true
            theForm.cEndDate = modDate
        }
        saveSingleAndJournalToCD()
        delegate?.theFormHasBeenSaved()
    }
    
}

extension ARC_FormTVC: TypeTVCDelegate {
    
    func localPartnersSelected(selected: [String], type: EntityType, path: IndexPath) {
        switch type {
        case .localPartners:
            let localPartners = selected.joined(separator: ", ")
            theForm.localPartner = localPartners
            let thePath = path
            tableView.reloadRows(at: [thePath], with: .automatic)
            saveToCD()
        case .nationalPartner: break
        case .residence: break
        }
        //        self.dismiss(animated: true, completion: nil)
    }
    
    func typeLabelSelected(name: String, type: EntityType, path: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        switch type {
        case .residence:
            theForm.campaignResidenceType = name
            tableView.reloadRows(at: [path], with: .automatic)
        case .localPartners:
            theForm.localPartner = name
            tableView.reloadRows(at: [path], with: .automatic)
        case .nationalPartner:
            theForm.nationalPartner = name
            tableView.reloadRows(at: [path], with: .automatic)
        }
        saveToCD()
    }
    
    func typeBackTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension ARC_FormTVC: ARC_AddressFieldsButtonsCellDelegate {
    
    //    MARK: -ARC_AddressFieldsButtonsCellDelegate-
    func worldBTapped(index: IndexPath) {
        showMap.toggle()
        let path: IndexPath = IndexPath.init(item: 2, section: 0)
        tableView.reloadRows(at: [path], with: .automatic)
        tableView.scrollToRow(at: path, at: .bottom, animated: true)
    }
    
    func addressHasBeenFinished() {
        //        <#code#>
    }
    
    func addressFieldFinishedEditing(address: String, tag: Int) {
        switch tag {
        case 1:
            theForm.arcLocationStreetNum = address
        case 2:
            theForm.arcLocationStreetName = address
        case 3:
            theForm.arcLocationAptMobile = address
        case 4:
            theForm.arcLocationCity = address
        case 5:
            theForm.arcLocaitonState = address
        case 6:
            theForm.arcLocationZip = address
        case 7:
            theForm.arcLocationLatitude = address
        case 8:
            theForm.arcLocationLongitude = address
        default: break
        }
    }
    
    func locationBTapped() {
        determineLocation()
    }
    
    
    func determineLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) -> Void in
            print(userLocation)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if placemarks?.count != 0 {
                let pm = placemarks![0]
                print(pm.subThoroughfare!)
                self.theForm.arcLocationLatitude = String(userLocation.coordinate.latitude)
                self.theForm.arcLocationLongitude = String(userLocation.coordinate.longitude)
                if let city = pm.locality {
                    self.theForm.arcLocationCity = city
                }
                var number: String = ""
                var street: String = ""
                if let num = pm.subThoroughfare {
                    number = num
                    self.theForm.arcLocationStreetNum = number
                }
                if let st = pm.thoroughfare {
                    street = st
                    self.theForm.arcLocationStreetName = street
                }
                self.theForm.arcLocationAddress = "\(number) \(street)"
                if let state = pm.administrativeArea {
                    self.theForm.arcLocaitonState = state
                }
                if let zip = pm.postalCode {
                    self.theForm.arcLocationZip = zip
                }
                self.theForm.arcLocationAptMobile = "NA"
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: userLocation, requiringSecureCoding: true)
                    self.theForm.arcLocationSC = data as NSObject
                } catch {
                    print("got an error here")
                }
                let path1: IndexPath = IndexPath.init(item: 2, section: 0)
                let path2: IndexPath = IndexPath.init(item: 3, section: 0)
                let path3: IndexPath = IndexPath.init(item: 0, section: 0)
                self.tableView.reloadRows(at: [path1,path2,path3], with: .automatic)
                self.tableView.scrollToRow(at: path3, at: .bottom, animated: true)
                DispatchQueue.main.async { [weak self] in
                    self?.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                                  object: nil, userInfo: ["shift":MenuItems.arcForm])
                }
            }
            else {
                if !self.alertUp {
                    let error: String = "Problem with the data received from geocoder. Try again later."
                    self.errorAlert(errorMessage: error)
                }
            }
        })
    }
    
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
}

extension ARC_FormTVC: ARC_TextViewCellDelegate {
    
    //    MARK: -ARC_TextViewCellDelegate-
    func theTextInTextViewChanged(text: String, index: IndexPath, tag: Int) {
        switch tag {
        case 16:
            theForm.hazard = text
        case 35:
            theForm.iaNotes = text
        default: break
        }
        tableView.reloadRows(at: [index], with: .automatic)
    }
    
    func theTextViewEditing(text: String, index: IndexPath, tag: Int) {
        switch tag {
        case 16:
            theForm.hazard = text
        case 35:
            theForm.iaNotes = text
        default: break
        }
    }
    
}

extension ARC_FormTVC: DateTimeAdminDelegate {
    
    //    MARK: -DateTimeAdminDelegate-
    func dateTimeAdminTimeBTapped(index: IndexPath, tag: Int) {
        switch tag {
        case 49:
            theForm.adminDate = Date()
            datePicker3.toggle()
            let path = IndexPath.init(item: 49, section: 0)
            tableView.reloadRows(at: [path], with: .automatic)
        default: break
        }
    }
    
}

extension ARC_FormTVC: ARC_AdminSegmentDelegate {
    
    //    MARK: -AdminSegmentDelegate-
    func theAdminSegmentWasTapped(type: ARC_FormType, tag: Int, indexPath: IndexPath) {
        switch tag {
        case 51:
            switch type {
            case .arcOrp:
                theForm.arcPortalSystem = "ARC ORP"
            case .mySmokeAlarm:
                theForm.arcPortalSystem = "MySmokeAlarm"
            case .other:
                theForm.arcPortalSystem = "Other"
            }
        default: break
        }
    }
    
}

extension ARC_FormTVC: ARC_LabelTextViewCellDelegate {
    
    //    MARK: -ARC_LabelTextViewCellDelegate-
    func textViewEditing(text: String, indexPath: IndexPath) {
        //        <#code#>
    }
    
    func textViewDoneEditing(text: String, indexPath: IndexPath) {
        //        <#code#>
    }
    
}

extension ARC_FormTVC: ARC_MapViewCellDelegate {
    
    //    MARK: -ARC_MapViewCellDelegate-
    func theMapLocationHasBeenChosen(location: CLLocation) {
        //        <#code#>
    }
    
    func theMapCancelButtonTapped() {
        showMap.toggle()
        let path: IndexPath = IndexPath.init(item: 2, section: 0)
        tableView.reloadRows(at: [path], with: .automatic)
    }
    
    func theAddressHasBeenChosen(addressStreetNum: String, addressStreetName: String, addressCity: String, addressState: String, addressZip: String, location: CLLocation) {
        theForm.arcLocationStreetNum = addressStreetNum
        theForm.arcLocationStreetName = addressStreetName
        theForm.arcLocationAddress = "\(addressStreetNum) \(addressStreetName)"
        theForm.arcLocationCity = addressCity
        theForm.arcLocaitonState = addressState
        theForm.arcLocationZip = addressZip
        
        /// arcLocation archived with secureCodeing
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
            theForm.arcLocationSC = data as NSObject
            theForm.arcLocationAvailable = true
            var latitude: String = ""
            var longitude: String = ""
            let coordinate = location.coordinate
            latitude = String(coordinate.latitude)
            longitude = String(coordinate.longitude)
            theForm.arcLocationLatitude = latitude
            theForm.arcLocationLongitude = longitude
        } catch {
            print("got an error here")
        }
        
        showMap.toggle()
        let path1: IndexPath = IndexPath.init(item: 1, section: 0)
        let path2: IndexPath = IndexPath.init(item: 2, section: 0)
        let path3: IndexPath = IndexPath.init(item: 0, section: 0)
        self.tableView.reloadRows(at: [path1,path2,path3], with: .automatic)
        self.tableView.scrollToRow(at: path3, at: .bottom, animated: true)
        DispatchQueue.main.async { [weak self] in
            self?.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                          object: nil, userInfo: ["shift":MenuItems.arcForm])
        }
    }
    
    func theMapCellInfoBTapped() {
        //        <#code#>
    }
    
}

extension ARC_FormTVC: ARC_DatePickerCellDelegate {
    
    //    MARK: -ARC_DatePickerCellDelegate-
    func theDatePickerChangedDate(_ date: Date, at indexPath: IndexPath, tag: Int) {
        var path1: IndexPath!
        var path2: IndexPath!
        switch tag {
        case 21:
            theForm.residentSigDate = date
            datePicker1 = false
            path1 = IndexPath.init(item: 20, section: 0)
            path2 = IndexPath.init(item: 21, section: 0)
        case 25:
            theForm.installerDate = date
            datePicker2 = false
            path1 = IndexPath.init(item: 24, section: 0)
            path2 = IndexPath.init(item: 25, section: 0)
        case 50:
            theForm.adminDate = date
            datePicker3 = false
            path1 = IndexPath.init(item: 48, section: 0)
            path2 = IndexPath.init(item: 49, section: 0)
        default: break
        }
        tableView.reloadRows(at: [path1,path2], with: .automatic)
    }
    
}

extension ARC_FormTVC: ARC_DateTimeCellDelegate {
    
    //    MARK: -ARC_DateTimeCellDelegate-
    func theTimeBTapped(tag: Int) {
        switch tag {
        case 20:
            datePicker1.toggle()
            let path = IndexPath.init(item: 20, section: 0)
            tableView.reloadRows(at: [path], with: .automatic)
        case 24:
            datePicker2.toggle()
            let path = IndexPath.init(item: 24, section: 0)
            tableView.reloadRows(at: [path], with: .automatic)
        default: break
        }
    }
}

extension ARC_FormTVC: ARC_HeadCellDelegate {
    
    //    MARK: -ARC_HeadCellDelegate-
    func arcFormInfoTapped() {
        if !alertUp {
            presentAlert()
        }
    }
    
    func presentAlert() {
        let message: String = FJkARCrossHeaderInfoNotes
        let title: String = FJkARCrossHeaderInfoSubject
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentShareAlert() {
        let message: String = FJkARCrossShare
        let title: String = FJkARCrossShareSubject
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
//            self.alertUp = false
//        })
//        alert.addAction(okAction)
            alertUp = true
        self.present(alert, animated: true, completion: nil)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            alert.dismiss(animated: true, completion: nil)
            self.alertUp = false
        })
    }
    
    
    
    func arcFormCampaignSwitchTapped(campaign: Bool) {
        theForm.cComplete.toggle()
        let path: IndexPath = IndexPath.init(item: 0, section: 0)
        tableView.reloadRows(at: [path], with: .automatic)
    }
    
    func arcFormShareThisFormTapped() {
        saveTheForm(self)
        let theForm = arcFormToCloud.arcBuildToShare(objectID!)
        print("here is the form \n\(theForm)")
        if !self.alertUp {
            self.presentShareAlert()
        }
        arcFormToCloud.sendAndRecieve(dataCompletionHander:  { link, error in
            
            if link == link {
                self.pdfLink = link
            }
        }
        )
    }
    
}

extension ARC_FormTVC: ARC_arcLabelTextFieldCellDelegate {
    
    func theTextFieldTextIsChanging(text: String, indexPath: IndexPath, tag: Int) {
        switch tag {
        case 18:
            theForm.residentName = text
        case 22:
            theForm.installerName = text
        case 40:
            theForm.option1 = text
        case 41:
            theForm.option2 = text
        case 44:
            theForm.residentEmail = text
        case 45:
            theForm.residentCellNum = text
        case 46:
            theForm.residentOtherPhone = text
        default: break
        }
    }
    //    MARK: -ARC_arcLabelTextFieldCellDelegate-
    func theTextFieldHasChanged(text: String, indexPath: IndexPath, tag: Int) {
        self.resignFirstResponder()
        switch tag {
        case 18:
            theForm.residentName = text
        case 22:
            theForm.installerName = text
        case 40:
            theForm.option1 = text
        case 41:
            theForm.option2 = text
        case 44:
            theForm.residentEmail = text
        case 45:
            theForm.residentCellNum = text
        case 46:
            theForm.residentOtherPhone = text
        default: break
        }
        //        tableView.reloadRows(at: [indexPath], with:.automatic)
    }
    
    func theTextFieldHitReturnKey(text: String, indexPath: IndexPath, tag: Int) {
        let cell = tableView.cellForRow(at: indexPath) as! ARC_arcLabelTextFieldCell
        cell.descriptionTF.resignFirstResponder()
        switch tag {
        case 18:
            theForm.residentName = text
        case 22:
            theForm.installerName = text
        case 40:
            theForm.option1 = text
        case 41:
            theForm.option2 = text
        case 44:
            theForm.residentEmail = text
        case 45:
            theForm.residentCellNum = text
        case 46:
            theForm.residentOtherPhone = text
        default: break
        }
    }
}

extension ARC_FormTVC: LabelExtendedTextFieldDelegate {
    
    //    MARK: -LabelExtendedTextFieldDelegate-
    func labelExtendedTFEdited(text: String, tag: Int, index: IndexPath) {
        switch tag {
        case 48:
            theForm.adminName  = text
        default: break
        }
        tableView.reloadRows(at: [index], with: .automatic)
    }
    
    func labelTextBeingEdited(text:String,tag: Int, index: IndexPath) {
        switch tag {
        case 48:
            theForm.adminName  = text
        default: break
        }
    }
    
}

extension ARC_FormTVC: ARC_SignatureCellDelegate, T1AutographDelegate {
    
    //    MARK: -SIGNATURE DELEGATE-
    func theSignatureBTapped(path: IndexPath, tag: Int) {
        signaturePath = path
        signatureTag = tag
        var modalDisplayName: String = ""
        switch signatureTag {
        case 19:
            modalDisplayName = "Resident Signature"
            let path: IndexPath = IndexPath.init(item: 18, section: 0)
            let cell = tableView.cellForRow(at: path) as! ARC_arcLabelTextFieldCell
            cell.resignFirstResponder()
        case 23:
            modalDisplayName = "Installer Agent Signature"
        default: break
        }
        autograph = T1Autograph.autograph(withDelegate: self, modalDisplay: modalDisplayName) as! T1Autograph
        
        // Enter license code here to remove the watermark
        autograph.licenseCode = "9186d2059ae047426bd0c571a0cf637ef569a6c4"
        
        // any optional configuration done here
        autograph.showDate = false
        autograph.strokeColor = UIColor.darkGray
    }
    
    func autograph(_ autograph: T1Autograph!, didCompleteWith signature: T1Signature!) {
        var datePath: IndexPath!
        switch signatureTag {
        case 19:
            datePath = IndexPath.init(item: 20, section: 0)
            theForm.residentSigDate = Date()
            theForm.residentSigned = true
            residentSignature = true
        case 23:
            datePath = IndexPath.init(item: 24, section: 0)
            theForm.installerDate = Date()
            theForm.installerSigend = true
            installerSignature = true
        default: break
        }
        signatureImage = UIImage(data:signature.imageData,scale:1.0)
        if let imageD = signatureImage!.pngData() as NSData? {
            switch signatureTag {
            case 19:
                theForm.residentSignature = imageD as Data
            case 23:
                theForm.installerSignature = imageD as Data
            default: break
            }
        }
        tableView.reloadRows(at: [signaturePath,datePath], with: .automatic)
    }
    
    func autographDidCancelModalView(_ autograph: T1Autograph!) {
        switch signatureTag {
        case 19:
            residentSignature = false
        case 23:
            installerSignature = false
        default: break
        }
        signatureImage = nil
        tableView.reloadRows(at: [signaturePath], with: .automatic)
    }
    
    func autographDidCompleteWithNoSignature(_ autograph: T1Autograph!) {
        switch signatureTag {
        case 19:
            residentSignature = false
        case 23:
            installerSignature = false
        default: break
        }
        signatureImage = nil
        tableView.reloadRows(at: [signaturePath], with: .automatic)
    }
    
    func autograph(_ autograph: T1Autograph!, didEndLineWithSignaturePointCount count: UInt) {
        // Note: You can use the 'count' parameter to determine if the line is substantial enough to enable the done or clear button.
    }
    
    func autograph(_ autograph: T1Autograph!, willCompleteWith signature: T1Signature!) {
        NSLog("Autograph will complete with signature")
    }
    
}

extension ARC_FormTVC: ARC_QuestionSwitchDelegate {
    
    //    MARK: -ARC_QuestionSwitchDelegate-
    func theSwitchIsTapped(switchState: Bool, index: IndexPath, tag: Int) {
        switch tag {
        case 11:
            theForm.receiveSPM = switchState
        case 12:
            theForm.recieveEP = switchState
        case 13:
            theForm.createFEPlan = switchState
        case 14:
            theForm.reviewFEPlan = switchState
        case 15:
            theForm.localHazard = switchState
        case 43:
            theForm.residentContactInfo = switchState
        default: break
        }
        tableView.reloadRows(at: [index], with: .automatic)
    }
    
    func theCompleteIsMarkedTrue(complete: Bool) {
        //        <#code#>
    }
}

extension ARC_FormTVC: ARC_StepperTFCellDelegate {
    
    //    MARK: -ARC_StepperTFCellDELEGATE-
    func stepperTapped(count: String, indexPath: IndexPath, tag: Int) {
        switch tag {
        case 5:
            theForm.numNewSA = count
        case 6:
            theForm.numBedShaker = count
        case 7:
            theForm.numBatteries = count
        case 9:
            theForm.numC02detectors = count
        case 27:
            theForm.iaNumPeople = count
        case 28:
            theForm.ia17Under = count
        case 29:
            theForm.ia65Over = count
        case 30:
            theForm.iaDisability = count
        case 31:
            theForm.iaVets = count
        case 32:
            theForm.iaPrexistingSA = count
        case 33:
            theForm.iaWorkingSA = count
        case 34:
            theForm.iaHowOldSA = count
        default: break
        }
        //        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func stepperCompleted(complete: Bool) {
        //        <#code#>
    }
    
    
}

extension ARC_FormTVC: FormHeaderDelegate {
    func formBackBTapped() {
        delegate?.theFormHasCancelled()
    }
    
    func formSaveBTapped() {
        let modDate = Date()
        theForm.arcModDate = modDate
        if theForm.campaignName == "Single" {
            theForm.cComplete = true
            theForm.cEndDate = modDate
        }
        saveToCD()
        delegate?.theFormHasBeenSaved()
    }
    
    func formNewBTapped() {
        delegate?.theFormWantsNewForm()
    }
    
    
}

