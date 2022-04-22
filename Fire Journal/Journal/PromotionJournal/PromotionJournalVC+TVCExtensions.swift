//
//  PromotionJournalVC+TVCExtensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/21/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//



import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import PhotosUI

extension PromotionJournalVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        projectTableView.register(JournalEditTVCell.self, forCellReuseIdentifier: "JournalEditTVCell")
        projectTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        projectTableView.register(UINib(nibName: "LabelDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "LabelDateiPhoneTVCell")
        projectTableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
        projectTableView.register(MultipleAddButtonTVCell.self, forCellReuseIdentifier: "MultipleAddButtonTVCell")
        projectTableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        projectTableView.register(UINib(nibName: "NewAddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "NewAddressFieldsButtonsCell")
        projectTableView.register(JournalTagsCViewTVCell.self, forCellReuseIdentifier: "JournalTagsCViewTVCell")
        projectTableView.register(JournalPhotoCollectionCell.self, forCellReuseIdentifier: "JournalPhotoCollectionCell")
        projectTableView.register(CameraTVCell.self, forCellReuseIdentifier: "CameraTVCell")
    }
    
}

extension PromotionJournalVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 165
        case 1:
            if Device.IS_IPHONE {
                return 100
            } else {
                return 60
            }
        case 2:
            return 85
        case 3:
            return 85
        case 4:
            if theOverviewNotesAvailable {
                return theOverviewNotesHeight
            } else {
                return 0
            }
        case 5:
            return 85
        case 6:
            if theProjectNotesAvailable {
                return theProjectNotesHeight
            } else {
                return 0
            }
        case 7:
            return 85
        case 8:
            return 88
        case 9:
            if Device.IS_IPHONE {
                return 390
            } else {
                return  310
            }
        case 10:
            return 85
        case 11:
            if photosAvailable {
                return 85
            } else {
                return 0
            }
        case 12:
            return 85
        case 13:
            if theTagsAvailable {
                return theTagsHeight
            } else {
                return 0
            }
        case 14:
            return 150
        default:
            return 44
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
        case 2:
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell = configureLabelTextFieldCell(cell, index: indexPath)
                return cell
        case 3:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 4:
            if theOverviewNotesAvailable {
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell = configureLabelCell(cell, index: indexPath)
                return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 5:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 6:
            if theProjectNotesAvailable {
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell = configureLabelCell(cell, index: indexPath)
                return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 7:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 8:
            if theProjectCrewAvailable {
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell = configureLabelCell(cell, index: indexPath)
                return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 9:
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewAddressFieldsButtonsCell", for: indexPath) as! NewAddressFieldsButtonsCell
                let tag = indexPath.row
                cell = configureNewAddressFieldsButtonsCell( cell , at: indexPath , tag: tag)
                cell.configureNewMapButton(type: IncidentTypes.journal)
                cell.configureNewLocationButton(type: IncidentTypes.journal)
                return cell
        case 10:
            var cell = tableView.dequeueReusableCell(withIdentifier: "CameraTVCell", for: indexPath) as! CameraTVCell
            cell = configureCameraTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 11:
            if photosAvailable {
                var cell = tableView.dequeueReusableCell(withIdentifier: "JournalPhotoCollectionCell", for: indexPath) as! JournalPhotoCollectionCell
                cell = configureJournalPhotoCollectionCell(cell, index: indexPath)
                cell.configure(index: indexPath)
//                cell.delegate = self
                cell.bringSubviewToFront(cell.photoCollectionView)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                return cell
            }
        case 12:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 13:
            var cell = tableView.dequeueReusableCell(withIdentifier: "JournalTagsCViewTVCell", for: indexPath) as! JournalTagsCViewTVCell
            cell = configureJournalTagsCViewTVCell(cell, index: indexPath)
//            cell.configure(theJournal: theJournal)
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
    
    func configureCameraTVCell(_ cell: CameraTVCell, index: IndexPath) -> CameraTVCell {
        cell.tag = index.row
        cell.indexPath = index
        let section = index.section
        let row = index.row
        cell.delegate = self
        switch section {
        case 0:
            switch row {
            case 10:
                cell.type = IncidentTypes.theProject
                cell.aBackgroundColor = "FJBlueColor"
            default: break
            }
        default: break
        }
        return cell
    }
    
    func configureJournalEditTVCell(_ cell: JournalEditTVCell, index: IndexPath) -> JournalEditTVCell {
        cell.tag = index.row
        cell.delegate = self
        let imageName = typeNameA[0]
        if imageName != "" {
            cell.imageName = imageName
        }
        if let title = theProject.projectName {
            cell.journalNumber = title
        }
        var address: String = ""
        if theLocation != nil {
            if let number = theLocation.streetNumber {
                address = number
            }
            if let street = theLocation.streetName {
                address = address + " " + street
            }
            if let city = theLocation.city {
                address = address + " " + city
            }
            if let state = theLocation.state {
                address = address + ", " + state
            }
            if let zip = theLocation.zip {
                address = address + " " + zip
            }
            cell.journalAddress = address
        }
        dateFormatter.dateFormat = "EEE MMM dd,YYYY HH:mm"
        if theProject != nil {
            if let cDate = theProject.promotionDate {
                let journalTime = dateFormatter.string(from: cDate)
                cell.journalDate = journalTime
            }
        }
        cell.configure()
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
        if theLocation != nil {
            if let number = theLocation.streetNumber {
                streetAddress = number + " "
            }
            if let street = theLocation.streetName {
                streetAddress = streetAddress + street
            }
            if let c = theLocation.city {
                city = c
            }
            if let s = theLocation.state {
                state = s
            }
            if let z = theLocation.zip {
                zip = z
            }
            if theLocation.latitude != 0.0 {
                latitude = String(theLocation.latitude)
            }
            if theLocation.longitude != 0.0 {
                longitude = String(theLocation.longitude)
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
    
    func configureLabelTextFieldCell(_ cell: LabelTextFieldCell, index: IndexPath) -> LabelTextFieldCell {
        let row = index.row
        cell.tag = row
        switch row {
        case 0:
            cell.delegate = self
            cell.theShift = MenuItems.projects
            cell.subjectL.text = "Project"
            cell.descriptionTF.tag = 1
            if let topic = theProject.projectName {
                cell.descriptionTF.text = topic
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Project title",attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2])
            }
            cell.descriptionTF.keyboardType = .alphabet
            return cell
        case 2:
            cell.delegate = self
            cell.theShift = MenuItems.projects
            cell.subjectL.text = "Project Type"
            cell.descriptionTF.tag = 1
            if let topic = theProject.projectType {
                cell.descriptionTF.text = topic
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Project type: class, training, other ",attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2])
            }
            cell.descriptionTF.keyboardType = .alphabet
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
    
    func configureLabelDateiPhoneTVCell(_ cell: LabelDateiPhoneTVCell, index: IndexPath) -> LabelDateiPhoneTVCell {
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
                if theProject != nil {
                    if let projectDate = theProject.promotionDate {
                        cell.theFirstDose = projectDate
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
            case 1:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Date/Time"
                if theProject != nil {
                    if let projectDate = theProject.promotionDate {
                        cell.theFirstDose = projectDate
                    }
                }
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
            case 3:
                cell.type = IncidentTypes.theProjectOverview
                cell.aBackgroundColor = "FJBlueColor"
                cell.aChoice = ""
            case 5:
                cell.type = IncidentTypes.theProjectClassNote
                cell.aBackgroundColor = "FJBlueColor"
                cell.aChoice = ""
            default: break
            }
        default: break
        }
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
        case 4:
            cell.modalTitleL.text = theOverviewNotes
        default: break
        }
        cell.modalTitleL.setNeedsDisplay()
        return cell
    }
    
    
    
}
