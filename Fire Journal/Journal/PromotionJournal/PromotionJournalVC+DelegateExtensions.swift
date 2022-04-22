//
//  PromotionJournalVC+DelegateExtensions.swift
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

extension PromotionJournalVC {
    
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
        label.font = .systemFont(ofSize: 18)
        label.text = text
        label.sizeToFit()
        let labelFrame = label.frame
        theFloat = labelFrame.height
        label.removeFromSuperview()
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
    
    func configureTheProjectTableView() {
        projectTableView = UITableView(frame: .zero)
        registerCellsForTable()
        projectTableView.translatesAutoresizingMaskIntoConstraints = false
        projectTableView.backgroundColor = .systemBackground
        view.addSubview(projectTableView)
        projectTableView.delegate = self
        projectTableView.dataSource = self
        projectTableView.separatorStyle = .none
        
        projectTableView.rowHeight = UITableView.automaticDimension
        projectTableView.estimatedRowHeight = 300
        
        if Device.IS_IPHONE {
            NSLayoutConstraint.activate([
                projectTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                projectTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                projectTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                projectTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            ])
        } else {
        NSLayoutConstraint.activate([
            projectTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            projectTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            projectTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            projectTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
        }
    }
    
}

extension PromotionJournalVC: LabelTextFieldCellDelegate {
    
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {}
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        let row = tag
        switch row {
        case 0:
            theProject.projectName = text
        case 2:
            theProject.projectType = text
        default: break
        }
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
    
    
}

extension PromotionJournalVC: LabelDateiPhoneTVCellDelegate {
    
    func theDatePickerTapped(_ theDate: Date, index: IndexPath) {
        let row = index.row
        switch row {
        case 1:
            theProject.promotionDate = theDate
        default: break
        }
    }
    
}

extension PromotionJournalVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        let row = index.row
        switch row {
        case 1:
            theProject.promotionDate = date
        default: break
        }
    }
    
    
}

extension PromotionJournalVC: MultipleAddButtonTVCellDelegate {
    
    func multiAddBTapped(type: IncidentTypes, index: IndexPath) {
        let row = index.row
        switch row {
        case 3:
            let storyboard = UIStoryboard(name: "PromotionNote", bundle: nil)
            if let thePromotionNoteVC = storyboard.instantiateViewController(withIdentifier: "PromotionNoteVC") as? PromotionNoteVC {
                thePromotionNoteVC.modalPresentationStyle = .formSheet
                thePromotionNoteVC.isModalInPresentation = true
                thePromotionNoteVC.theType = IncidentTypes.theProjectOverview
                if theProject != nil {
                    thePromotionNoteVC.promotionObID = theProject.objectID
                    thePromotionNoteVC.delegate = self
                    thePromotionNoteVC.index = index
                    self.present(thePromotionNoteVC , animated: true, completion: nil)
                }
            }
        case 5:
            let storyboard = UIStoryboard(name: "PromotionNote", bundle: nil)
            if let thePromotionNoteVC = storyboard.instantiateViewController(withIdentifier: "PromotionNoteVC") as? PromotionNoteVC {
                thePromotionNoteVC.modalPresentationStyle = .formSheet
                thePromotionNoteVC.isModalInPresentation = true
                thePromotionNoteVC.theType = IncidentTypes.theProjectClassNote
                if theProject != nil {
                    thePromotionNoteVC.promotionObID = theProject.objectID
                    thePromotionNoteVC.delegate = self
                    thePromotionNoteVC.index = index
                    self.present(thePromotionNoteVC , animated: true, completion: nil)
                }
            }
        default: break
        }
    }
    
    func multiTitleChosen(type: IncidentTypes, title: String, index: IndexPath) {
    }
    
    
}

extension PromotionJournalVC: PromotionNoteVCDelegate {
    
    func thePromotionNoteHasBeenUpdated(text: String, index: IndexPath, type: IncidentTypes) {
        let indexPath = IndexPath(row: 4, section: 0)
        switch type {
        case .theProjectOverview:
            theOverviewNotesAvailable = true
            theOverviewNotes = text
            theOverviewNotesHeight = configureLabelHeight(text: theOverviewNotes)
            if theProject != nil {
                theProject.overview = theOverviewNotes as NSObject
            }
        case .theProjectClassNote:
            theProjectNotesAvailable = true
            theProjectNotes = text
            theProjectNotesHeight = configureLabelHeight(text: theProjectNotes)
            if theProject != nil {
                theProject.studyClassNote = theProjectNotes as NSObject
            }
        default: break
        }
        projectTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}

extension PromotionJournalVC: JournalEditTVCellDelegate {
    
    func editBTapped() {
        let errorMessage = "This is not available yet."
        errorAlert(errorMessage: errorMessage)

    }
    
    
}

extension PromotionJournalVC: NewAddressFieldsButtonsCellDelegate {
    
        //    MARK: -AddressFieldsButtonsCellDelegate-
    
    func worldBTapped(tag: Int) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "OnBoard", bundle:nil)
        let onBoardAddressSearchlVC = storyBoard.instantiateViewController(withIdentifier: "OnBoardAddressSearch") as! OnBoardAddressSearch
        guard let region = getUserLocation.cameraBoundary else {
            mapAlert()
            return
        }
        theUserRegion = region
        onBoardAddressSearchlVC.type = IncidentTypes.journal
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
            case 6:
                self.theLocation.location = location
                self.theLocation.latitude = location.coordinate.latitude
                self.theLocation.longitude = location.coordinate.longitude
                guard let count = placemarks?.count else {
                    self.errorAlert(errorMessage: "There were no placemarks in this location-  failed with error" + (error?.localizedDescription ?? ""))
                    return
                }
                if count != 0 {
                    guard let pm = placemarks?[0] else { return }
                    if pm.thoroughfare != nil {
                        if let pmCity = pm.locality {
                            self.theLocation.city = "\(pmCity)"
                        } else {
                            self.theLocation.city = ""
                        }
                        if let pmSubThroughfare = pm.subThoroughfare {
                            self.theLocation.streetNumber = "\(pmSubThroughfare)"
                        } else {
                            self.theLocation.streetNumber = ""
                        }
                        if let pmThoroughfare = pm.thoroughfare {
                            self.theLocation.streetName = "\(pmThoroughfare)"
                        } else {
                            self.theLocation.streetName = ""
                        }
                        if let pmState = pm.administrativeArea {
                            self.theLocation.state = "\(pmState)"
                        } else {
                            self.theLocation.state = ""
                        }
                        if let pmZip = pm.postalCode {
                            self.theLocation.zip = "\(pmZip)"
                        } else {
                            self.theLocation.zip = ""
                        }
                        
                        self.locationAvailable = true
                        let index = IndexPath(row: 9, section: 0)
                        self.projectTableView.reloadRows(at: [index], with: .automatic)
                        
                    }
                }
            default: break
            }
            
        })
    }
    
    
}

extension PromotionJournalVC: OnBoardAddressSearchDelegate {
    
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
                case 6:
                    self.theLocation.location = theLocation
                    self.theLocation.latitude = location.latitude
                    self.theLocation.longitude = location.longitude
                    guard let pm = placemarks?[0] else { return }
                    if pm.thoroughfare != nil {
                        if let pmCity = pm.locality {
                            self.theLocation.city = "\(pmCity)"
                        } else {
                            self.theLocation.city = ""
                        }
                        if let pmSubThroughfare = pm.subThoroughfare {
                            self.theLocation.streetNumber = "\(pmSubThroughfare)"
                        } else {
                            self.theLocation.streetNumber = ""
                        }
                        if let pmThoroughfare = pm.thoroughfare {
                            self.theLocation.streetName = "\(pmThoroughfare)"
                        } else {
                            self.theLocation.streetName = ""
                        }
                        if let pmState = pm.administrativeArea {
                            self.theLocation.state = "\(pmState)"
                        } else {
                            self.theLocation.state = ""
                        }
                        if let pmZip = pm.postalCode {
                            self.theLocation.zip = "\(pmZip)"
                        } else {
                            self.theLocation.zip = ""
                        }
                        
                        self.locationAvailable = true
                        let index = IndexPath(row: 9, section: 0)
                        self.projectTableView.reloadRows(at: [index], with: .automatic)
                    }
                default: break
                }
            }
            
        })
    }
    
}



