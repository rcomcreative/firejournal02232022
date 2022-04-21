    //
    //  IncidentNewModalVC + Extensions.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 3/11/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import Foundation
import CoreData
import CloudKit
import MapKit
import CoreLocation

extension IncidentNewModalVC: ModalHeaderSaveDismissDelegate {
    
    func modalDismiss() {
        if theIncident != nil {
            context.delete(theIncident)
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Newer Incident merge that"])
                }
            } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "IncidentNew saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
            theIncident = nil
        }
        delegate?.incidentNewCancelled()
    }
    
    func modalSave(myShift: MenuItems) {
        if theIncident.incidentNumber == "" || theIncident.incidentNumber == nil{
            let cell = incidentTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! LabelTextFieldCell
            if let number = cell.descriptionTF.text {
                theIncident.incidentNumber = number
            } else {
                theIncident.incidentNumber = ""
            }
        }
        if theIncident.locationAvailable, theIncident.incidentNumber != "" {
            buildTheJournalEntry()
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Newer Incident merge that"])
                }
                let objectID = theIncident.objectID
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKNewIncidentCreated),
                                 object: nil,
                                 userInfo: ["objectID": objectID as NSManagedObjectID])
                }
                DispatchQueue.main.async {
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
                delegate?.incidentNewSaved(objectID: objectID)
            } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "IncidentNew saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
        } else {
            var message: String = "The following is needed to complete\n\n"
            var messagesA = [String]()
            if theIncident.incidentNumber == "" {
                let error: String = "The incident number is needed."
                messagesA.append(error)
            }
            if !theIncident.locationAvailable {
                let error: String = "The incident address is needed."
                messagesA.append(error)
            }
            let theMessage = messagesA.joined(separator: "\n")
            message = message + theMessage
            errorAlert(errorMessage: message)
        }
        
    }
    
    func modalInfoBTapped(myShift: MenuItems) {
        presentAlert()
    }
    
    func buildTheJournalEntry() {
        theJournal = Journal(context: context)
        let journalModDate = Date()
        let jGuidDate = GuidFormatter.init(date:journalModDate)
        let searchDate = FormattedDate.init(date:journalModDate)
        let sDate:String = searchDate.formatTheDateAndTime()
        let jGuid:String = jGuidDate.formatGuid()
        theJournal.fjpJGuidForReference = "01."+jGuid
        let incidentModDate = theIncident.incidentModDate
        theJournal.journalModDate = incidentModDate
        theJournal.journalCreationDate = incidentModDate
        theJournal.fjpJournalModifiedDate = incidentModDate
        theJournal.journalEntryType = theIncident.situationIncidentImage
        theJournal.journalEntryTypeImageName = "NOTJournal"
        theJournal.journalDateSearch = sDate
        theJournal.fjpIncReference = theIncident.fjpIncGuidForReference
        theJournal.fjpUserReference = theUser.userGuid
        if let number = theIncident.incidentNumber {
            theJournal.journalHeader = "Incident " + number + " " + sDate
        } else {
            theJournal.journalHeader = "Incident " + sDate
        }
        
        theJournal.incidentDetails = theIncident
        theJournal.fireJournalUserInfo = theUser
        theJournal.userTime = theUserTime
        
    }
    
}

extension IncidentNewModalVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        incidentTableView.register(UINib(nibName: "SubjectLabelTextFieldIndicatorTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextFieldIndicatorTVCell")
        incidentTableView.register(UINib(nibName: "SubjectLabelTextViewTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextViewTVCell")
        incidentTableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
        
        incidentTableView.register(UINib(nibName: "LabelDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "LabelDateiPhoneTVCell")
        incidentTableView.register(UINib(nibName: "LabelYesNoSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelYesNoSwitchCell")
        incidentTableView.register(UINib(nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: "SegmentCell")
        incidentTableView.register(UINib(nibName: "NewAddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "NewAddressFieldsButtonsCell")
        incidentTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        incidentTableView.register(RankTVCell.self, forCellReuseIdentifier: "RankTVCell")
    }
    
}

extension IncidentNewModalVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 65
        case 1:
            return 85
        case 2:
            if Device.IS_IPHONE {
                return 100
            } else {
            return 60
            }
        case 3:
            return 84
        case 4:
            if Device.IS_IPHONE {
                return 390
            } else {
                return  310
            }
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch  row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelYesNoSwitchCell", for: indexPath) as! LabelYesNoSwitchCell
            cell = configureLabelYesNoSwitchCell(cell, index: indexPath)
            return cell
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        case 2:
            if Device.IS_IPHONE {
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateiPhoneTVCell", for: indexPath) as! LabelDateiPhoneTVCell
                cell = configureLabelDateiPhoneTVCell(cell, index: indexPath)
                return cell
            } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelSingleDateFieldCell", for: indexPath) as! LabelSingleDateFieldCell
            cell = configureLabelSingleDateFieldCell(cell, index: indexPath)
            cell.configureTheLabel(width: 125)
            cell.configureDatePickersHoldingV()
            return cell
            }
        case 3:
            var cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
            cell = configureSegmentCell(cell, index: indexPath)
            return cell
        case 4:
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewAddressFieldsButtonsCell", for: indexPath) as! NewAddressFieldsButtonsCell
            let tag = indexPath.row
            cell = configureNewAddressFieldsButtonsCell( cell , at: indexPath , tag: tag)
            cell.configureNewMapButton(type: IncidentTypes.allIncidents)
            cell.configureNewLocationButton(type: IncidentTypes.allIncidents)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            return cell
        }
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
        if theIncident.locationAvailable {
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
    
    func configureSegmentCell(_ cell: SegmentCell, index: IndexPath) -> SegmentCell {
        let tag = index.row
        cell.tag = tag
        cell.delegate = self
        cell.subjectL.text = "Incident Type"
        cell.myShift = .incidents
        cell.typeSegment.setTitle("Fire", forSegmentAt: 0)
        cell.typeSegment.setTitle("EMS", forSegmentAt: 1)
        cell.typeSegment.setTitle("Rescue", forSegmentAt: 2)
        
        if theIncident.situationIncidentImage == "" {
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
    
    func configureLabelDateiPhoneTVCell(_ cell: LabelDateiPhoneTVCell, index: IndexPath) -> LabelDateiPhoneTVCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        cell.index = index
        let section = index.section
        switch section {
        case 0:
            switch row {
            case 2:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Date/Time"
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
    
    func configureLabelSingleDateFieldCell(_ cell: LabelSingleDateFieldCell, index: IndexPath ) -> LabelSingleDateFieldCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        cell.index = index
        let section = index.section
        switch section {
        case 0:
            switch row {
            case 2:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Date/Time"
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
        default: break
        }
        return cell
    }
    
}

extension IncidentNewModalVC: LabelDateiPhoneTVCellDelegate {
    
    func theDatePickerTapped(_ theDate: Date, index: IndexPath) {
        theIncidentTime.incidentAlarmDateTime = theDate
    }
    
}

extension IncidentNewModalVC: NewAddressFieldsButtonsCellDelegate {
    
        //    MARK: -AddressFieldsButtonsCellDelegate-
    
    func worldBTapped(tag: Int) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "OnBoard", bundle:nil)
        let onBoardAddressSearchlVC = storyBoard.instantiateViewController(withIdentifier: "OnBoardAddressSearch") as! OnBoardAddressSearch
        guard let region = getUserLocation.cameraBoundary else {
            mapAlert()
            return }
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
            case 4:
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
                        let index = IndexPath(row: 4, section: 0)
                        self.incidentTableView.reloadRows(at: [index], with: .automatic)
                        
                    }
                }
            default: break
            }
            
        })
    }
    
    
}

extension IncidentNewModalVC: OnBoardAddressSearchDelegate {
    
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
                case 4:
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
                        let index = IndexPath(row: 4, section: 0)
                        self.incidentTableView.reloadRows(at: [index], with: .automatic)
                    }
                default: break
                }
            }
            
        })
    }
    
}

extension IncidentNewModalVC: SegmentCellDelegate {
    
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

extension IncidentNewModalVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        theIncidentTime.incidentAlarmDateTime = date
    }
    
}

extension IncidentNewModalVC: LabelTextFieldCellDelegate {
    
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

extension IncidentNewModalVC: LabelYesNoSwitchCellDelegate {
    
    func labelYesNoSwitchTapped(theShift: MenuItems, yesNoB: Bool, type: IncidentTypes) {
        yesNo = yesNoB
        if yesNo {
            theIncident.incidentType = "Emergency"
        } else {
            theIncident.incidentType = "Non-Emergency"
        }
    }
    
}
