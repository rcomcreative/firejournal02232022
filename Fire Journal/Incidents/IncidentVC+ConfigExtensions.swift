    //
    //  IncidentVC+ConfigExtensions.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 3/14/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import PhotosUI

extension IncidentVC {
    
        //    MARK: -CONFIGUREHEIGHT-
    
        /// find the height for text area using the string associated with input
        /// - Parameter text: text entered in modals for form
        /// - Returns: returns the height for the label cell
    func configureLabelHeight(text: String ) -> CGFloat {
        var theFloat: CGFloat = 0.0
        let frame = self.view.frame
        let width = frame.width - 70
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = .systemFont(ofSize: 15)
        label.text = text
        label.sizeToFit()
        let labelFrame = label.frame
        theFloat = labelFrame.height
        label.removeFromSuperview()
        theFloat = theFloat - 400
        if theFloat < 44 {
            theFloat = 88
        }
        return theFloat
    }
    
        // MARK: -USER USERTIME-
    
        /// lazy var theUserProvider will get the user to be used for relationships - as it is
        /// pulled from a background context - theUser needs to be pulled by the objectID in this
        /// context.
    func getTheUser() {
        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
        guard let users = theUserProvider.getTheUser(theUserContext) else {
            let errorMessage = "There is no user associated with this end shift"
            errorAlert(errorMessage: errorMessage)
            return
        }
        let aUser = users.last
        if let id = aUser?.objectID {
            theUser = context.object(with: id) as? FireJournalUser
        }
    }
    
        /// lazy var userTimeProvider will get the userTime to be used for relationships - as it is
        /// pulled from a background context - theUser needs to be pulled by the objectID in this
        /// context.
    func getTheLastUserTime() {
        userTimeContext = userTimeProvider.persistentContainer.newBackgroundContext()
        guard let userTime = userTimeProvider.getLastShiftNotCompleted(userTimeContext) else {
            let errorMessage = "A start shift is needed to retrieve the incidents of the day"
            errorAlert(errorMessage: errorMessage)
            return
        }
        let aUserTime = userTime.last
        if let id = aUserTime?.objectID {
            theUserTime = context.object(with: id) as? UserTime
        }
        
        
    }
    
    func getTheTags() {
        theTagContext = tagProvider.persistentContainer.newBackgroundContext()
        theTags = tagProvider.getAllTags(context: theTagContext)
        if theTags.isEmpty {
            DispatchQueue.main.async {
                self.theTags = self.tagProvider.buildTheTags(bkgrndContext: self.theTagContext)
            }
        }
    }
    
    func getTheActionsTaken() {
        theActionsTakenContext = nfirsActionTakenProvider.persistentContainer.newBackgroundContext()
        if let actions = nfirsActionTakenProvider.getAllActionsTaken(context: theActionsTakenContext) {
            if actions.count == 0 {
                DispatchQueue.main.async {
                    self.theNFIRsActionsTaken = self.nfirsActionTakenProvider.buildNFIRSActionTaken(theGuidDate: Date(), backgroundContext: self.theActionsTakenContext)
                }
            } else {
                theNFIRsActionsTaken = actions
            }
        } else {
                DispatchQueue.main.async {
                    self.theNFIRsActionsTaken = self.nfirsActionTakenProvider.buildNFIRSActionTaken(theGuidDate: Date(), backgroundContext: self.theActionsTakenContext)
                }
        }
    }
    
    func getTheLocalIncidentTypes() {
        theLocalIncidentContext = localIncidentProvider.persistentContainer.newBackgroundContext()
        if let local = localIncidentProvider.getAllLocalIncidentTypes(context: theLocalIncidentContext) {
            if local.count == 0 {
                    DispatchQueue.main.async {
                        self.theLocalIncidentTypes = self.localIncidentProvider.buildLocalIncidentType(theGuidDate: Date(), backgroundContext: self.theLocalIncidentContext)
                    }
            } else {
                theLocalIncidentTypes = local
            }
        } else {
            DispatchQueue.main.async {
                self.theLocalIncidentTypes = self.localIncidentProvider.buildLocalIncidentType(theGuidDate: Date(), backgroundContext: self.theLocalIncidentContext)
            }
        }
    }
    
    func getTheNFIRSIncidentType() {
        nfirsIncidentTypeContext = nfirsIncidentTypeProvider.persistentContainer.newBackgroundContext()
        if let types = nfirsIncidentTypeProvider.getAllNFIRSIncidentType(nfirsIncidentTypeContext) {
            if types.count == 0 {
                DispatchQueue.main.async {
                    self.theNFIRSIncidentTypes = self.nfirsIncidentTypeProvider.buildTheNFIRSIncidentTypes(theGuidDate: Date(), backgroundContext: self.nfirsIncidentTypeContext)
                }
            } else {
                theNFIRSIncidentTypes = types
            }
        } else {
            DispatchQueue.main.async {
                self.theNFIRSIncidentTypes = self.nfirsIncidentTypeProvider.buildTheNFIRSIncidentTypes(theGuidDate: Date(), backgroundContext: self.nfirsIncidentTypeContext)
            }
        }
    }
    
        // MARK: -LAYOUT CONFIGURATIONS-
    
        /// build the table view for the form - called in viewdidload
    func configureIncidentTableView() {
        incidentTableView = UITableView(frame: .zero)
        registerCellsForTable()
        incidentTableView.translatesAutoresizingMaskIntoConstraints = false
        incidentTableView.backgroundColor = .systemBackground
        view.addSubview(incidentTableView)
        incidentTableView.delegate = self
        incidentTableView.dataSource = self
        incidentTableView.separatorStyle = .none
        
        incidentTableView.rowHeight = UITableView.automaticDimension
        incidentTableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            incidentTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            incidentTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            incidentTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            incidentTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }
    
        //    MARK: -ALERTS-
    
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func theAlert(message: String) {
        let alert = UIAlertController.init(title: "Update", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert() {
        let message: InfoBodyText = .newIncidentSubject
        let title: InfoBodyText = .newIncident
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapAlert() {
        let subject = InfoBodyText.mapErrorSubject.rawValue
        let message = InfoBodyText.mapErrorDescription.rawValue
        let alert = UIAlertController.init(title: subject, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
        //    MARK:- Address fields and buttons cell
    
        /// configuring the NewAddressFieldsButtonsCell
        /// - Parameters:
        ///   - cell: NewAddressFieldsButtonsCell
        ///   - indexPath: indexPath of cell
        ///   - tag: cell.tag int
        /// - Returns: street, city, state, zip, latitude, and longitude with map buttons
    func configureNewAddressFieldsButtonsCell(_ cell: NewAddressFieldsButtonsCell, at indexPath: IndexPath, tag: Int) -> NewAddressFieldsButtonsCell {
        cell.tag = tag
        cell.delegate = self
        cell.subjectL.text = "Address:"
        var streetAddress: String = ""
        var city: String = ""
        var state: String = ""
        var zip: String = ""
        var latitude: String = ""
        var longitude: String = ""
        if theIncidentLocation != nil {
            if let number = theIncidentLocation.streetNumber {
                streetAddress = number + " "
            }
            if let street = theIncidentLocation.streetName {
                streetAddress = streetAddress + street
            }
            if let c = theIncidentLocation.city {
                city = c
            }
            if let s = theIncidentLocation.state {
                state = s
            }
            if let z = theIncidentLocation.zip {
                zip = z
            }
            if theIncidentLocation.latitude != 0.0 {
                latitude = String(theIncidentLocation.latitude)
            }
            if theIncidentLocation.longitude != 0.0 {
                longitude = String(theIncidentLocation.longitude)
            }
        }
        if theIncidentAddress != nil {
            if let number = theIncidentAddress.streetNumber {
                streetAddress = number + " "
            }
            if let street = theIncidentAddress.streetHighway {
                streetAddress = streetAddress + street
            }
            if let c = theIncidentAddress.city {
                city = c
            }
            if let s = theIncidentAddress.incidentState {
                state = s
            }
            if let z = theIncidentAddress.zip {
                zip = z
            }
            if theIncidentMap != nil {
                if let theLatitude = theIncidentMap.incidentLatitude {
                    latitude = theLatitude
                }
                if let theLongitude = theIncidentMap.incidentLongitude {
                    longitude = theLongitude
                }
            }
            
        }
        cell.addressTF.text = streetAddress
        cell.addressTF.placeholder = "100 Grant"
        cell.addressTF.textColor = UIColor(named: "FJIconRed")
        cell.cityTF.text = city
        cell.cityTF.placeholder = "City"
        cell.cityTF.textColor = UIColor(named: "FJIconRed")
        cell.stateTF.text = state
        cell.stateTF.placeholder = "State"
        cell.stateTF.textColor = UIColor(named: "FJIconRed")
        cell.zipTF.text = zip
        cell.zipTF.placeholder = "Zip Code"
        cell.zipTF.textColor = UIColor(named: "FJIconRed")
        cell.addressLatitudeTF.text = latitude
        cell.addressLatitudeTF.textColor = UIColor(named: "FJIconRed")
        cell.addressLongitudeTF.text = longitude
        cell.addressLongitudeTF.textColor = UIColor(named: "FJIconRed")
        cell.addressLatitudeTF.placeholder = "Latitude"
        cell.addressLongitudeTF.placeholder = "Longitude"
        return cell
    }
    
        /// build the button for choosing camera type with IncidentTypes.allincidents and red color
        /// - Parameters:
        ///   - cell: CameraTVCell
        ///   - index: index row cell resides
        /// - Returns: returns list of camera types
    func configureCameraTVCell(_ cell: CameraTVCell, index: IndexPath) -> CameraTVCell {
        cell.tag = index.row
        cell.indexPath = index
        let section = index.section
        let row = index.row
        cell.delegate = self
        switch section {
        case 0:
            switch row {
            case 29:
                cell.type = IncidentTypes.allIncidents
                cell.aBackgroundColor = "FJIconRed"
            default: break
            }
        default: break
        }
        return cell
    }
    
    func configureIncidentPhotoCollectionCell(_ cell: IncidentPhotoCollectionCell, index: IndexPath) -> IncidentPhotoCollectionCell {
        cell.photos = self.validPhotos
        return cell
    }
    
    func configureIncidentEditBarTVC(_ cell: IncidentEditBarTVC, index: IndexPath) -> IncidentEditBarTVC {
        cell.tag = index.row
        cell.delegate = self
        if let imageName = theIncident.incidentEntryTypeImageName {
            cell.imageName = imageName
        } else {
            cell.imageName = typeNameA[0]
        }
        if let incidentNumber = theIncident.incidentNumber {
            cell.incidentNumber = incidentNumber
        }
        var address: String = ""
        if theIncidentAddress != nil {
            if let number = theIncidentAddress.streetNumber {
                address = number
            }
            if let street = theIncidentAddress.streetHighway {
                address = address + " " + street
            }
            if let city = theIncidentAddress.city {
                address = address + " " + city
            }
            if let state = theIncidentAddress.incidentState {
                address = address + ", " + state
            }
            if let zip = theIncidentAddress.zip {
                address = address + " " + zip
            }
            cell.incidentAddress = address
        }
        if theIncidentLocation != nil {
            if let number = theIncidentLocation.streetNumber {
                address = number
            }
            if let street = theIncidentLocation.streetName {
                address = address + " " + street
            }
            if let city = theIncidentLocation.city {
                address = address + " " + city
            }
            if let state = theIncidentLocation.state {
                address = address + ", " + state
            }
            if let zip = theIncidentLocation.zip {
                address = address + " " + zip
            }
            cell.incidentAddress = address
        }
        dateFormatter.dateFormat = "EEE MMM dd,YYYY HH:mm"
        if theIncidentTime != nil {
            if let alarm = theIncidentTime.incidentAlarmDateTime {
                let alarmTime = dateFormatter.string(from: alarm)
                cell.alarmDate = alarmTime
            }
        }
        cell.configure()
        return cell
    }
    
    func configureSegmentCell(_ cell: SegmentCell, index: IndexPath) -> SegmentCell {
        let tag = index.row
        cell.tag = tag
        cell.delegate = self
        cell.subjectL.text = "Incident Type"
        cell.myShift = .incidents
        cell.typeSegment.setTitle("Fire", forSegmentAt: 0)
        cell.typeSegment.setTitle("EMS", forSegmentAt: 1)
        cell.typeSegment.setTitle("Rescue", forSegmentAt: 2)
        
       
        
        if let type = theIncident.situationIncidentImage {
            if type == "Fire" {
                segmentType = MenuItems.fire
            } else if type == "EMS" {
                segmentType = MenuItems.ems
            } else if type == "Rescue" {
                segmentType = MenuItems.rescue
            }
        } else {
                theIncident.situationIncidentImage = "Fire"
                theIncident.incidentEntryTypeImageName = "100515IconSet_092016_fireboard"
                segmentType = MenuItems.fire
        }
        
        
        
        switch segmentType {
        case .fire:
            cell.typeSegment.selectedSegmentIndex = 0
        case .ems:
            cell.typeSegment.selectedSegmentIndex = 1
        case .rescue:
            cell.typeSegment.selectedSegmentIndex = 2
        default:
            cell.typeSegment.selectedSegmentIndex = 0
        }
        return cell
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
            case 9:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Alarm"
                if theIncident != nil {
                    if let alarmTime = theIncidentTime.incidentAlarmDateTime {
                        cell.theFirstDose = alarmTime
                    } else {
                        if let alarmTime = theIncident.incidentModDate {
                            cell.theFirstDose = alarmTime
                            theIncidentTime.incidentAlarmDateTime = alarmTime
                        }
                    }
                }
            default: break
            }
        default: break
        }
        return cell
    }
    
    func configureLabelYesNoSwitchCell(_ cell: LabelYesNoSwitchCell, index: IndexPath) -> LabelYesNoSwitchCell {
        let tag = index.row
        cell.tag = tag
        cell.delegate = self
        switch tag {
        case 1:
            cell.yesNotSwitch.onTintColor = UIColor(named: "FJIconRed")
            cell.yesNotSwitch.backgroundColor = UIColor(named: "FJIconRed")
            cell.yesNotSwitch.layer.cornerRadius = 16
            cell.yesNotSwitch.isOn = true
            yesNo = true
            if theIncident.incidentType == "Emergency" {
                cell.yesNotSwitch.isOn = true
                yesNo = true
            } else if theIncident.incidentType == "Non-Emergency" {
                cell.yesNotSwitch.isOn = false
                yesNo = false
            }
            cell.yesNoB = yesNo
            cell.myShift = MenuItems.incidents
            cell.incidentType = .emergency
            cell.subjectL.text = "Emergency"
            cell.leftText = "No"
            cell.rightText = "Yes"
            cell.rightL.textColor = UIColor.systemRed
            cell.leftL.textColor = UIColor.systemRed
        case 28:
            cell.yesNotSwitch.onTintColor = UIColor(named: "FJIconRed")
            cell.yesNotSwitch.backgroundColor = UIColor(named: "FJIconRed")
            cell.yesNotSwitch.layer.cornerRadius = 16
            cell.yesNotSwitch.isOn = true
            yesNo = true
            if theIncident.arsonInvestigation {
                cell.yesNotSwitch.isOn = true
                yesNo = true
            } else {
                cell.yesNotSwitch.isOn = false
                yesNo = false
            }
            cell.yesNoB = yesNo
            cell.myShift = MenuItems.incidents
            cell.incidentType = .emergency
            cell.subjectL.text = "Arson"
            cell.leftText = "No"
            cell.rightText = "Yes"
            cell.rightL.textColor = UIColor.systemRed
            cell.leftL.textColor = UIColor.systemRed
        default: break
        }
        
        return cell
    }
    
    func configureLabelTextFieldCell(_ cell: LabelTextFieldCell, index: IndexPath) -> LabelTextFieldCell {
        let row = index.row
        switch row {
        case 1:
            cell.delegate = self
            cell.theShift = MenuItems.incidents
            cell.subjectL.text = "Incident Number"
            cell.descriptionTF.tag = 1
            cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
            if let number = theIncident.incidentNumber {
                cell.descriptionTF.text = number
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "01",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        default:
            cell.subjectL.isHidden = true
            cell.subjectL.alpha = 0.0
            cell.descriptionTF.isHidden = true
            cell.descriptionTF.isEnabled = false
            cell.descriptionTF.alpha = 0.0
        }
        return cell
    }
    
    func configureMultipleAddButtonTVCell(_ cell: MultipleAddButtonTVCell, index: IndexPath) -> MultipleAddButtonTVCell {
        cell.tag = index.row
        cell.indexPath = index
        let section = index.section
        let row = index.row
        cell.delegate = self
        switch section {
        case 0:
            switch row {
            case 4:
                cell.type = IncidentTypes.nfirsIncidentType
                cell.aBackgroundColor = "FJIconRed"
                cell.aChoice = ""
            case 6:
                cell.type = IncidentTypes.localIncidentType
                cell.aBackgroundColor = "FJIconRed"
                cell.aChoice = ""
            case 8:
                cell.type = IncidentTypes.incidentNote
                cell.aBackgroundColor = "FJIconRed"
                cell.aChoice = ""
            case 11:
                cell.type = IncidentTypes.alarm
                cell.aBackgroundColor = "FJIconRed"
                cell.aChoice = ""
            case 14:
                cell.type = IncidentTypes.arrival
                cell.aBackgroundColor = "FJIconRed"
                cell.aChoice = ""
            case 17:
                cell.type = IncidentTypes.controlled
                cell.aBackgroundColor = "FJIconRed"
                cell.aChoice = ""
            case 20:
                cell.type = IncidentTypes.lastunitstanding
                cell.aBackgroundColor = "FJIconRed"
                cell.aChoice = ""
            case 22:
                cell.type = IncidentTypes.firstAction
                cell.aBackgroundColor = "FJIconRed"
                cell.aChoice = ""
            case 24:
                cell.type = IncidentTypes.secondAction
                cell.aBackgroundColor = "FJIconRed"
                cell.aChoice = ""
            case 26:
                cell.type = IncidentTypes.thirdAction
                cell.aBackgroundColor = "FJIconRed"
                cell.aChoice = ""
            case 31:
                cell.type = IncidentTypes.tags
                cell.aBackgroundColor = "FJIconRed"
                cell.aChoice = ""
            default: break
            }
        default: break
        }
        return cell
    }
    
    func configureIncidentTextViewTVCell(_ cell: IncidentTextViewTVCell, index: IndexPath) -> IncidentTextViewTVCell {
        let row = index.row
        switch row {
        case 5:
            var theNFIRSIncidentType: String = ""
            if theIncidentNFIRS != nil {
                if let number = theIncidentNFIRS.incidentTypeNumberNFRIS {
                    theNFIRSIncidentType = number
                }
                if let text = theIncidentNFIRS.incidentTypeTextNFRIS {
                    theNFIRSIncidentType = theNFIRSIncidentType + " " + text
                }
                cell.information = theNFIRSIncidentType
            }
        case 7:
            if theIncidentLocal !=  nil {
                if let local = theIncidentLocal.incidentLocalType {
                    cell.information = local
                }
            }
        default: break
        }
        cell.configure()
        return cell
    }
    
    func configureSubjectLabelTextViewTVCell(_ cell: SubjectLabelTextViewTVCell, index: IndexPath) -> SubjectLabelTextViewTVCell {
        cell.subjectL.text = "Incident Notes"
        if theIncidentNotes != nil {
            cell.subjectTV.text = theIncidentNotes.incidentNote
        }
        cell.delegate = self
        return cell
    }
    
        //    MARK:- compact date field with label
        
        /// configure the time and date of the incident
        /// - Parameters:
        ///   - cell: labelsingleDateFieldCell with delegate
        ///   - index: indexPath of the cell
        ///   - tag: int for the cell tag - arrived from indexPath.row
        /// - Returns: incident date/time field
    func configureModalLableSingleDateFieldCell(_ cell: ModalLableSingleDateFieldCell, index: IndexPath, tag: Int) -> ModalLableSingleDateFieldCell {
        cell.tag = tag
        cell.delegate = self
        cell.index = index
        switch tag {
        case 10:
            cell.theSubject = "Alarm"
            if theIncidentTime != nil {
                if theAlarmDate != nil {
                    cell.theFirstDose = theAlarmDate
                }
            }
        default: break
        }
        cell.datePicker.datePickerMode = .dateAndTime
        return cell
    }
    
    
    func configureLabelCell(_ cell: LabelCell, index: IndexPath) -> LabelCell {
        cell.tag = index.row
        let row = index.row
        cell.modalTitleL.font = cell.modalTitleL.font.withSize(15)
        cell.modalTitleL.adjustsFontSizeToFitWidth = true
        cell.modalTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.modalTitleL.numberOfLines = 0
        cell.infoB.isHidden = true
        cell.infoB.alpha = 0.0
        cell.infoB.isEnabled = false
        switch row {
        case 5:
            cell.modalTitleL.text = theNFIRSIncidentTypeText
        case 7:
            cell.modalTitleL.text = theLocalIncidentTypeText
        case 9:
            cell.modalTitleL.text = theIncidentNote
        case 12:
            cell.modalTitleL.text = theAlarmNotes
        case 15:
            cell.modalTitleL.text = theArrivalNotes
        case 18:
            cell.modalTitleL.text = theControlledNotes
        case 21:
            cell.modalTitleL.text = theLastUnitNotes
        case 23:
            cell.modalTitleL.text = theAction1
        case 25:
            cell.modalTitleL.text = theAction2
        case 27:
            cell.modalTitleL.text = theAction3
        case 33:
            cell.modalTitleL.text = " "
        default: break
        }
        cell.modalTitleL.setNeedsDisplay()
        return cell
    }
    
    func configureIncidentSameDateAlarmTVCell(_ cell: IncidentSameDateAlarmTVCell, index: IndexPath) -> IncidentSameDateAlarmTVCell {
        let row = index.row
        cell.tag = row
        cell.index = index
        cell.sameAsAlarmSwitch.onTintColor = UIColor(named: "FJIconRed")
        cell.sameAsAlarmSwitch.backgroundColor = UIColor(named: "FJIconRed")
        cell.sameAsAlarmSwitch.layer.cornerRadius = 16
        switch row {
        case 13:
            cell.theSubject = "Arrival"
            if theIncidentTime != nil {
                if theIncidentTime.incidentArrivalDateTime == nil {
                    cell.sameDate = true
                    if let alarm = theIncidentTime.incidentAlarmDateTime {
                        cell.theFirstDose = alarm
                    }
                } else {
                    cell.sameDate = false
                    if let alarm = theIncidentTime.incidentArrivalDateTime {
                        cell.theFirstDose = alarm
                    }
                }
            }
        case 16:
            cell.theSubject = "Controlled"
            if theIncidentTime != nil {
                if theIncidentTime.incidentControlDateTime == nil {
                    cell.sameDate = true
                    if let alarm = theIncidentTime.incidentAlarmDateTime {
                        cell.theFirstDose = alarm
                    }
                } else {
                    cell.sameDate = false
                    if let alarm = theIncidentTime.incidentControlDateTime {
                        cell.theFirstDose = alarm
                    }
                }
            }
        case 19:
            cell.theSubject = "Last Unit"
            if theIncidentTime != nil {
                if theIncidentTime.incidentLastUnitDateTime == nil {
                    cell.sameDate = true
                    if let alarm = theIncidentTime.incidentAlarmDateTime {
                        cell.theFirstDose = alarm
                    }
                } else {
                    cell.sameDate = false
                    if let alarm = theIncidentTime.incidentLastUnitDateTime {
                        cell.theFirstDose = alarm
                    }
                }
            }
        default: break
        }
        
        return cell
    }
    
    func configureIncidentLabelDateiPhoneTVCell(_ cell: IncidentLabelDateiPhoneTVCell, index: IndexPath) -> IncidentLabelDateiPhoneTVCell {
        let row = index.row
        cell.tag = row
        cell.index = index
        switch row {
        case 10:
            cell.theSubject = "Alarm"
            if theIncidentTime != nil {
                if let alarm = theIncidentTime.incidentAlarmDateTime {
                    cell.theFirstDose = alarm
                }
            }
        default: break
        }
        return cell
    }
    
    func configureIncidentSameDateiPhoneTVCell(_ cell: IncidentSameDateiPhoneTVCell, index: IndexPath) -> IncidentSameDateiPhoneTVCell {
        let row = index.row
        cell.tag = row
        cell.index = index
        
        cell.sameAsAlarmSwitch.onTintColor = UIColor(named: "FJIconRed")
        cell.sameAsAlarmSwitch.backgroundColor = UIColor(named: "FJIconRed")
        cell.sameAsAlarmSwitch.layer.cornerRadius = 16
        switch row {
        case 13:
            cell.theSubject = "Arrival"
            if theIncidentTime != nil {
                if theIncidentTime.incidentArrivalDateTime == nil {
                    cell.sameDate = true
                    if let alarm = theIncidentTime.incidentAlarmDateTime {
                        cell.theFirstDose = alarm
                    }
                } else {
                    cell.sameDate = false
                    if let alarm = theIncidentTime.incidentArrivalDateTime {
                        cell.theFirstDose = alarm
                    }
                }
            }
        case 16:
            cell.theSubject = "Controlled"
            if theIncidentTime != nil {
                if theIncidentTime.incidentControlDateTime == nil {
                    cell.sameDate = true
                    if let alarm = theIncidentTime.incidentAlarmDateTime {
                        cell.theFirstDose = alarm
                    }
                } else {
                    cell.sameDate = false
                    if let alarm = theIncidentTime.incidentControlDateTime {
                        cell.theFirstDose = alarm
                    }
                }
            }
        case 19:
            cell.theSubject = "Last Unit"
            if theIncidentTime != nil {
                if theIncidentTime.incidentLastUnitDateTime == nil {
                    cell.sameDate = true
                    if let alarm = theIncidentTime.incidentAlarmDateTime {
                        cell.theFirstDose = alarm
                    }
                } else {
                    cell.sameDate = false
                    if let alarm = theIncidentTime.incidentLastUnitDateTime {
                        cell.theFirstDose = alarm
                    }
                }
            }
        default: break
        }
        
        return cell
    }
    
    func configureIncidentTagsCViewTVCell(_ cell: IncidentTagsCViewTVCell, index: IndexPath ) -> IncidentTagsCViewTVCell {
        cell.tag = index.row
        return cell
    }
    
}

extension IncidentVC: IncidentPhotoCollectionCellDelegate {
   
    func theIncidentPhotoCellObjectID(objectID: NSManagedObjectID) {
        let photo = context.object(with: objectID) as? Photo
        let storyboard = UIStoryboard(name: "FullImage", bundle: nil)
        
        guard let navController = storyboard.instantiateViewController(withIdentifier: "FullNC") as? UINavigationController,
              let fullImageVC = navController.topViewController as? FullImageVC else {
            return
        }
        spinner.startAnimating()
        
        taskContext = photoProvider.persistentContainer.newBackgroundContext()
        guard let theGuid = photo?.guid else { return }
        fullImageVC.fullImage = photo?.getImage(with: taskContext, guid: theGuid)
        
        present(navController, animated: true) {
            self.spinner.stopAnimating()
        }
    }
    
    
    
    func theIncidentCellHasBeenTapped(photo: Photo) {
        
        let storyboard = UIStoryboard(name: "FullImage", bundle: nil)
        
        guard let navController = storyboard.instantiateViewController(withIdentifier: "FullNC") as? UINavigationController,
              let fullImageVC = navController.topViewController as? FullImageVC else {
            return
        }
        
        let taskContext = photoProvider.persistentContainer.newBackgroundContext()
        
        spinner.startAnimating()
        
        guard let theGuid = photo.guid else { return }
        fullImageVC.fullImage = photo.getImage(with: taskContext, guid: theGuid)
        
        present(navController, animated: true) {
            self.spinner.stopAnimating()
        }
        
    }
    
}

extension IncidentVC: ModalLableSingleDateFieldCellDelegate {
    
    func modalSingleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        let row = index.row
        switch row {
        case 16:
            if theIncidentTime != nil {
                theIncidentTime.incidentAlarmDateTime = date
            }
        case 19:
            if theIncidentTime != nil {
                theIncidentTime.incidentArrivalDateTime = date
            }
        case 22:
                if theIncidentTime != nil {
                    theIncidentTime.incidentControlDateTime = date
                }
        case 25:
            if theIncidentTime != nil {
                theIncidentTime.incidentLastUnitDateTime = date
            }
        default: break
        }
        if context.hasChanges {
//            context.save(with: .editIncident)
        }
    }
    
}

extension IncidentVC: SubjectLabelTextViewTVCellDelegate {
    
    func subjectLabelTextViewEditing(text: String) {
        if theIncidentNotes != nil {
            theIncidentNotes.incidentNote = text
        }
    }
    
    func subjectLabelTextViewDoneEditing(text: String) {
        if theIncidentNotes != nil {
            theIncidentNotes.incidentNote = text
        }
    }
    
}

extension IncidentVC: MultipleAddButtonTVCellDelegate {
    
    func multiAddBTapped(type: IncidentTypes, index: IndexPath) {
        let row = index.row
        switch row {
        case 4:
            presentModal(menuType: MenuItems.incidents , title: "NFIRS Incident Type", type: IncidentTypes.nfirsIncidentType, index: index)
        case 6:
            presentModal(menuType: MenuItems.incidents , title: "Local Incident Type", type: IncidentTypes.localIncidentType, index: index)
        case 8:
            let storyboard = UIStoryboard(name: "IncidentNote", bundle: nil)
            if let theIncidentNoteVC = storyboard.instantiateViewController(withIdentifier: "TheIncidentNoteVC") as? TheIncidentNoteVC {
                theIncidentNoteVC.modalPresentationStyle = .formSheet
                theIncidentNoteVC.isModalInPresentation = true
                theIncidentNoteVC.theType = IncidentTypes.incidentNote
                theIncidentNoteVC.isIncidentNote = true
                if theIncidentNotes != nil {
                    theIncidentNoteVC.incidentNotesObID = theIncidentNotes.objectID
                    theIncidentNoteVC.delegate = self
                    theIncidentNoteVC.index = index
                    self.present(theIncidentNoteVC , animated: true, completion: nil)
                }
            }
        case 11:
            let storyboard = UIStoryboard(name: "IncidentNote", bundle: nil)
            if let theIncidentNoteVC = storyboard.instantiateViewController(withIdentifier: "TheIncidentNoteVC") as? TheIncidentNoteVC {
                theIncidentNoteVC.modalPresentationStyle = .formSheet
                theIncidentNoteVC.isModalInPresentation = true
                theIncidentNoteVC.theType = IncidentTypes.alarmNote
                theIncidentNoteVC.isIncidentNote = false
                if theIncidentTime != nil {
                    theIncidentNoteVC.incidentTimerObjID = theIncidentTime.objectID
                    theIncidentNoteVC.delegate = self
                    theIncidentNoteVC.index = index
                    self.present(theIncidentNoteVC , animated: true, completion: nil)
                }
            }
        case 14:
            let storyboard = UIStoryboard(name: "IncidentNote", bundle: nil)
            if let theIncidentNoteVC = storyboard.instantiateViewController(withIdentifier: "TheIncidentNoteVC") as? TheIncidentNoteVC {
                theIncidentNoteVC.modalPresentationStyle = .formSheet
                theIncidentNoteVC.isModalInPresentation = true
                theIncidentNoteVC.theType = IncidentTypes.arrivalNote
                theIncidentNoteVC.isIncidentNote = false
                if theIncidentTime != nil {
                    theIncidentNoteVC.incidentTimerObjID = theIncidentTime.objectID
                    theIncidentNoteVC.delegate = self
                    theIncidentNoteVC.index = index
                    self.present(theIncidentNoteVC , animated: true, completion: nil)
                }
            }
        case 17:
            let storyboard = UIStoryboard(name: "IncidentNote", bundle: nil)
            if let theIncidentNoteVC = storyboard.instantiateViewController(withIdentifier: "TheIncidentNoteVC") as? TheIncidentNoteVC {
                theIncidentNoteVC.modalPresentationStyle = .formSheet
                theIncidentNoteVC.isModalInPresentation = true
                theIncidentNoteVC.theType = IncidentTypes.controlledNote
                theIncidentNoteVC.isIncidentNote = false
                if theIncidentTime != nil {
                    theIncidentNoteVC.incidentTimerObjID = theIncidentTime.objectID
                    theIncidentNoteVC.delegate = self
                    theIncidentNoteVC.index = index
                    self.present(theIncidentNoteVC , animated: true, completion: nil)
                }
            }
        case 20:
            let storyboard = UIStoryboard(name: "IncidentNote", bundle: nil)
            if let theIncidentNoteVC = storyboard.instantiateViewController(withIdentifier: "TheIncidentNoteVC") as? TheIncidentNoteVC {
                theIncidentNoteVC.modalPresentationStyle = .formSheet
                theIncidentNoteVC.isModalInPresentation = true
                theIncidentNoteVC.theType = IncidentTypes.lastUnitStandingNote
                theIncidentNoteVC.isIncidentNote = false
                if theIncidentTime != nil {
                    theIncidentNoteVC.incidentTimerObjID = theIncidentTime.objectID
                    theIncidentNoteVC.delegate = self
                    theIncidentNoteVC.index = index
                    self.present(theIncidentNoteVC , animated: true, completion: nil)
                }
            }
        case 22:
            presentModal(menuType: MenuItems.incidents , title: "Actions Taken", type: IncidentTypes.firstAction, index: index)
        case 24:
            presentModal(menuType: MenuItems.incidents , title: "Actions Taken", type: IncidentTypes.secondAction, index: index)
        case 26:
            presentModal(menuType: MenuItems.incidents , title: "Actions Taken", type: IncidentTypes.thirdAction, index: index)
        case 31:
            let storyBoard : UIStoryboard = UIStoryboard(name: "Tags", bundle:nil)
            if let tagsVC = storyBoard.instantiateViewController(withIdentifier: "TagsVC") as? TagsVC {
                tagsVC.modalPresentationStyle = .formSheet
                tagsVC.isModalInPresentation = true
                tagsVC.delegate = self
                self.present(tagsVC, animated: true, completion: nil)
            }
        default: break
        }
    }
    
    func multiTitleChosen(type: IncidentTypes, title: String, index: IndexPath) {
    }
    
    fileprivate func presentModal(menuType: MenuItems, title: String, type: IncidentTypes, index: IndexPath ) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        dataTVC = storyBoard.instantiateViewController(withIdentifier: "ModalDataTVC") as? ModalDataTVC
        dataTVC.delegate = self
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        dataTVC.headerTitle = title
        dataTVC.myShift = menuType
        dataTVC.incidentType = type
        dataTVC.index = index
        dataTVC.context = context
        switch type {
        case .nfirsIncidentType:
            dataTVC.entity = "NFIRSIncidentType"
            dataTVC.attribute = "incidentTypeName"
        case .localIncidentType:
            dataTVC.entity = "UserLocalIncidentType"
            dataTVC.attribute = "localIncidentTypeName"
        case .firstAction:
            dataTVC.entity = "NFIRSActionsTaken"
            dataTVC.attribute = "actionTaken"
        case .secondAction:
            dataTVC.entity = "NFIRSActionsTaken"
            dataTVC.attribute = "actionTaken"
        case .thirdAction:
            dataTVC.entity = "NFIRSActionsTaken"
            dataTVC.attribute = "actionTaken"
        default:break
        }
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
    }
    
    
}

extension IncidentVC: TagsVCDelegate {
    
    func tagsSubmitted(tags: [Tag]) {
        if !tags.isEmpty {
            theTagsAvailable = true
            for tag in tags {
                if !theIncidentTags.isEmpty {
                    let result = theIncidentTags.filter { $0 == tag }
                    if result.isEmpty {
                        let incidentTag = IncidentTags(context: context)
                        incidentTag.incidentTag = tag.name
                        if let guid = theIncident.fjpIncGuidForReference {
                            incidentTag.incidentGuid = guid
                        }
                        if let incidentModDate = theIncident.incidentModDate {
                            let jGuidDate = GuidFormatter.init(date: incidentModDate)
                            let jGuid:String = jGuidDate.formatGuid()
                            let guid = "21." + jGuid
                            incidentTag.incidentGuid = guid
                            incidentTag.guid = UUID()
                        }
                        theIncident.addToIncidentTags(incidentTag)
                        theIncidentTags.append(incidentTag)
                    }
                } else {
                    let incidentTag = IncidentTags(context: context)
                    incidentTag.incidentTag = tag.name
                    if let guid = theIncident.fjpIncGuidForReference {
                        incidentTag.incidentGuid = guid
                    }
                    if let incidentModDate = theIncident.incidentModDate {
                        let jGuidDate = GuidFormatter.init(date: incidentModDate)
                        let jGuid:String = jGuidDate.formatGuid()
                        let guid = "21." + jGuid
                        incidentTag.incidentGuid = guid
                        incidentTag.guid = UUID()
                    }
                    theIncident.addToIncidentTags(incidentTag)
                    theIncidentTags.append(incidentTag)
                }
            }
            if context.hasChanges {
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Updated Incident merge that"])
                    }
                    let objectID = theIncident.objectID
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue :FJkCKModifyIncidentToCloud),
                                     object: nil,
                                     userInfo: ["objectID": objectID as NSManagedObjectID])
                    }
                    DispatchQueue.main.async {
                        self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                    }
//                    TODO: -INCIDENTTAGS TO CLOUD-
                    theAlert(message: "The incident data has been saved.")
                } catch let error as NSError {
                    let nserror = error
                    
                    let errorMessage = "IncidentEdit saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                    print(errorMessage)
                }
            }

            let count = theIncidentTags.count
            let counted = count / 6
            theTagsHeight = CGFloat(counted * 44)
            if theTagsHeight < 100 {
                theTagsHeight = 88
            }
            incidentTableView.reloadRows(at: [IndexPath(row: 32, section: 0)], with: .automatic)
        }
    }
    
}

extension IncidentVC: TheIncidentNoteVCDelegate {
    
    func theNoteHasBeenUpdated(text: String, index: IndexPath, type: IncidentTypes) {
        let row = index.row
        let indexPath = IndexPath(row: row + 1, section: 0)
        switch type {
        case .alarmNote:
            theAlarmNotesAvailable = true
            theAlarmNotes = text
            theAlarmNotesHeight = configureLabelHeight(text: theAlarmNotes)
            if theIncidentTime != nil {
                theIncidentTime.incidentAlarmNotesSC = theAlarmNotes as NSObject
            }
        case .arrivalNote:
            theArrivalNotesAvailable = true
            theArrivalNotes = text
            theArrivalNotesHeight = configureLabelHeight(text: theArrivalNotes)
            if theIncidentTime != nil {
                theIncidentTime.incidentArrivalNotesSC = theArrivalNotes as NSObject
            }
        case .controlledNote:
            theControlledNotesAvailable = true
            theControlledNotes = text
            theControlledNotesHeight = configureLabelHeight(text: theControlledNotes)
            if theIncidentTime != nil {
                theIncidentTime.incidentControlledNotesSC = theControlledNotes as NSObject
            }
        case .lastUnitStandingNote:
            theLastUnitNotesAvailable = true
            theLastUnitNotes = text
            theLastUnitNotesHeight = configureLabelHeight(text: theLastUnitNotes)
            if theIncidentTime != nil {
                theIncidentTime.incidentLastUnitClearedNotesSC = theLastUnitNotes as NSObject
            }
        case .incidentNote:
            theIncidentNotesAvailable = true
            theIncidentNote = text
            theIncidentNotesHeight = configureLabelHeight(text: theIncidentNote)
            if theIncidentNotes != nil {
                theIncidentNotes.incidentNote = theIncidentNote
            }
        default: break
        }
        incidentTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}

extension IncidentVC: ModalDataTVCDelegate {
    
    func theModalDataCancelTapped() {
        dataTVC.dismiss(animated: true , completion: nil)
    }
    
    func theModalDataTapped(object: NSManagedObjectID, type: IncidentTypes, index: IndexPath) {
        let tag = index.row
        let indexPath = IndexPath(row: tag + 1, section: 0)
        switch type {
        case .nfirsIncidentType:
            let nfirsB1Type:NFIRSIncidentType = context.object(with: object) as! NFIRSIncidentType
            var name: String = ""
            var number: String = ""
            if let nfirsNum = nfirsB1Type.incidentTypeNumber {
                number = nfirsNum
            }
            if let nfirsName = nfirsB1Type.incidentTypeName {
                name = nfirsName
            }
            theIncidentNFIRS.incidentTypeTextNFRIS = name
            theIncidentNFIRS.incidentTypeNumberNFRIS = number
            nfirsIncidentType = true
            theNFIRSIncidentTypeText = number + " " + name
            theNFIRSIncidentTypeHeight = configureLabelHeight(text: theNFIRSIncidentTypeText)
            incidentTableView.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .automatic)
        case .localIncidentType:
            let localIncidentType = context.object(with: object) as! UserLocalIncidentType
            if let local = localIncidentType.localIncidentTypeName {
                theIncidentLocal.incidentLocalType = local
                theLocalIncidentType = true
                theLocalIncidentTypeText = local
                incidentTableView.reloadRows(at: [IndexPath(row: 7, section: 0)], with: .automatic)
            }
        case .firstAction:
            let aNIRSActionTaken = context.object(with: object) as! NFIRSActionsTaken
            if let action = aNIRSActionTaken.actionTaken {
                if theActionsTaken != nil {
                    let actionString = action.dropFirst(3)
                    theActionsTaken.primaryAction = String(actionString)
                    if let theAction = aNIRSActionTaken.actionTaken {
                        let number = theAction.prefix(2)
                        theActionsTaken.primaryActionNumber = String(number)
                    }
                } else {
                    if theIncident.actionsTakenDetails != nil {
                        theActionsTaken = theIncident.actionsTakenDetails
                        let actionString = action.dropFirst(3)
                        theActionsTaken.primaryAction = String(actionString)
                        if let theAction = aNIRSActionTaken.actionTaken {
                            let number = theAction.prefix(2)
                            theActionsTaken.primaryActionNumber = String(number)
                        }
                    } else {
                        theActionsTaken = ActionsTaken(context: context)
                        theActionsTaken.guid = UUID()
                        let actionString = action.dropFirst(3)
                        theActionsTaken.primaryAction = String(actionString)
                        if let theAction = aNIRSActionTaken.actionTaken {
                            let number = theAction.prefix(2)
                            theActionsTaken.primaryActionNumber = String(number)
                        }
                        theIncident.actionsTakenDetails = theActionsTaken
                    }
                }
                theAction1 = action
                theAction1Available = true
                theAction1Height = configureLabelHeight(text: theAction1)
            }
        case .secondAction:
            let aNIRSActionTaken = context.object(with: object) as! NFIRSActionsTaken
            if let action = aNIRSActionTaken.actionTaken {
                if theActionsTaken != nil {
                    let actionString = action.dropFirst(3)
                    theActionsTaken.additionalTwo = String(actionString)
                    if let theAction = aNIRSActionTaken.actionTaken {
                        let number = theAction.prefix(2)
                        theActionsTaken.additionalTwoNumber = String(number)
                    }
                } else {
                    if theIncident.actionsTakenDetails != nil {
                        theActionsTaken = theIncident.actionsTakenDetails
                        let actionString = action.dropFirst(3)
                        theActionsTaken.additionalTwo = String(actionString)
                        if let theAction = aNIRSActionTaken.actionTaken {
                            let number = theAction.prefix(2)
                            theActionsTaken.additionalTwoNumber = String(number)
                        }
                    } else {
                        theActionsTaken = ActionsTaken(context: context)
                        theActionsTaken.guid = UUID()
                        let actionString = action.dropFirst(3)
                        theActionsTaken.additionalTwo = String(actionString)
                        if let theAction = aNIRSActionTaken.actionTaken {
                            let number = theAction.prefix(2)
                            theActionsTaken.additionalTwoNumber = String(number)
                        }
                        theIncident.actionsTakenDetails = theActionsTaken
                    }
                }
                theAction2 = action
                theAction2Available = true
                theAction2Height = configureLabelHeight(text: theAction2)
            }
        case .thirdAction:
            let aNIRSActionTaken = context.object(with: object) as! NFIRSActionsTaken
            if let action = aNIRSActionTaken.actionTaken {
                if theActionsTaken != nil {
                    let actionString = action.dropFirst(3)
                    theActionsTaken.additionalThree = String(actionString)
                    if let theAction = aNIRSActionTaken.actionTaken {
                        let number = theAction.prefix(2)
                        theActionsTaken.additionalThreeNumber = String(number)
                    }
                } else {
                    if theIncident.actionsTakenDetails != nil {
                        theActionsTaken = theIncident.actionsTakenDetails
                        let actionString = action.dropFirst(3)
                        theActionsTaken.additionalThree = String(actionString)
                        if let theAction = aNIRSActionTaken.actionTaken {
                            let number = theAction.prefix(2)
                            theActionsTaken.additionalThreeNumber = String(number)
                        }
                    } else {
                        theActionsTaken = ActionsTaken(context: context)
                        theActionsTaken.guid = UUID()
                        let actionString = action.dropFirst(3)
                        theActionsTaken.additionalThree = String(actionString)
                        if let theAction = aNIRSActionTaken.actionTaken {
                            let number = theAction.prefix(2)
                            theActionsTaken.additionalThreeNumber = String(number)
                        }
                        theIncident.actionsTakenDetails = theActionsTaken
                    }
                }
                theAction3 = action
                theAction3Available = true
                theAction3Height = configureLabelHeight(text: theAction3)
            }
        default: break
        }
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Updated Incident merge that"])
            }
            let objectID = theIncident.objectID
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue :FJkCKModifyIncidentToCloud),
                             object: nil,
                             userInfo: ["objectID": objectID as NSManagedObjectID])
            }
            DispatchQueue.main.async {
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
            theAlert(message: "The incident data has been saved.")
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "IncidentEdit saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        dismiss(animated: true, completion: nil)
        incidentTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func theModalDataWithTapped(type: IncidentTypes) {
            //        <#code#>
    }
    
    
}

extension IncidentVC: IncidentEditBarTVCDelegate {
    
    func editBTapped() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "IncidentEdit", bundle:nil)
        incidentEditVC = storyBoard.instantiateViewController(withIdentifier: "IncidentEditVC") as? IncidentEditVC
        incidentEditVC.modalPresentationStyle = .formSheet
        incidentEditVC.isModalInPresentation = true
        incidentEditVC.delegate = self
        incidentEditVC.objectID = theIncident.objectID
        self.present(incidentEditVC, animated: true, completion: nil)
    }
    
}

extension IncidentVC: IncidentEditVCDelegate {
    
    func editSaveTapped(objectID: NSManagedObjectID) {
        theIncident = context.object(with: objectID) as? Incident
        incidentTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        incidentEditVC.dismiss(animated: true, completion: nil)
    }
    
    func editCancelTapped() {
        incidentEditVC.dismiss(animated: true, completion: nil)
    }
    
    
}

extension IncidentVC: NewAddressFieldsButtonsCellDelegate {
    
        //    MARK: -AddressFieldsButtonsCellDelegate-
    
    func worldBTapped(tag: Int) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "OnBoard", bundle:nil)
        let onBoardAddressSearchlVC = storyBoard.instantiateViewController(withIdentifier: "OnBoardAddressSearch") as! OnBoardAddressSearch
        guard let region = getUserLocation.cameraBoundary else {
            mapAlert()
            return
        }
        theUserRegion = region
        onBoardAddressSearchlVC.type = IncidentTypes.allIncidents
        onBoardAddressSearchlVC.boundarys = theUserRegion
        onBoardAddressSearchlVC.searches = getUserLocation.searchBoundary
        onBoardAddressSearchlVC.stationBoundary = getUserLocation.mapBoundary
        onBoardAddressSearchlVC.theMapTag = tag
        onBoardAddressSearchlVC.delegate = self
        self.present(onBoardAddressSearchlVC, animated: true, completion: nil)
    }
    
    func worldB2Tapped(tag: Int) {
        
    }
    
    func locationBTapped(tag: Int) {
        guard let location = getUserLocation.currentLocation else {
            mapAlert()
            return
        }
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            switch tag {
            case 2:
                self.theIncidentLocation.latitude = location.coordinate.latitude
                self.theIncidentLocation.longitude = location.coordinate.longitude
                guard let count = placemarks?.count else {
                    self.errorAlert(errorMessage: "There were no placemarks in this location-  failed with error" + (error?.localizedDescription ?? ""))
                    return
                }
                if count != 0 {
                    guard let pm = placemarks?[0] else { return }
                    if pm.thoroughfare != nil {
                        if let pmCity = pm.locality {
                            self.theIncidentLocation.city = "\(pmCity)"
                        } else {
                            self.theIncidentLocation.city = ""
                        }
                        if let pmSubThroughfare = pm.subThoroughfare {
                            self.theIncidentLocation.streetNumber = "\(pmSubThroughfare)"
                        } else {
                            self.theIncidentLocation.streetNumber = ""
                        }
                        if let pmThoroughfare = pm.thoroughfare {
                            self.theIncidentLocation.streetName = "\(pmThoroughfare)"
                        } else {
                            self.theIncidentLocation.streetName = ""
                        }
                        if let pmState = pm.administrativeArea {
                            self.theIncidentLocation.state = "\(pmState)"
                        } else {
                            self.theIncidentLocation.state = ""
                        }
                        if let pmZip = pm.postalCode {
                            self.theIncidentLocation.zip = "\(pmZip)"
                        } else {
                            self.theIncidentLocation.zip = ""
                        }
                        
                        self.theIncident.locationAvailable = true
                        let index = IndexPath(row: 2, section: 0)
                        self.incidentTableView.reloadRows(at: [index], with: .automatic)
                        
                    }
                }
            default: break
            }
            
        })
    }
    
    
}

extension IncidentVC: OnBoardAddressSearchDelegate {
    
    func addressHasBeenChosen(location: CLLocationCoordinate2D, address: String, tag: Int) {
        self.dismiss(animated: true, completion: nil )
        let theLocation = CLLocation.init(latitude: location.latitude, longitude: location.longitude)
        
        CLGeocoder().reverseGeocodeLocation(theLocation, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                self.errorAlert(errorMessage: "Reverse geocoder failed with error" + (error?.localizedDescription ?? ""))
                return
            }
            
            guard let count = placemarks?.count else {
                self.errorAlert(errorMessage: "There were no placemarks in this location-  failed with error" + (error?.localizedDescription ?? ""))
                return
            }
            if count != 0 {
                switch tag {
                case 2:
                    self.theIncidentLocation.location = theLocation
                    self.theIncidentLocation.latitude = location.latitude
                    self.theIncidentLocation.longitude = location.longitude
                    guard let pm = placemarks?[0] else { return }
                    if pm.thoroughfare != nil {
                        if let pmCity = pm.locality {
                            self.theIncidentLocation.city = "\(pmCity)"
                        } else {
                            self.theIncidentLocation.city = ""
                        }
                        if let pmSubThroughfare = pm.subThoroughfare {
                            self.theIncidentLocation.streetNumber = "\(pmSubThroughfare)"
                        } else {
                            self.theIncidentLocation.streetNumber = ""
                        }
                        if let pmThoroughfare = pm.thoroughfare {
                            self.theIncidentLocation.streetName = "\(pmThoroughfare)"
                        } else {
                            self.theIncidentLocation.streetName = ""
                        }
                        if let pmState = pm.administrativeArea {
                            self.theIncidentLocation.state = "\(pmState)"
                        } else {
                            self.theIncidentLocation.state = ""
                        }
                        if let pmZip = pm.postalCode {
                            self.theIncidentLocation.zip = "\(pmZip)"
                        } else {
                            self.theIncidentLocation.zip = ""
                        }
                        
                        self.theIncident.locationAvailable = true
                        let index = IndexPath(row: 2, section: 0)
                        self.incidentTableView.reloadRows(at: [index], with: .automatic)
                    }
                default: break
                }
            }
            
        })
    }
    
}

extension IncidentVC: SegmentCellDelegate {
    
    func sectionChosen(type: MenuItems) {
        switch type {
        case .fire:
            theIncident.situationIncidentImage = "Fire"
            theIncident.incidentEntryTypeImageName = "100515IconSet_092016_fireboard"
            segmentType = MenuItems.fire
        case .ems:
            theIncident.situationIncidentImage = "EMS"
            theIncident.incidentEntryTypeImageName = "100515IconSet_092016_emsboard"
            segmentType = MenuItems.ems
        case .rescue:
            theIncident.situationIncidentImage = "Rescue"
            theIncident.incidentEntryTypeImageName = "100515IconSet_092016_rescueboard"
            segmentType = MenuItems.rescue
        default: break
        }
    }
    
    
}

extension IncidentVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        theIncidentTime.incidentAlarmDateTime = date
    }
    
}

extension IncidentVC: LabelTextFieldCellDelegate {
    
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
    }
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
    }
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
        theIncident.incidentNumber = text
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        theIncident.incidentNumber = text
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
    }
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
    }
    
    
}

extension IncidentVC: LabelYesNoSwitchCellDelegate {
    
    func labelYesNoSwitchTapped(theShift: MenuItems, yesNoB: Bool, type: IncidentTypes) {
        switch type {
        case .emergency:
            yesNo = yesNoB
            if yesNo {
                theIncident.incidentType = "Emergency"
            } else {
                theIncident.incidentType = "Non-Emergency"
            }
        case .arson:
                yesNo = yesNoB
                if yesNo {
                    theIncident.arsonInvestigation = true
                } else {
                    theIncident.arsonInvestigation = false
                }
        default: break
        }
    }
    
}
