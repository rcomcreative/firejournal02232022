//
//  JournalVC+TVCExtensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/30/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import PhotosUI

extension JournalVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        journalTableView.register(UINib(nibName: "ModalLableSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "ModalLableSingleDateFieldCell")
        journalTableView.register(UINib(nibName: "IncidentSameDateAlarmTVCell", bundle: nil), forCellReuseIdentifier: "IncidentSameDateAlarmTVCell")
        journalTableView.register(UINib(nibName: "IncidentLabelDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "IncidentLabelDateiPhoneTVCell")
        journalTableView.register(UINib(nibName: "IncidentSameDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "IncidentSameDateiPhoneTVCell")
        journalTableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        journalTableView.register(UINib(nibName: "JournalInfoCell", bundle: nil), forCellReuseIdentifier: "JournalInfoCell")
        journalTableView.register(UINib(nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: "SegmentCell")
        journalTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        journalTableView.register(UINib(nibName: "NewAddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "NewAddressFieldsButtonsCell")
        journalTableView.register(RankTVCell.self, forCellReuseIdentifier: "RankTVCell")
        journalTableView.register(MultipleAddButtonTVCell.self, forCellReuseIdentifier: "MultipleAddButtonTVCell")
        journalTableView.register(IncidentEditBarTVC.self, forCellReuseIdentifier: "IncidentEditBarTVC")
        journalTableView.register(IncidentTextViewTVCell.self, forCellReuseIdentifier: "IncidentTextViewTVCell")
        journalTableView.register(JournalEditTVCell.self, forCellReuseIdentifier: "JournalEditTVCell")
        journalTableView.register(JournalTagsCViewTVCell.self, forCellReuseIdentifier: "JournalTagsCViewTVCell")
        journalTableView.register(JournalPhotoCollectionCell.self, forCellReuseIdentifier: "JournalPhotoCollectionCell")
        journalTableView.register(CameraTVCell.self, forCellReuseIdentifier: "CameraTVCell")
    }
    
}

extension JournalVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 32
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 165
        case 1:
            return 290
        case 2:
            return 85
        case 3:
            if theOverviewNotesAvailable {
                return theOverviewNotesHeight
            } else {
                return  0
            }
        case 4:
            return 85
        case 5:
            if theDiscussionNotesAvailable {
                return theDiscussionNotesHeight
            } else {
                return 0
            }
        case 6:
            if Device.IS_IPHONE {
                return 390
            } else {
                return  310
            }
        case 7:
            return 85
        case 8:
            if photosAvailable {
                return 85
            } else {
                return 0
            }
        case 9:
            return 85
        case 10:
            if theTagsAvailable {
                return theTagsHeight
            } else {
                return 0
            }
        case 31:
            return 150
        default:
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch  row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "JournalEditTVCell", for: indexPath) as! JournalEditTVCell
            cell = configureJournalEditTVCell(cell, index: indexPath)
            cell.configureEditButton()
            return cell
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "JournalInfoCell", for: indexPath) as! JournalInfoCell
            cell = configureJournalInfoCell(cell, index: indexPath)
            return cell
        case 2:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 3:
            if theOverviewNotesAvailable {
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell = configureLabelCell(cell, index: indexPath)
                return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 4:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 5:
            if theDiscussionNotesAvailable {
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell = configureLabelCell(cell, index: indexPath)
                return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 6:
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewAddressFieldsButtonsCell", for: indexPath) as! NewAddressFieldsButtonsCell
            let tag = indexPath.row
            cell = configureNewAddressFieldsButtonsCell( cell , at: indexPath , tag: tag)
            cell.configureNewMapButton(type: IncidentTypes.journal)
            cell.configureNewLocationButton(type: IncidentTypes.journal)
            return cell
        case 7:
            var cell = tableView.dequeueReusableCell(withIdentifier: "CameraTVCell", for: indexPath) as! CameraTVCell
            cell = configureCameraTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 8:
            if photosAvailable {
                var cell = tableView.dequeueReusableCell(withIdentifier: "JournalPhotoCollectionCell", for: indexPath) as! JournalPhotoCollectionCell
                cell = configureJournalPhotoCollectionCell(cell, index: indexPath)
                cell.configure(index: indexPath)
                cell.delegate = self
                cell.bringSubviewToFront(cell.photoCollectionView)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                return cell
            }
        case 9:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 10:
            var cell = tableView.dequeueReusableCell(withIdentifier: "JournalTagsCViewTVCell", for: indexPath) as! JournalTagsCViewTVCell
            cell = configureJournalTagsCViewTVCell(cell, index: indexPath)
            cell.configure(theJournal: theJournal)
            return cell
        default:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        }
    }
    
    func configureJournalPhotoCollectionCell(_ cell: JournalPhotoCollectionCell, index: IndexPath) -> JournalPhotoCollectionCell {
        cell.photos = self.validPhotos
        return cell
    }
    
    func configureJournalTagsCViewTVCell(_ cell: JournalTagsCViewTVCell, index: IndexPath ) -> JournalTagsCViewTVCell {
        cell.tag = index.row
        return cell
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
        if theJournalLocation != nil {
            if let number = theJournalLocation.streetNumber {
                streetAddress = number + " "
            }
            if let street = theJournalLocation.streetName {
                streetAddress = streetAddress + street
            }
            if let c = theJournalLocation.city {
                city = c
            }
            if let s = theJournalLocation.state {
                state = s
            }
            if let z = theJournalLocation.zip {
                zip = z
            }
            if theJournalLocation.latitude != 0.0 {
                latitude = String(theJournalLocation.latitude)
            }
            if theJournalLocation.longitude != 0.0 {
                longitude = String(theJournalLocation.longitude)
            }
        }
        cell.addressTF.text = streetAddress
        cell.addressTF.placeholder = "100 Grant"
        cell.addressTF.textColor = .label
        cell.cityTF.text = city
        cell.cityTF.placeholder = "City"
        cell.cityTF.textColor = .label
        cell.stateTF.text = state
        cell.stateTF.placeholder = "State"
        cell.stateTF.textColor = .label
        cell.zipTF.text = zip
        cell.zipTF.placeholder = "Zip Code"
        cell.zipTF.textColor = .label
        cell.addressLatitudeTF.text = latitude
        cell.addressLatitudeTF.textColor = .label
        cell.addressLongitudeTF.text = longitude
        cell.addressLongitudeTF.textColor = .label
        cell.addressLatitudeTF.placeholder = "Latitude"
        cell.addressLongitudeTF.placeholder = "Longitude"
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
        case 3:
            cell.modalTitleL.text = theOverviewNotes
        case 5:
            cell.modalTitleL.text = theDiscussionNotes
        default: break
        }
        cell.modalTitleL.setNeedsDisplay()
        return cell
    }
    
    func configureCameraTVCell(_ cell: CameraTVCell, index: IndexPath) -> CameraTVCell {
        cell.tag = index.row
        cell.indexPath = index
        let section = index.section
        let row = index.row
        cell.delegate = self
        switch section {
        case 0:
            switch row {
            case 7:
                cell.type = IncidentTypes.journal
                cell.aBackgroundColor = "FJBlueColor"
            default: break
            }
        default: break
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
            case 2:
                cell.type = IncidentTypes.overview
                cell.aBackgroundColor = "FJBlueColor"
                cell.aChoice = ""
            case 4:
                cell.type = IncidentTypes.discussion
                cell.aBackgroundColor = "FJBlueColor"
                cell.aChoice = ""
            case 9:
                cell.type = IncidentTypes.tags
                cell.aBackgroundColor = "FJBlueColor"
                cell.aChoice = ""
            default: break
            }
        default: break
        }
        return cell
    }
    
    func configureJournalInfoCell(_ cell: JournalInfoCell, index: IndexPath) -> JournalInfoCell {
        cell.tag = index.row
        cell.delegate = self
        cell.subjectL.text = "User Data"
        cell.label1L.text = "User"
        cell.label2L.text = "Entry Type"
        cell.label3L.text = "Fire Station"
        cell.label4L.text = "Platoon"
        cell.label5L.text = "Apparatus"
        cell.label6L.text = "Assignment"
        if let user = theUser.userName {
            cell.user = user
            if user == "" {
                var name: String = ""
                if let first = theUser.firstName {
                    name = first
                }
                if let last = theUser.lastName {
                    name = name + " " + last
                }
                cell.user = name
            }
        }
        if let theType = theJournal.journalEntryType {
            cell.entryType = theType
        }
        if let station = theJournal.journalFireStation {
            cell.fireStation = station
        }
        if let platton = theJournal.journalTempPlatoon {
            cell.platoon = platton
        }
        if let apparatus = theJournal.journalTempApparatus {
            cell.apparatus = apparatus
        }
        if let assignmet = theJournal.journalTempAssignment {
            cell.assignment = assignmet
        }
        return cell
    }
    
    func configureJournalEditTVCell(_ cell: JournalEditTVCell, index: IndexPath) -> JournalEditTVCell {
        cell.tag = index.row
        cell.delegate = self
        if let imageName = theJournal.journalEntryTypeImageName {
            cell.imageName = imageName
        } else {
            cell.imageName = typeNameA[0]
        }
        if let journalTitle = theJournal.journalHeader {
            cell.journalNumber = journalTitle
        }
        var address: String = ""
        if theJournalLocation != nil {
            if let number = theJournalLocation.streetNumber {
                address = number
            }
            if let street = theJournalLocation.streetName {
                address = address + " " + street
            }
            if let city = theJournalLocation.city {
                address = address + " " + city
            }
            if let state = theJournalLocation.state {
                address = address + ", " + state
            }
            if let zip = theJournalLocation.zip {
                address = address + " " + zip
            }
            cell.journalAddress = address
        }
        dateFormatter.dateFormat = "EEE MMM dd,YYYY HH:mm"
        if theJournal != nil {
            if let cDate = theJournal.journalCreationDate {
                let journalTime = dateFormatter.string(from: cDate)
                cell.journalDate = journalTime
            }
        }
        cell.configure()
        return cell
    }
    
    func configureLabelTextFieldCell(_ cell: LabelTextFieldCell, index: IndexPath) -> LabelTextFieldCell {
        let row = index.row
        switch row {
        default:
            cell.subjectL.isHidden = true
            cell.subjectL.alpha = 0.0
            cell.descriptionTF.isHidden = true
            cell.descriptionTF.isEnabled = false
            cell.descriptionTF.alpha = 0.0
        }
        return cell
    }
}
